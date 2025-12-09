# `box` library separate packages and module imports linter

Checks that packages and modules are imported in separate
[`box::use()`](http://klmr.me/box/reference/use.md) statements.

## Usage

``` r
box_separate_calls_linter()
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
  text = "box::use(package, path/to/file)",
  linters = box_separate_calls_linter()
)
#> <text>:1:1: style: [box_separate_calls_linter] Separate packages and modules in their respective box::use() calls.
#> box::use(package, path/to/file)
#> ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

lintr::lint(
  text = "box::use(path/to/file, package)",
  linters = box_separate_calls_linter()
)
#> <text>:1:1: style: [box_separate_calls_linter] Separate packages and modules in their respective box::use() calls.
#> box::use(path/to/file, package)
#> ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# okay
lintr::lint(
  text = "box::use(package1, package2)
    box::use(path/to/file1, path/to/file2)",
  linters = box_separate_calls_linter()
)
#> ℹ No lints found.
```
