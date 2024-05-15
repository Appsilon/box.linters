# box.linters development version

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
