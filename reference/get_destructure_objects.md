# Get the output object names of the destructure (`rhino::%<-%`) assignment operator.

This is a naive search for the `SYMBOLS` within a
[`c()`](https://rdrr.io/r/base/c.html) as the first expression before
the `%<-%`. For example: `c(x, y, z) %<-% ...`.

## Usage

``` r
get_destructure_objects(xml)
```

## Arguments

- xml:

  An XML node list

## Value

a list of `xml_nodes` and `text`
