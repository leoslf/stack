<div class="hidden-warning"><a href="https://docs.haskellstack.org/"><img src="https://cdn.jsdelivr.net/gh/commercialhaskell/stack/doc/img/hidden-warning.svg"></a></div>

# Upgrading MSYS2

When installing GHC on Windows, Stack will also install
[MSYS2](http://www.msys2.org/). MSYS2 provides a Unix shell and environment, and
is necessary for such things as running configure scripts. This section explains
the steps required to upgrade the MSYS2 version used by Stack.

1.  Download latest installer(s) from MSYS2's website. Historically, there were
    separate installers for 32 bit (`i686`) and 64 bit (`x86_64`). On
    17 May 2020, the MSYS2 project announced it did not plan to release any
    further `i686` installers. An installer is an executable, versioned by a
    date in the format YYYYMMDD - for example, `msys2-x86_64-20220503.exe`.

2.  Run the installer and install to the default location (`C:\msys64` for the
    64 bit version; the location for the 32 bit version was `C:\msys32`). Do not
    use the installed version; it will create a `.bash_history` file if you do.

3.  Create a tarball for each relevant directory (eg `C:\msys64`). That requires
    a version of [`tar`](https://www.gnu.org/software/tar/tar.html) that
    supports the compression option `--xz`. The version of `tar` that is
    supplied with Windows (`C:\Windows\System32\tar.exe`) does not support that
    option, but MSYS2 can supply a [version](https://packages.msys2.org/package/tar)
    that does (using its `pacman` tool). Using the existing Stack-supplied
    MSYS2, in PowerShell and located in a folder with write permissions (so the `.tar.xz` file can be created):

        > stack exec -- pacman -S tar
        > stack exec -- tar cJf msys2-YYYYMMDD-x86_64.tar.xz C:\msys64

4.  Create a new release tagged and named `msys2-YYYYMMDD` in the `master`
    branch of the [commercialhaskell/stackage-content](https://github.com/commericalhaskell/stackage-content)
    GitHub repository, uploading the tarball file(s) into that release.

5.  Changes need to be made to the [stackage-content/stack/stack-setup-2.yaml](https://github.com/commercialhaskell/stackage-content/blob/master/stack/stack-setup-2.yaml)
    file, to switch over to using the newly uploaded files. For example
    (extract):

        # For upgrade instructions, see: https://github.com/commercialhaskell/stack/blob/stable/doc/maintainers/msys.md
        msys2:
            windows32:
                version: "20200517"
                url: "https://github.com/fpco/stackage-content/releases/download/20200517/msys2-20200517-i686.tar.xz"
                content-length: 79049224
                sha256: 9152ddf50c6bacfae33c1436338235f8db4b10d73aaea63adefd96731fb0bceb
            windows64:
                version: "20220503"
                url: "https://github.com/commercialhaskell/stackage-content/releases/download/msys2-20220503/msys2-20220503-x86_64.tar.xz"
                content-length: 93835868
                sha256: c918f66e984f70add313ee3a5c5b101132cd93d5a3f8e3555e129e2d3dcb3718

    The `content-length:` key's value is the size of the file in bytes. It can
    be obtained from the `Length` field of the `dir` command. The `sha256:`
    key's value can be obtained from the command (in PowerShell):

        > (Get-FileHash msys2-YYYYMMDD-x86_64.tar.xz -Algorithm SHA256).Hash.ToLower()

    The `sha256:` key only accepts lowercase hash results as values.

6.  The changed `stack-setup-2.yaml` file should be tested locally. This can be
    done by:

    * temporarily disabling the existing local copy of MSYS2 by changing the
      name of the `msys2-YYYYMMDD.installed` file in the `stack path --programs` directory; and

    * executing the command:
      `stack setup --setup-info-yaml <path to local copy of stack-setup-2.yaml>`

    If all is well, the command should proceed to download the updated version
    of MSYS2 that has been specified.

7.  Raise a pull request on `commercialhaskell/stackage-contents` for the
    changes to the locally-tested `stack-setup-2.yaml` file.
