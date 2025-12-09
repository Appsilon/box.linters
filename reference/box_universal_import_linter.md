# `box` library universal import linter

Checks that all function imports are explicit. `package[...]` is not
used.

## Usage

``` r
box_universal_import_linter()
```

## Value

A custom linter function for use with `r-lib/lintr`

## Details

For use in `rhino`, see the [Explanation: Rhino style
guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
to learn about the details.

## Examples

``` r
# will produce lints
lintr::lint(
  text = "box::use(base[...])",
  linters = box_universal_import_linter()
)
#> <text>:1:15: style: [box_universal_import_linter] Explicitly declare imports rather than universally import with `...`.
#> box::use(base[...])
#>               ^~~

lintr::lint(
  text = "box::use(path/to/file[...])",
  linters = box_universal_import_linter()
)
#> <text>:1:23: style: [box_universal_import_linter] Explicitly declare imports rather than universally import with `...`.
#> box::use(path/to/file[...])
#>                       ^~~

# okay
lintr::lint(
  text = "box::use(base[print])",
  linters = box_universal_import_linter()
)
#> ℹ No lints found.

lintr::lint(
  text = "box::use(path/to/file[do_something])",
  linters = box_universal_import_linter()
)
#> ℹ No lints found.
```
