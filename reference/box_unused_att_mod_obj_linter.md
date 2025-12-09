# `box` library unused attached module object linter

Checks that all attached module functions and data objects are used
within the source file.

## Usage

``` r
box_unused_att_mod_obj_linter()
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
# will produce lints
code <- "
box::use(
  path/to/module[some_function, some_object],
)
"

lintr::lint(text = code, linters = box_unused_att_mod_obj_linter())

code <- "
box::use(
  path/to/module[alias_func = some_function, alias_obj = some_object],
)
"

lintr::lint(text = code, linters = box_unused_att_mod_obj_linter())

# okay
code <- "
box::use(
  path/to/module[some_function, some_object],
)

x <- sum(some_object)
some_function()
"

lintr::lint(text = code, linters = box_unused_att_mod_obj_linter())

code <- "
box::use(
  path/to/module[alias_func = some_function, alias_obj = some_object],
)

x <- sum(alias_obj)
alias_func()
"

lintr::lint(text = code, linters = box_unused_att_mod_obj_linter())
} # }
```
