# Get objects called in current source file.

This ignores objects to the left of `<-`, `=`, `%<-%` as these are
assignments.

## Usage

``` r
get_object_calls(xml)
```

## Arguments

- xml:

  An XML node list

## Value

a list of `xml_nodes` and `text`.
