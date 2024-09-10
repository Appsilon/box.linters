# box.linters 0.10.5

## Authors comment

This release contains fixes in unit tests affected by the recent 1.1.0 update of `treesitter.r`. This also address CRAN Package Check errors.

# box.linters 0.10.4

## Authors comment

This release contains fixes for two critical bugs that affect all users of the package. In light of this, we humbly appeal to the reviewer to consider this release. We understand that the last submission was very recent, and we apologize for submitting a publish request soon after the last.

The first bugfix is for a destructive bug of our styling function. If it encounters an R script file without any `box::use()` calls, it replaces all lines with `NA`.

The second is a fix for a bug that only exists on MacOS and R versions >= 4.3.0. Installing `box.linters` from CRAN behaves differently from doing a `devtools::install_local()`. We check for package dependencies (`treesitter` and `treesitter.r`). We then disable the `namespaced_function_calls()` linter if these dependencies are not available. This method to disable the linter fails when installing from CRAN on MacOS and R >= 4.3.0, and causes `lintr` to throw an error. It, however, works fine when installed from local.

# box.linters 0.10.3

## Authors comment

This release contains a bugfix that Rhino, our reverse dependency, requires. Because of that, we kindly request the reviewer to consider an exception to the CRAN publishing frequency policy.
