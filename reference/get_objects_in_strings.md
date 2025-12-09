# Get objects used in `glue` string templates

In `glue`, all text between `{` and `}` is considered code. Literal
braces are defined as `{{` and `}}`. Text between double braces are not
interpolated.

## Usage

``` r
get_objects_in_strings(xml)
```

## Arguments

- xml:

  An xml node list.

## Value

A character vector of object and function names found inside `glue`
string templates.
