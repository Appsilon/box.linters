# `box` library-aware object usage linter

Checks that all function and data object calls made within a source file
are valid. There are three ways for functions and data object calls to
be come "valid". First is via base R packages. Second is via local
declaration/definition. The third is via
[`box::use()`](http://klmr.me/box/reference/use.md) attachment.

## Usage

``` r
box_usage_linter()
```

## Value

A custom linter function for use with `r-lib/lintr`.

## Details

For use in `rhino`, see the [Explanation: Rhino style
guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
to learn about the details.

## Examples

``` r
if (FALSE) { # \dontrun{
box::use(
  dplyr[`%>%`, filter, pull],
  stringr,
)

mpg <- mtcars %>%
  filter(mpg <= 10) %>%
  pull(mpg)

mpg <- mtcars %>%
  filter(mpg <= 10) %>%
  select(mpg)             # will lint

trimmed_string <- stringr$str_trim("  some string  ")
trimmed_string <- stringr$strtrim("  some string  ")     # will lint

existing_function <- function(x, y, z) {
  mean(c(x, y, z))
}

existing_function(1, 2, 3)
non_existing_function(1, 2, 3)     # will lint

average(1, 2, 3)       # will lint
} # }
```
