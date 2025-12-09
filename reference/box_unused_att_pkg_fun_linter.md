# `box` library unused attached package function linter

Checks that all attached package functions are used within the source
file.

## Usage

``` r
box_unused_att_pkg_fun_linter()
```

## Value

A custom linter function for use with `r-lib/lintr`.

## Details

For use in `rhino`, see the [Explanation: Rhino style
guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
to learn about the details.

## Examples

``` r
# will produce lints
code <- "
box::use(
  stringr[str_pad],
)
"

lintr::lint(text = code, linters = box_unused_att_pkg_fun_linter())
#> <text>:3:11: warning: [box_unused_att_pkg_fun_linter] Imported function unused.
#>   stringr[str_pad],
#>           ^~~~~~~

code <- "
box::use(
  stringr[alias_func = str_pad],
)
"

lintr::lint(text = code, linters = box_unused_att_pkg_fun_linter())
#> <text>:3:24: warning: [box_unused_att_pkg_fun_linter] Imported function unused.
#>   stringr[alias_func = str_pad],
#>                        ^~~~~~~

# okay
code <- "
box::use(
  stringr[str_pad],
)

str_pad()
"

lintr::lint(text = code, linters = box_unused_att_pkg_fun_linter())
#> ℹ No lints found.

code <- "
box::use(
  stringr[alias_func = str_pad],
)

alias_func()
"

lintr::lint(text = code, linters = box_unused_att_pkg_fun_linter())
#> ℹ No lints found.
```
