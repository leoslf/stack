<div class="hidden-warning"><a href="https://docs.haskellstack.org/"><img src="https://cdn.jsdelivr.net/gh/commercialhaskell/stack/doc/img/hidden-warning.svg"></a></div>

# User guide (advanced)

Some of Stack's features will not be needed regularly or by all users. This part
of the guide provides information about those features. Some of the features are
complex and separate pages are dedicated to them.

## The `stack build` command

The `stack build` command is introduced in the first part of
[Stack's user guide](GUIDE.md#the-stack-build-command). For further information
about the command, see the [build command](build_command.md) documentation.

## The `stack config` commands

The `stack config` commands provide assistence with accessing or modifying
Stack's configuration. See `stack config` for the available commands.

## The `stack config env` command

`stack config env` outputs a script that sets or unsets environment variables
for a Stack environment. Flags modify the script that is output:

* `--[no-]locals` (enabled by default) include/exclude local package information
* `--[no-]ghc-package-path` (enabled by default) set `GHC_PACKAGE_PATH`
  environment variable or not
* `--[no-]stack-exe` (enabled by default) set `STACK_EXE` environment variable
  or not
* `--[no-]locale-utf8` (disabled by default) set the `GHC_CHARENC`
  environment variable to `UTF-8` or not
* `--[no-]keep-ghc-rts` (disabled by default) keep/discard any `GHCRTS`
  environment variable

## The `stack config set` commands

The `stack config set` commands allow the values of keys in YAML configuration
files to be set. See `stack config set` for the available keys.

## The `stack config set install-ghc` command

`stack config set install-ghc true` or `false` sets the `install-ghc` key in a
YAML configuration file, accordingly. By default, the project-level
configuration file (`stack.yaml`) is altered. The `--global` flag specifies the
user-specific global configuration file (`config.yaml`).

## The `stack config set resolver` command

`stack config set resolver <snapshot>` sets the `resolver` key in the
project-level configuration file (`stack.yaml`).

A snapshot of `lts` or `nightly` will be translated into the most recent
available. A snapshot of `lts-19` will be translated into the most recent
available in the `lts-19` sequence.

Known bug:

* The command does not respect the presence of a `snapshot` key.

## The `stack config set system-ghc` command

`stack config set system-ghc true` or `false` sets the `system-ghc` key in a
YAML configuration file, accordingly. By default, the project-level
configuration file (`stack.yaml`) is altered. The `--global` flag specifies the
user-specific global configuration file (`config.yaml`).

## The `stack dot` command

If you'd like to get some insight into the dependency tree of your packages, you
can use the `stack dot` command and Graphviz. More information is available in
the [Dependency visualization](dependency_visualization.md) documentation.

## The `stack ide` commands

The `stack ide` commands provide information that may be of use in an
integrated development environment (IDE). See `stack ide` for the available
commands.

## The `stack ide packages` command

`stack ide packages` lists all available local packages that are loadable. By
default, its output is sent to the standard error channel. This can be changed
to the standard output channel with the `--stdout` flag.

By default, the output is the package name (without its version). This can be
changed to the full path to the package's Cabal file with the `--cabal-files`
flag.

## The `stack ide targets` command

`stack ide targets` lists all available Stack targets. By default, its output is
sent to the standard error channel. This can be changed to the standard output
channel with the `--stdout` flag.

For example, for the Stack project itself:

~~~
$ cd stack
$ stack ide targets
stack:lib
stack:exe:stack
stack:exe:stack-integration-test
stack:test:stack-test
~~~

## The `stack list` command

`stack list [PACKAGE]...` list the version of the specified package(s) in a
snapshot, or without an argument list all the snapshot's package versions. If no
resolver is specified the latest package version from Hackage is given.

## The `stack ls` commands

The `stack ls` commands list different types of information. See `stack ls` for
the available commands.

## The `stack ls dependencies` command

`stack ls dependencies` lists all of the packages and versions used for a
project.

## The `stack ls snapshots` command

`stack ls snapshots` will list all the local snapshots by default. You can also
view the remote snapshots using `stack ls snapshots remote`. It also supports
options for viewing only lts (`-l`) and nightly (`-n`) snapshots.

## The `stack ls stack-colors` command

The British English spelling is also accepted (`stack ls stack-colours`).

`stack ls stack-colors` will list all of Stack's output styles. A number of
different formats for the output are available, see
`stack ls stack-colors --help`.

The default is a full report, with the equivalent SGR instructions and an
example of the applied style. The latter can be disabled with flags `--no-sgr`
and `--no-example`.

The flag `--basic` specifies a more basic report, in the format that is accepted
by Stack's command line option `--stack-colors` and the YAML configuration key
`stack-colors`.

## The `stack ls tools` command

`stack ls tools` will list Stack's installed tools. On Unix-like operating
systems, they will be one or more versions of GHC. On Windows, they will include
MSYS2. For example, on Windows:

~~~
$ stack ls tools
ghc-9.4.1
ghc-9.2.4
ghc-9.0.2
msys2-20210604
~~~

The `--filter <tool_name>` option will filter the output by a tool name (e.g.
'ghc', 'ghc-git' or 'msys2'). The tool name is case sensitive. For example:

~~~
$ stack ls tools --filter ghc
ghc-9.4.1
ghc-9.2.4
ghc-9.0.2
~~~

## The `stack sdist` command

Hackage only accepts packages for uploading in a standard form, a compressed
archive ('tarball') in the format produced by Cabal's `sdist` action.

`stack sdist` generates an file for your package, in the format accepted by
Hackage for uploads. The command will report the location of the generated file.
The location can be changed from the default using the
`--tar-dir <path_to_directory>` option.

By default, the command will check the package for common mistakes. This can be
disabled with the flag `--ignore-check`.

Setting the flag `--test-tarball` will cause Stack to attempt to build the
resulting package archive, to test it.

## The `stack templates` command

`stack templates` provides information about how to find templates available for
`stack new`.

Stack provides multiple templates to start a new project from. You can specify
one of these templates following your project name in the `stack new` command:

    $ stack new my-rio-project rio
    Downloading template "rio" to create project "my-rio-project" in my-rio-project/ ...
    Looking for .cabal or package.yaml files to use to init the project.
    Using cabal packages:
    - my-rio-project/

    Selecting the best among 18 snapshots...

    * Matches ...

    Selected resolver: ...
    Initialising configuration using resolver: ...
    Total number of user packages considered: 1
    Writing configuration to file: my-rio-project/stack.yaml
    All done.
    <Stack root>\templates\rio.hsfiles:   10.10 KiB downloaded...

The default templates repository is
https://github.com/commercialhaskell/stack-templates. You can download templates
from a different Github user by prefixing the username and a slash:

    $ stack new my-yesod-project yesodweb/simple

Then template file `simple.hsfiles` would be downloaded from GitHub repository
`yesodweb/stack-templates`.

You can even download templates from a service other that GitHub, such as
[GitLab](https://gitlab.com) or [Bitbucket](https://bitbucket.com). For example:

    $ stack new my-project gitlab:user29/foo

Template file `foo.hsfiles` would be downloaded from GitLab, user account
`user29`, repository `stack-templates`.

If you need more flexibility, you can specify the full URL of the template:

    $ stack new my-project https://my-site.com/content/template9.hsfiles

(The `.hsfiles` extension is optional; it will be added if it's not specified.)

Alternatively you can use a local template by specifying the path:

    $ stack new project <path_to_template>/template.hsfiles

As a starting point for creating your own templates, you can use the
["simple" template](https://github.com/commercialhaskell/stack-templates/blob/master/simple.hsfiles).
The
[stack-templates repository](https://github.com/commercialhaskell/stack-templates#readme)
provides an introduction into creating templates.

## The `stack update` command

`stack update` will download the most recent set of packages from your package
indices (e.g. Hackage). Generally, Stack runs this for you automatically when
necessary, but it can be useful to do this manually sometimes.

## The `stack upgrade` command

`stack upgrade` will build a new version of Stack from source.
  * `--git` is a convenient way to get the most recent version from the `master`
     branch, for those testing and living on the bleeding edge.

## The `stack unpack` command

`stack unpack` does what you'd expect: downloads a tarball and unpacks it. It
accepts an optional `--to` argument to specify the destination directory.

## The `stack upload` command

`stack upload` uploads an sdist to Hackage. As of version
[1.1.0](https://docs.haskellstack.org/en/v1.1.0/ChangeLog/) Stack will also
attempt to GPG sign your packages as per
[our blog post](https://www.fpcomplete.com/blog/2016/05/stack-security-gnupg-keys).

* `--no-signature` disables signing of packages
* `--candidate` upload a
  [package candidate](http://hackage.haskell.org/upload#candidates)
* Hackage API key can be used instead of username and password. Usage
  example:

  ```bash
  HACKAGE_KEY=<api_key> stack upload .
    ```

* `username` and `password` can be read by environment

  ```bash
  export $HACKAGE_USERNAME="<username>"
  export $HACKAGE_PASSWORD="<password>"
  ```

## Docker integration

Stack is able to build your code inside a Docker image, which means even more
reproducibility to your builds, since you and the rest of your team will always
have the same system libraries.

For more information see the [Docker integration](docker_integration.md)
documentation.

## Nix integration

Stack provides an integration with [Nix](http://nixos.org/nix), providing you
with the same two benefits as the first Docker integration discussed above:

* more reproducible builds, since fixed versions of any system libraries and
  commands required to build the project are automatically built using Nix and
  managed locally per-project. These system packages never conflict with any
  existing versions of these libraries on your system. That they are managed
  locally to the project means that you don't need to alter your system in any
  way to build any odd project pulled from the Internet.
* implicit sharing of system packages between projects, so you don't have more
  copies on-disk than you need to.

When using the Nix integration, Stack downloads and builds Haskell dependencies
as usual, but resorts on Nix to provide non-Haskell dependencies that exist in
the Nixpkgs.

Both Docker and Nix are methods to *isolate* builds and thereby make them more
reproducible. They just differ in the means of achieving this isolation. Nix
provides slightly weaker isolation guarantees than Docker, but is more
lightweight and more portable (Linux and macOS mainly, but also Windows). For
more on Nix, its command-line interface and its package description language,
read the [Nix manual](http://nixos.org/nix/manual). But keep in mind that the
point of Stack's support is to obviate the need to write any Nix code in the
common case or even to learn how to use the Nix tools (they're called under the
hood).

For more information, see the [Nix-integration](nix_integration.md)
documentation.

## Continuous integration (CI)

### Travis with caching

This content has been moved to a dedicated
[Travis CI document](https://docs.haskellstack.org/en/stable/travis_ci/).

## Editor integration

### The `intero` project

For editor integration, Stack has a related project called
[intero](https://github.com/commercialhaskell/intero). It is particularly well
supported by Emacs, but some other editors have integration for it as well.

### Shell auto-completion

Love tab-completion of commands? You're not alone. If you're on bash, just run
the following (or add it to `.bashrc`):

    eval "$(stack --bash-completion-script stack)"

For more information and other shells, see the
[Shell auto-completion wiki page](https://docs.haskellstack.org/en/stable/shell_autocompletion)

## Debugging

To profile a component of the current project, simply pass the `--profile`
flag to `stack`. The `--profile` flag turns on the `--enable-library-profiling`
and `--enable-executable-profiling` Cabal options _and_ passes the `+RTS -p`
runtime options to any testsuites and benchmarks.

For example the following command will build the `my-tests` testsuite with
profiling options and create a `my-tests.prof` file in the current directory
as a result of the test run.

    $ stack test --profile my-tests

The `my-tests.prof` file now contains time and allocation info for the test run.

To create a profiling report for an executable, e.g. `my-exe`, you can run

     $ stack exec --profile -- my-exe +RTS -p

For more fine-grained control of compilation options there are the
`--library-profiling` and `--executable-profiling` flags which will turn on the
`--enable-library-profiling` and `--enable-executable-profiling` Cabal
options respectively. Custom GHC options can be passed in with
`--ghc-options "more options here"`.

To enable compilation with profiling options by default you can add the
following snippet to your `stack.yaml` or `~/.stack/config.yaml`:

```yaml
build:
  library-profiling: true
  executable-profiling: true
```

### Further reading

For more commands and uses, see the
[official GHC chapter on profiling](https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/profiling.html),
the [Haskell wiki](https://wiki.haskell.org/How_to_profile_a_Haskell_program),
and the
[chapter on profiling in Real World Haskell](http://book.realworldhaskell.org/read/profiling-and-optimization.html).

### Tracing

To generate a backtrace in case of exceptions during a test or benchmarks run,
use the `--trace` flag. Like `--profile` this compiles with profiling options,
but adds the `+RTS -xc` runtime option.

### Debugging symbols

Building with debugging symbols in the
[DWARF information](https://ghc.haskell.org/trac/ghc/wiki/DWARF) is supported by
Stack. This can be done by passing the flag `--ghc-options="-g"` and also to
override the default behaviour of stripping executables of debugging symbols by
passing either one of the following flags: `--no-strip`,
`--no-library-stripping` or `--no-executable-stripping`.

In Windows, GDB can be installed to debug an executable with
`stack exec -- pacman -S gdb`. Windows' Visual Studio compiler's debugging
format PDB is not supported at the moment. This might be possible by
[separating](https://stackoverflow.com/questions/866721/how-to-generate-gcc-debug-symbol-outside-the-build-target)
debugging symbols and
[converting](https://github.com/rainers/cv2pdb) their format. Or as an option
when
[using the LLVM backend](http://blog.llvm.org/2017/08/llvm-on-windows-now-supports-pdb-debug.html).
