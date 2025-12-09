# Style the box::use() calls of source code text

Styles [`box::use()`](http://klmr.me/box/reference/use.md) calls.

- All packages are called under one
  [`box::use()`](http://klmr.me/box/reference/use.md).

- All modules are called under one
  [`box::use()`](http://klmr.me/box/reference/use.md).

- Package and module levels are re-formatted to multiple lines. One
  package per line.

- Packages and modules are sorted alphabetically, ignoring the aliases.

- Functions attached in a single line retain the single line format.

- Functions attached in multiple lines retain the multiple line format.

- Functions are sorted alphabetically, ignoring the aliases.

- A trailing comma is added to packages, modules, and functions.

## Usage

``` r
style_box_use_text(
  text,
  indent_spaces = 2,
  trailing_commas_func = FALSE,
  colored = getOption("styler.colored_print.vertical", default = FALSE),
  style = prettycode::default_style()
)
```

## Arguments

- text:

  Source code in text format

- indent_spaces:

  Number of spaces per indent level

- trailing_commas_func:

  A boolean to activate adding a trailing comma to the end of the lists
  of functions to attach.

- colored:

  Boolean. For syntax highlighting using {prettycode}

- style:

  A style from {prettycode}

## Examples

``` r
code <- "box::use(stringr[str_trim, str_pad], dplyr)"

style_box_use_text(code)
#> box::use(
#>   dplyr,
#>   stringr[str_pad, str_trim],
#> )
#> 
#> Warning: Changes were made. Please review the modifications made. Comments near
#> box::use() are moved to the top of the file.

code <- "box::use(stringr[
  str_trim,
  str_pad
],
shiny[...], # nolint
dplyr[alias = select, mutate], alias = tidyr
path/to/module)
"

style_box_use_text(code)
#> box::use(
#>   dplyr[mutate, alias = select],
#>   shiny[...], # nolint
#>   stringr[
#>     str_pad,
#>     str_trim
#>   ],
#> )
#> 
#> box::use(
#>   alias = tidyr
#> path/to/module,
#> )
#> 
#> Warning: Changes were made. Please review the modifications made. Comments near
#> box::use() are moved to the top of the file.

style_box_use_text(code, trailing_commas_func = TRUE)
#> box::use(
#>   dplyr[mutate, alias = select, ],
#>   shiny[...], # nolint
#>   stringr[
#>     str_pad,
#>     str_trim,
#>   ],
#> )
#> 
#> box::use(
#>   alias = tidyr
#> path/to/module,
#> )
#> 
#> Warning: Changes were made. Please review the modifications made. Comments near
#> box::use() are moved to the top of the file.
```
