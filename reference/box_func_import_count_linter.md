# `box` library function import count linter

Checks that function imports do not exceed the defined `max`.

## Usage

``` r
box_func_import_count_linter(max = 8L)
```

## Arguments

- max:

  Maximum function imports allowed between `[` and `]`. Defaults to 8.

## Value

A custom linter function for use with `r-lib/lintr`.

## Details

For use in `rhino`, see the [Explanation: Rhino style
guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
to learn about the details.

## Examples

``` r
# will produce lints
lintr::lint(
  text = "box::use(package[one, two, three, four, five, six, seven, eight, nine])",
  linters = box_func_import_count_linter()
)
#> <text>:1:10: style: [box_func_import_count_linter] Limit the function imports to a max of 8.
#> box::use(package[one, two, three, four, five, six, seven, eight, nine])
#>          ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

lintr::lint(
  text = "box::use(package[one, two, three, four])",
  linters = box_func_import_count_linter(3)
)
#> <text>:1:10: style: [box_func_import_count_linter] Limit the function imports to a max of 3.
#> box::use(package[one, two, three, four])
#>          ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# okay
lintr::lint(
  text = "box::use(package[one, two, three, four, five])",
  linters = box_func_import_count_linter()
)
#> ℹ No lints found.

lintr::lint(
  text = "box::use(package[one, two, three])",
  linters = box_func_import_count_linter(3)
)
#> ℹ No lints found.
```
