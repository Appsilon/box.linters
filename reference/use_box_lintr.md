# Use lintr with box.linters in your project

Create a minimal lintr config file with `box` modules support as a
starting point for customization

## Usage

``` r
use_box_lintr(path = ".", type = c("basic_box", "rhino"))
```

## Arguments

- path:

  Path to project root where a `.lintr` file should be created. If the
  `.lintr` file already exists, an error will be thrown.

- type:

  The kind of configuration to create

  - `basic_box` creates a minimal lintr config based on the `tidyverse`
    configuration of `lintr`. This starts with
    [`lintr::linters_with_defaults()`](https://lintr.r-lib.org/reference/linters_with_defaults.html)
    and is customized for `box` module compatibility

  - `rhino` creates a lintr config based on the [Rhino style
    guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)

## Value

Path to the generated configuration, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
  # use default box-compatible set of linters
  box.linters::use_box_lintr()

  # use `rhino` set of linters
  box.linters::use_box_lintr(type = "rhino")
} # }
```
