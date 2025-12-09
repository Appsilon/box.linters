# Changelog

## box.linters 0.10.6

CRAN release: 2025-06-26

- The
  [`box_unused_attached_pkg_linter()`](https://appsilon.github.io/box.linters/reference/box_unused_attached_pkg_linter.md)
  now correctly recognizes list elements accessed via `$` as valid uses
  of an attached package.
  ([\#148](https://github.com/Appsilon/box.linters/issues/148))
- [`box_unused_attached_mod_linter()`](https://appsilon.github.io/box.linters/reference/box_unused_attached_mod_linter.md)
  now handles errors gracefully when a module does not exist.
  ([\#108](https://github.com/Appsilon/box.linters/issues/108))
- Now respects the `box` convention that “nothing exported means export
  all”. ([\#166](https://github.com/Appsilon/box.linters/issues/166))
- Introduces support for destructure operator `%<-%`
- Now handles non-syntactic names for object names, function
  definitions, and module references
  ([\#147](https://github.com/Appsilon/box.linters/issues/147),
  [\#151](https://github.com/Appsilon/box.linters/issues/151))
- Resolved a false-positive lint triggered by calling a function
  argument via list notation.
  ([\#131](https://github.com/Appsilon/box.linters/issues/131))
- Alphabetical sorting now uses the `radix` method, ensuring consistent
  behavior across systems.
  ([\#168](https://github.com/Appsilon/box.linters/issues/168))
- Fixed a bug in styling that caused issues when the source code
  contained no empty lines.
  ([\#134](https://github.com/Appsilon/box.linters/issues/134))

## box.linters 0.10.5

CRAN release: 2024-09-10

- Fix for `treesitter.r` update to version 1.1.0. Change in how
  treesitter returns the start row of the program node.
  ([\#143](https://github.com/Appsilon/box.linters/issues/143))

## box.linters 0.10.4

CRAN release: 2024-09-03

- Fix critical bug of style_box_use\_\*() converting all lines to NA if
  there is no [`box::use()`](http://klmr.me/box/reference/use.md) call
  found.
- R version (\>= 4.3.0) compatibility fix for MacOS.

## box.linters 0.10.3

CRAN release: 2024-08-21

- Implement `exclude_files` in
  [`style_box_use_dir()`](https://appsilon.github.io/box.linters/reference/style_box_use_dir.md)
  to exclude files from styling.

## box.linters 0.10.2

CRAN release: 2024-08-20

- Implemented linter tags file compatible with
  [`lintr::available_linters()`](https://lintr.r-lib.org/reference/available_linters.html)
  and
  [`lintr::available_tags()`](https://lintr.r-lib.org/reference/available_linters.html)
  functions.

## box.linters 0.10.1

- [`box_unused_att_pkg_fun_linter()`](https://appsilon.github.io/box.linters/reference/box_unused_att_pkg_fun_linter.md)
  allows functions passed into other functions by name without `()`.
- `package::function()` check is exclusive to
  `namespace_function_calls()`.
- Move `treesitter` dependencies to Suggests because of the R \>= 4.3.0
  requirement. Functions that depend on `treesitter` now check if it is
  installed and handle the absence gracefully.

## box.linters 0.10.0

CRAN release: 2024-07-15

- Add checks for `package::function()` calls. Allow `box::*()` by
  default.
- \[Bug fix\] Allow relative box module paths
  ([\#110](https://github.com/Appsilon/box.linters/issues/110))
- Less verbose
  [`box_alphabetical_calls_linter()`](https://appsilon.github.io/box.linters/reference/box_alphabetical_calls_linter.md).
  Reports only the first out-of-place function.
- Added styling functions for
  [`box::use()`](http://klmr.me/box/reference/use.md) calls.
- \[Bug fix\] Allow multiple `box::use(pkg)` calls
  ([\#111](https://github.com/Appsilon/box.linters/issues/111))

## box.linters 0.9.1

CRAN release: 2024-06-04

- Handle `box` recommended method of testing private methods.
- Added handler for `glue` string templates.
- Added box_mod_fun_exists_linter() to default linters
- \[bug fix\] box_trailing_commas_linter() now properly handles a
  \#nolint for other linters
- \[bug fix\]
  [`box_unused_att_pkg_fun_linter()`](https://appsilon.github.io/box.linters/reference/box_unused_att_pkg_fun_linter.md)
  had issues with lists of functions. Linter function now drops the
  nested function name and retains the list name
  (`list_name$function_name()`) when performing the check.
- \[bug fix\]
  [`get_attached_modules()`](https://appsilon.github.io/box.linters/reference/get_attached_modules.md)
  was not properly finding whole modules attached with short
  `path/module` declarations

## box.linters 0.9.0

CRAN release: 2024-05-25

- Handle box-exported functions and objects
- Handle functional programming, cloned functions, curried functions
- R6 class awareness
- Very basic handling of objects inside function definitions
  - Data objects inside function definitions should not lint
  - Functions passed as arguments and used inside function definitions
    should not lint
  - List data objects passed into functions should not lint
  - Functions in lists should not lint. *Same `x$y()` pattern as
    `package$function()`*
  - … in function signature should not lint.
- Test for dplyr column names
- Rationalize file names
- Linting on `box::use(local_module)` patterns
  - All box-attached modules with or without aliases should be used
  - All box-attached module functions with or without aliases should be
    used
  - Catches non-existing `module[function]` or `module[data_object]`
    imports
  - Catches non-existing `module$function()` or `module$data_object`
    calls
  - Catches functions that are not box-imported
- Linting on `box::use(package)` patterns
  - All box-attached packages with or without aliases should be used
  - All box-attached functions with or without aliases should be used
  - Catches non-existing `package[function]` imports
  - Catches non-existing `package$function()` calls
  - Catches functions that are not box-imported
- Local source linting
  - Catches functions that are not defined
  - All defined functions should be used
  - Handles internal R6 class object calls
- Added `rhino_default_linters`
- Migrated existing box linters from rhino 1.7.0
  - Import calls should be alphabetical
  - Maximum quantity of function imports
  - Separate packages and modules
  - Enforce trailing commas
  - Block universal \[…\] imports
- Added a `NEWS.md` file to track changes to the package.

## box.linters 0.0.0

- Create box.linters
