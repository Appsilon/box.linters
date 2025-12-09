# `box` library alphabetical module and function imports linter

Checks that module and function imports are sorted alphabetically.
Aliases are ignored. The sort check is on package/module names and
attached function names.

## Usage

``` r
box_alphabetical_calls_linter()
```

## Value

A custom linter function for use with `r-lib/lintr`.

## Details

Alphabetical sort order places upper-case/capital letters first: (A, B,
C, a, b, c).

For use in `rhino`, see the [Explanation: Rhino style
guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
to learn about the details.

## Examples

``` r
# will produce lints
lintr::lint(
  text = "box::use(packageB, packageA)",
  linters = box_alphabetical_calls_linter()
)
#> <text>:1:10: style: [box_alphabetical_calls_linter] Module and function imports must be sorted alphabetically.
#> box::use(packageB, packageA)
#>          ^~~~~~~~
#> <text>:1:20: style: [box_alphabetical_calls_linter] Module and function imports must be sorted alphabetically.
#> box::use(packageB, packageA)
#>                    ^~~~~~~~

lintr::lint(
  text = "box::use(package[functionB, functionA])",
  linters = box_alphabetical_calls_linter()
)
#> <text>:1:18: style: [box_alphabetical_calls_linter] Module and function imports must be sorted alphabetically.
#> box::use(package[functionB, functionA])
#>                  ^~~~~~~~~

lintr::lint(
  text = "box::use(bslib, config, dplyr, DT)",
  linters = box_alphabetical_calls_linter()
)
#> <text>:1:10: style: [box_alphabetical_calls_linter] Module and function imports must be sorted alphabetically.
#> box::use(bslib, config, dplyr, DT)
#>          ^~~~~
#> <text>:1:17: style: [box_alphabetical_calls_linter] Module and function imports must be sorted alphabetically.
#> box::use(bslib, config, dplyr, DT)
#>                 ^~~~~~
#> <text>:1:25: style: [box_alphabetical_calls_linter] Module and function imports must be sorted alphabetically.
#> box::use(bslib, config, dplyr, DT)
#>                         ^~~~~
#> <text>:1:32: style: [box_alphabetical_calls_linter] Module and function imports must be sorted alphabetically.
#> box::use(bslib, config, dplyr, DT)
#>                                ^~

lintr::lint(
  text = "box::use(path/to/B, path/to/A)",
  linters = box_alphabetical_calls_linter()
)
#> <text>:1:10: style: [box_alphabetical_calls_linter] Module and function imports must be sorted alphabetically.
#> box::use(path/to/B, path/to/A)
#>          ^~~~~~~~~
#> <text>:1:21: style: [box_alphabetical_calls_linter] Module and function imports must be sorted alphabetically.
#> box::use(path/to/B, path/to/A)
#>                     ^~~~~~~~~

lintr::lint(
  text = "box::use(path/to/A[functionB, functionA])",
  linters = box_alphabetical_calls_linter()
)
#> <text>:1:20: style: [box_alphabetical_calls_linter] Module and function imports must be sorted alphabetically.
#> box::use(path/to/A[functionB, functionA])
#>                    ^~~~~~~~~

lintr::lint(
  text = "box::use(path/to/A[alias = functionB, functionA])",
  linters = box_alphabetical_calls_linter()
)
#> <text>:1:28: style: [box_alphabetical_calls_linter] Module and function imports must be sorted alphabetically.
#> box::use(path/to/A[alias = functionB, functionA])
#>                            ^~~~~~~~~

# okay
lintr::lint(
  text = "box::use(packageA, packageB)",
  linters = box_alphabetical_calls_linter()
)
#> ℹ No lints found.

lintr::lint(
  text = "box::use(package[functionA, functionB])",
  linters = box_alphabetical_calls_linter()
)
#> ℹ No lints found.

lintr::lint(
  text = "box::use(DT, bslib, config, dplyr)",
  linters = box_alphabetical_calls_linter()
)
#> ℹ No lints found.

lintr::lint(
  text = "box::use(path/to/A, path/to/B)",
  linters = box_alphabetical_calls_linter()
)
#> ℹ No lints found.

lintr::lint(
  text = "box::use(path/to/A[functionA, functionB])",
  linters = box_alphabetical_calls_linter()
)
#> ℹ No lints found.

lintr::lint(
  text = "box::use(path/to/A[functionA, alias = functionB])",
  linters = box_alphabetical_calls_linter()
)
#> ℹ No lints found.
```
