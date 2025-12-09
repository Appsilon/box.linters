# Get declared/defined R6 class components

Get declared/defined R6 class components

## Usage

``` r
get_r6_components(xml, mode = c("public", "active", "private"))
```

## Arguments

- xml:

  XML representation of R source code.

- mode:

  Type of internal component (`public`, `active`, `private`).

## Value

List of XML nodes and corresponding text string values of the nodes
