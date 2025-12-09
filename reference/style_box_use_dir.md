# Style the box::use() calls for a directory

Style the box::use() calls for a directory

## Usage

``` r
style_box_use_dir(
  path = ".",
  recursive = TRUE,
  exclude_files = c(),
  exclude_dirs = c("packrat", "renv"),
  indent_spaces = 2,
  trailing_commas_func = FALSE
)
```

## Arguments

- path:

  Path to a directory with files to style.

- recursive:

  A logical value indicating whether or not files in sub-directories

- exclude_files:

  A character vector of regular expressions to exclude files (not paths)
  from styling.

- exclude_dirs:

  A character vector of directories to exclude.

- indent_spaces:

  An integer scalar indicating tab width in units of spaces

- trailing_commas_func:

  A boolean to activate adding a trailing comma to the end of the lists
  of functions to attach.

## Details

Refer to
[`style_box_use_text()`](https://appsilon.github.io/box.linters/reference/style_box_use_text.md)
for styling details.

## Examples

``` r
if (FALSE) { # \dontrun{
style_box_use_dir("path/to/dir")

# to exclude `__init__.R` files from styling
style_box_use_dir("path/to/dir", exclude_files = c("__init__\\.R"))
} # }
```
