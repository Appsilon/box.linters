# Style the box::use() calls of a source code

Style the box::use() calls of a source code

## Usage

``` r
style_box_use_file(filename, indent_spaces = 2, trailing_commas_func = FALSE)
```

## Arguments

- filename:

  A file path to style.

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
code <- "box::use(stringr[str_trim, str_pad], dplyr)"
file <- tempfile("style", fileext = ".R")
writeLines(code, file)

style_box_use_file(file)
#> Warning: `/tmp/RtmpUr32ic/style31b92a757ec6.R` was modified. Please review the
#> modifications made. Comments near box::use() are moved to the top of the file.
```
