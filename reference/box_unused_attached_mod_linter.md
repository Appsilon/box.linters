# `box` library unused attached module linter

Checks that all attached modules are used within the source file. This
also covers modules attached using the `...`.

## Usage

``` r
box_unused_attached_mod_linter()
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
  path/to/module
)
"

lintr::lint(code, linters = box_unused_attached_mod_linter())

code <- "
box::use(
  alias = path/to/module
)
"

lintr::lint(code, linters = box_unused_attached_mod_linter())

code <- "
box::use(
  path/to/module[...]
)
"

lintr::lint(code, linters = box_unused_attached_mod_linter())

# okay
code <- "
box::use(
  path/to/module
)

module$some_function()
"

lintr::lint(code, linters = box_unused_attached_mod_linter())

code <- "
box::use(
  alias = path/to/module
)

alias$some_function()
"

lintr::lint(code, linters = box_unused_attached_mod_linter())

code <- "
box::use(
  path/to/module[...]     # module exports some_function()
)

some_function()
"

lintr::lint(code, linters = box_unused_attached_mod_linter())
} # }
```
