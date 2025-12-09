# `box` library attached function exists and exported by called module linter

Checks that functions being attached exist and are exported by the local
module being called.

## Usage

``` r
box_mod_fun_exists_linter()
```

## Value

A custom linter function for use with `r-lib/lintr`

## Details

For use in `rhino`, see the [Explanation: Rhino style
guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
to learn about the details.

## Examples

``` r
if (FALSE) { # \dontrun{
# will produce lint
lintr::lint(
  text = "box::use(path/to/module_a[function_not_exists],)",
  linter = box_mod_fun_exists_linter()
)

# okay
lintr::lint(
  text = "box::use(path/to/module_a[function_exists],)",
  linter = box_mod_fun_exists_linter()
)
} # }
```
