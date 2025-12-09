# `box` library unused attached package linter

Checks that all attached packages are used within the source file. This
also covers packages attached using the `...`.

## Usage

``` r
box_unused_attached_pkg_linter()
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
  stringr
)
"

lintr::lint(text = code, linters = box_unused_attached_pkg_linter())
#> <text>:3:3: warning: [box_unused_attached_pkg_linter] Attached package unused.
#>   stringr
#>   ^~~~~~~

code <- "
box::use(
  alias = stringr
)
"

lintr::lint(text = code, linters = box_unused_attached_pkg_linter())
#> <text>:3:11: warning: [box_unused_attached_pkg_linter] Attached package unused.
#>   alias = stringr
#>           ^~~~~~~

code <- "
box::use(
  stringr[...]
)
"

lintr::lint(text = code, linters = box_unused_attached_pkg_linter())
#> <text>:3:3: warning: [box_unused_attached_pkg_linter] Three-dots attached package unused.
#>   stringr[...]
#>   ^~~~~~~

# okay
code <- "
box::use(
  stringr
)

stringr$str_pad()
"

lintr::lint(text = code, linters = box_unused_attached_pkg_linter())
#> ℹ No lints found.

code <- "
box::use(
  alias = stringr
)

alias$str_pad()
"

lintr::lint(text = code, linters = box_unused_attached_pkg_linter())
#> ℹ No lints found.

code <- "
box::use(
  stringr[...]
)

str_pad()
"

lintr::lint(text = code, linters = box_unused_attached_pkg_linter())
#> ℹ No lints found.
```
