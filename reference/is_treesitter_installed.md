# Check if treesitter and dependencies are installed

Treesitter required R \>= 4.3.0. Treesitter is required by a few
`{box.linters}` functions.

## Usage

``` r
is_treesitter_installed()
```

## Value

Logical TRUE/FALSE if the `treesitter` dependencies exist.

## Examples

``` r
if (FALSE) { # \dontrun{

# Bare environment

is_treesitter_installed()
#> [1] FALSE

install.packages(c("treesitter", "treesitter.r"))
is_treesitter_installed()
#> [1] TRUE
} # }
```
