# `box` library attached function exists and exported by package linter

Checks that functions being attached exist and are exported by the
package/library being called.

## Usage

``` r
box_pkg_fun_exists_linter()
```

## Value

A custom linter function for use with `r-lib/lintr`

## Details

For use in `rhino`, see the [Explanation: Rhino style
guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
to learn about the details.

## Examples

``` r
# will produce lint
lintr::lint(
  text = "box::use(stringr[function_not_exists],)",
  linter = box_pkg_fun_exists_linter()
)
#> <text>:1:18: warning: [box_pkg_fun_exists_linter] Function not exported by package.
#> box::use(stringr[function_not_exists],)
#>                  ^~~~~~~~~~~~~~~~~~~

# okay
lintr::lint(
  text = "box::use(stringr[str_pad],)",
  linter = box_pkg_fun_exists_linter()
)
#> ℹ No lints found.
```
