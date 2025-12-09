# Unused declared function and data objects linter

Checks that all defined/declared functions and data objects are used
within the source file. Functions and data objects that are marked with
`@export` are ignored.

## Usage

``` r
unused_declared_object_linter()
```

## Value

A custom linter function for use with `r-lib/lintr`.

## Details

For use in `rhino`, see the [Explanation: Rhino style
guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
to learn about the details.

## Examples

``` r
# will produce lint
code <- "
#' @export
public_function <- function() {

}

private_function <- function() {

}

local_data <- \"A\"
"

lintr::lint(text = code, linters = unused_declared_object_linter())
#> <text>:7:1: warning: [unused_declared_object_linter] Declared function/object unused.
#> private_function <- function() {
#> ^~~~~~~~~~~~~~~~
#> <text>:11:1: warning: [unused_declared_object_linter] Declared function/object unused.
#> local_data <- "A"
#> ^~~~~~~~~~

# okay
code <- "
#' @export
public_function <- function(local_data) {
  private_function(local_data)
}

private_function <- function() {

}

local_data <- \"A\"
"

lintr::lint(text = code, linters = unused_declared_object_linter())
#> ℹ No lints found.
```
