<div class="hidden-warning"><a href="https://docs.haskellstack.org/"><img src="https://cdn.jsdelivr.net/gh/commercialhaskell/stack/doc/img/hidden-warning.svg"></a></div>

# Build command

## Overview

The primary command you use in Stack is `build`. This page describes the `build`
command's interface. The goal of the interface is to do the right thing for
simple input, and allow a lot of flexibility for more complicated goals.

See the introductory part of
[Stack's user guide](GUIDE.md#the-stack-build-command) for an introduction to
the command.

## Synonyms

One potential point of confusion is the synonym commands for `build`. These are
provided to match commonly expected command line interfaces, and to make common
workflows shorter. The important thing to note is that all of these are just
the `build` command in disguise. Each of these commands are called out as
synonyms in the `--help` output. These commands are:

* `stack test` is the same as `stack build --test`
* `stack bench` is the same as `stack build --bench`
* `stack haddock` is the same as `stack build --haddock`
* `stack install` is the same as `stack build --copy-bins`

The advantage of the synonym commands is that they're convenient and short. The
advantage of the options is that they compose. For example,
`stack build --test --copy-bins` will build libraries, executables, and test
suites, run the test suites, and then copy the executables to your local bin
path (more on this below).

## Components

Components are a subtle yet important point to how build operates under the
surface. Every cabal package is made up of one or more components. It can have
0 or 1 libraries, and then 0 or more of executable, test, and benchmark
components. Stack allows you to call out a specific component to be built, e.g.
`stack build mypackage:test:mytests` will build the `mytests` component of the
`mypackage` package. `mytests` must be a test suite component.

We'll get into the details of the target syntax for how to select components in
the next section. In this section, the important point is: whenever you target
a test suite or a benchmark, it's built __and also run__, unless you explicitly
disable running via `--no-run-tests` or `--no-run-benchmarks`. Case in point:
the previous command will in fact build the `mytests` test suite *and* run it,
even though you haven't used the `stack test` command or the `--test` option.
(We'll get to what exactly `--test` does below.)

This gives you a lot of flexibility in choosing what you want Stack to do. You
can run a single test component from a package, run a test component from one
package and a benchmark from another package, etc.

One final note on components: you can only control components for local
packages, not dependencies. With dependencies, Stack will *always* build the
library (if present) and all executables, and ignore test suites and
benchmarks. If you want more control over a package, you must add it to your
`packages` setting in your project-level configuration file (`stack.yaml`).

## Target syntax

In addition to a number of options (like the aforementioned `--test`),
`stack build` takes a list of zero or more *targets* to be built. There are a
number of different syntaxes supported for this list:

*   *package*, e.g. `stack build foobar`, is the most commonly used target. It
    will try to find the package in the following locations: local packages,
    extra dependencies, snapshots, and package index (e.g. Hackage). If it's
    found in the package index, then the latest version of that package from
    the index is implicitly added to your extra dependencies.

    This is where the `--test` and `--bench` flags come into play. If the
    package is a local package, then all of the test suite and benchmark
    components are selected to be built, respectively. In any event, the
    library and executable components are also selected to be built.

*   *package identifier*, e.g. `stack build foobar-1.2.3`, is usually used to
    include specific package versions from the index. If the version selected
    conflicts with an existing local package or extra dep, then stack fails
    with an error. Otherwise, this is the same as calling `stack build foobar`,
    except instead of using the latest version from the index, the version
    specified is used.

*   *component*. Instead of referring to an entire package and letting Stack
    decide which components to build, you select individual components from
    inside a package. This can be done for more fine-grained control over which
    test suites to run, or to have a faster compilation cycle. There are
    multiple ways to refer to a specific component (provided for convenience):

    * `packagename:comptype:compname` is the most explicit. The available
      comptypes are `exe`, `test`, and `bench`.
        * Side note: When any `exe` component is specified, all of the package's
          executable components will be built. This is due to limitations in all
          currently released versions of Cabal. See
          [issue#1046](https://github.com/commercialhaskell/stack/issues/1406)
    * `packagename:compname` allows you to leave off the component type, as
      that will (almost?) always be redundant with the component name. For
      example, `stack build mypackage:mytestsuite`.
    * `:compname` is a useful shortcut, saying "find the component in all of
      the local packages." This will result in an error if multiple packages
      have a component with the same name. To continue the above example,
      `stack build :mytestsuite`.

* *directory*, e.g. `stack build foo/bar`, will find all local packages that
  exist in the given directory hierarchy and then follow the same procedure as
  passing in package names as mentioned above. There's an important caveat
  here: if your directory name is parsed as one of the above target types, it
  will be treated as that. Explicitly starting your target with `./` can be a
  good way to avoid that, e.g. `stack build ./foo`

Finally: if you provide no targets (e.g., running `stack build`), Stack will
implicitly pass in all of your local packages. If you only want to target
packages in the current directory or deeper, you can pass in `.`, e.g.
`stack build .`.

To get a list of the available targets in your project, use `stack ide targets`.

## Controlling what gets built

Stack will automatically build the necessary dependencies. See the introductory
part of [Stack's user guide](GUIDE.md#the-stack-build-command) for information
about how these dependencies get specified.

In addition to specifying targets, you can also control what gets built, or
retained, with the following flags:

* `--haddock`, to build documentation.  This may cause a lot of packages to get
  re-built, so that the documentation links work.

* `--force-dirty`, to force rebuild of packages even when it doesn't seem
  necessary based on file dirtiness.

* `--reconfigure`, to force reconfiguration even when it doesn't seem necessary
  based on file dirtiness. This is sometimes useful with custom `Setup.hs`
  files, in particular when they depend on external data files.

* `--dry-run`, to build nothing and output information about the build plan.

* `--only-dependencies`, to skip building the targets.

* `--only-snapshot`, to only build snapshot dependencies, which are cached and
  shared with other projects.

* `--keep-going`, to continue building packages even after some build step
  fails. The packages which depend upon the failed build won't get built.

* `--keep-tmp-files`, to keep intermediate files and build directories that
  would otherwise be considered temporary and deleted. It may be useful to
  inspect these, if a build fails. By default, they are not kept.

* `--skip`, to skip building components of a local package. It allows
  you to skip test suites and benchmark without specifying other components
  (e.g. `stack test --skip long-test-suite` will run the tests without the
  `long-test-suite` test suite). Be aware that skipping executables won't work
  the first time the package is built due to
  [an issue in cabal](https://github.com/commercialhaskell/stack/issues/3229).
  This option can be specified multiple times to skip multiple components.

## Flags

There are a number of other flags accepted by `stack build`. Instead of listing
all of them, please use `stack build --help`. Some particularly convenient ones
worth mentioning here since they compose well with the rest of the build system
as described:

* `--file-watch` will rebuild your project every time a file changes, by default
  it will take into account all files belonging to the targets you specify,
  alternatively one could specify `--watch-all` which will make Stack watch
  any local files (from project packages or from local dependencies)
* `--exec "cmd [args]"` will run a command after a successful build

To come back to the composable approach described above, consider this final
example (which uses the [wai repository](https://github.com/yesodweb/wai/)):

```
stack build --file-watch --test --copy-bins --haddock wai-extra :warp warp:doctest --exec 'echo Yay, it worked!'
```

This command will start Stack up in file watch mode, waiting for files in your
project to change. When first starting, and each time a file changes, it will do
all of the following.

* Build the wai-extra package and its test suites
* Build the `warp` executable
* Build the warp package's doctest component (which, as you may guess, is a
  test site)
* Run all of the wai-extra package's test suite components and the doctest test
  suite component
* If all of that succeeds:
    * Copy generated executables to the local bin path
    * Run the command `echo Yay, it worked!`

## Build output

Starting with Stack 2.1, output of all packages being built scrolls by in a
streaming fashion. The output from each package built will be prefixed by the
package name, e.g. `mtl> Building ...`. This will include the output from
dependencies being built, not just targets.

To disable this behaviour, you can pass `--no-interleaved-output`, or add
`interleaved-output: false` to your `stack.yaml` file.  When disabled:

  * When building a single target package (e.g., `stack build` in a project
    with only one package, or `stack build package-name` in a multi-package
    project), the build output from GHC will be hidden for building all
    dependencies, and will be displayed for the one target package.

  * By default, when building multiple target packages, the output from these
    will end up in a log file instead of on the console unless it contains
    errors or warnings, to avoid problems of interleaved output and decrease
    console noise. If you would like to see this content instead, you can use
    the `--dump-logs` command line option, or add `dump-logs: all` to your
    YAML configuration file (`stack.yaml` or `config.yaml`).
