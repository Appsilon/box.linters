# Get objects names in function signatures from all functions in current source file

This is a brute-force extraction of `SYMBOL_FORMALS` and is not
scope-aware.

## Usage

``` r
get_function_signature_objs(xml)
```

## Arguments

- xml:

  An XML node list

## Value

a list of `xml_nodes` and `text`.
