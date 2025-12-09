# Get a list of functions and data objects exported by a local `box` module

An implementation for `box` modules to provide similar functionality as
[`getNamespaceExports()`](https://rdrr.io/r/base/ns-reflect.html) for
libraries/packages.

## Usage

``` r
get_box_module_exports(declaration, alias = "", caller = globalenv())
```

## Arguments

- declaration:

  The mod or package call expression. See `box:::parse_spec()` source
  code for more details.

- alias:

  Mod or package-level alias as a character string. See
  `box:::parse_spec()` source code for more details. Default is fine for
  `box.linters` use.

- caller:

  The environment from which
  [`box::use`](http://klmr.me/box/reference/use.md) was invoked. Default
  is fine for `box.linters` use.

## Value

A list of exported functions and data objects.

## See also

[`getNamespaceExports()`](https://rdrr.io/r/base/ns-reflect.html)
