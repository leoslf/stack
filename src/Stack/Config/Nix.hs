{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE RecordWildCards, DeriveDataTypeable, OverloadedStrings #-}

-- | Nix configuration
module Stack.Config.Nix
       (nixOptsFromMonoid
       ,nixCompiler
       ,StackNixException(..)
       ) where

import Stack.Prelude
import Control.Monad.Extra (ifM)
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import Distribution.System (OS (..))
import Stack.Constants
import Stack.Types.Version
import Stack.Types.Nix
import Stack.Types.Compiler
import Stack.Types.Runner
import System.Directory (doesFileExist)

-- | Interprets NixOptsMonoid options.
nixOptsFromMonoid
    :: HasRunner env
    => NixOptsMonoid
    -> OS
    -> RIO env NixOpts
nixOptsFromMonoid NixOptsMonoid{..} os = do
    let defaultPure = case os of
          OSX -> False
          _ -> True
        nixPureShell = fromFirst defaultPure nixMonoidPureShell
        nixPackages = fromFirst [] nixMonoidPackages
        nixInitFile = getFirst nixMonoidInitFile
        nixShellOptions = fromFirst [] nixMonoidShellOptions
                          ++ prefixAll (T.pack "-I") (fromFirst [] nixMonoidPath)
        nixAddGCRoots   = fromFirst False nixMonoidAddGCRoots

    -- Enable Nix-mode by default on NixOS, unless Docker-mode was specified
    osIsNixOS <- isNixOS
    let nixEnable0 = fromFirst osIsNixOS nixMonoidEnable

    nixEnable <- case () of _
                                | nixEnable0 && osIsWindows -> do
                                      logInfo "Note: Disabling nix integration, since this is being run in Windows"
                                      return False
                                | otherwise                 -> return nixEnable0

    when (not (null nixPackages) && isJust nixInitFile) $
       throwIO NixCannotUseShellFileAndPackagesException
    return NixOpts{..}
  where prefixAll p (x:xs) = p : x : prefixAll p xs
        prefixAll _ _      = []

nixCompiler :: CompilerVersion a -> Either StringException T.Text
nixCompiler compilerVersion =
  case compilerVersion of
    GhcVersion version ->
      case T.split (== '.') (versionText version) of
        x : y : minor ->
          Right $
          case minor of
            [] ->
              -- The minor version is not specified. Select the latest minor
              -- version in Nixpkgs corresponding to the requested major
              -- version.
              let major = T.concat [x, y] in
              "(let compilers = builtins.filter \
              \(name: builtins.match \
              \\"ghc" <> major <> "[[:digit:]]*\" name != null) \
              \(lib.attrNames haskell.compiler); in \
              \if compilers == [] \
              \then abort \"No compiler found for GHC "
              <> versionText version <> "\"\
              \else haskell.compiler.${builtins.head compilers})"
            _ -> "haskell.compiler.ghc" <> T.concat (x : y : minor)
        _ -> Left $ stringException "GHC major version not specified"
    _ -> Left $ stringException "Only GHC is supported by stack --nix"

-- Exceptions thown specifically by Stack.Nix
data StackNixException
  = NixCannotUseShellFileAndPackagesException
    -- ^ Nix can't be given packages and a shell file at the same time
    deriving (Typeable)

instance Exception StackNixException

instance Show StackNixException where
  show NixCannotUseShellFileAndPackagesException =
    "You cannot have packages and a shell-file filled at the same time in your nix-shell configuration."

isNixOS :: MonadIO m => m Bool
isNixOS = liftIO $ do
    let fp = "/etc/os-release"
    ifM (doesFileExist fp)
        (T.isInfixOf "ID=nixos" <$> TIO.readFile fp)
        (return False)
