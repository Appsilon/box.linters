# box.linters 0.10.6

* The `box_unused_attached_pkg_linter()` now correctly recognizes list elements accessed via `$` as valid uses of an attached package. (#148)
* `box_unused_attached_mod_linter()` now handles errors gracefully when a module does not exist. (#108)
* Now respects the `box` convention that "nothing exported means export all". (#166)
* Introduces support for destructure operator `%<-%`
* Now handles non-syntactic names for object names, function definitions, and module references (#147, #151)
* Resolved a false-positive lint triggered by calling a function argument via list notation. (#131)
* Alphabetical sorting now uses the `radix` method, ensuring consistent behavior across systems. (#168)
* Fixed a bug in styling that caused issues when the source code contained no empty lines. (#134)

# box.linters 0.10.5

* Fix for `treesitter.r` update to version 1.1.0. Change in how treesitter returns the start row of the program node. (#143)

# box.linters 0.10.4

* Fix critical bug of style_box_use_*() converting all lines to NA if there is no `box::use()` call found.
* R version (>= 4.3.0) compatibility fix for MacOS.

# box.linters 0.10.3

* Implement `exclude_files` in `style_box_use_dir()` to exclude files from styling.

# box.linters 0.10.2

* Implemented linter tags file compatible with `lintr::available_linters()` and
`lintr::available_tags()` functions.

# box.linters 0.10.1

* `box_unused_att_pkg_fun_linter()` allows functions passed into other functions by name without `()`.
* `package::function()` check is exclusive to `namespace_function_calls()`.
* Move `treesitter` dependencies to Suggests because of the R >= 4.3.0 requirement. Functions that depend on `treesitter` now check if it is installed and handle the absence gracefully.

# box.linters 0.10.0

* Add checks for `package::function()` calls. Allow `box::*()` by default.
* [Bug fix] Allow relative box module paths (#110)
* Less verbose `box_alphabetical_calls_linter()`. Reports only the first out-of-place function.
* Added styling functions for `box::use()` calls.
* [Bug fix] Allow multiple `box::use(pkg)` calls (#111)

# box.linters 0.9.1

* Handle `box` recommended method of testing private methods.
* Added handler for `glue` string templates.
* Added box_mod_fun_exists_linter() to default linters
* [bug fix] box_trailing_commas_linter() now properly handles a #nolint for other linters
* [bug fix] `box_unused_att_pkg_fun_linter()` had issues with lists of functions. Linter function
  now drops the nested function name and retains the list name (`list_name$function_name()`) when
  performing the check.
* [bug fix] `get_attached_modules()` was not properly finding whole modules attached with short `path/module` declarations

# box.linters 0.9.0

* Handle box-exported functions and objects
* Handle functional programming, cloned functions, curried functions
* R6 class awareness
* Very basic handling of objects inside function definitions
  * Data objects inside function definitions should not lint
  * Functions passed as arguments and used inside function definitions should not lint
  * List data objects passed into functions should not lint
  * Functions in lists should not lint. _Same `x$y()` pattern as `package$function()`_
  * ... in function signature should not lint.
* Test for dplyr column names
* Rationalize file names
* Linting on `box::use(local_module)` patterns
  * All box-attached modules with or without aliases should be used
  * All box-attached module functions with or without aliases should be used
  * Catches non-existing `module[function]` or `module[data_object]` imports
  * Catches non-existing `module$function()` or `module$data_object` calls
  * Catches functions that are not box-imported
* Linting on `box::use(package)` patterns
  * All box-attached packages with or without aliases should be used
  * All box-attached functions with or without aliases should be used
  * Catches non-existing `package[function]` imports
  * Catches non-existing `package$function()` calls
  * Catches functions that are not box-imported
* Local source linting
  * Catches functions that are not defined
  * All defined functions should be used
  * Handles internal R6 class object calls
* Added `rhino_default_linters`
* Migrated existing box linters from rhino 1.7.0
  * Import calls should be alphabetical
  * Maximum quantity of function imports
  * Separate packages and modules
  * Enforce trailing commas
  * Block universal [...] imports
* Added a `NEWS.md` file to track changes to the package.

# box.linters 0.0.0

* Create box.linters
