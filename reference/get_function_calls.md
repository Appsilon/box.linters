# Get functions called in current source file

Will not return `package::function()` form.
[`namespaced_function_calls()`](https://appsilon.github.io/box.linters/reference/namespaced_function_calls.md)
is responsible for checking `package_function()` use.

## Usage

``` r
get_function_calls(xml)
```

## Arguments

- xml:

  An XML node list

## Value

A list of `xml_nodes` and `text`.
