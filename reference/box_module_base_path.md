# Find `box::use` calls for local modules

Find [`box::use`](http://klmr.me/box/reference/use.md) calls for local
modules

## Usage

``` r
box_module_base_path()
```

## Value

An XPath

## Details

Base XPath to find [`box::use`](http://klmr.me/box/reference/use.md)
declarations that match the following pattern:
` box::use( path/to/module, ) `

## See also

[`box_separate_calls_linter()`](https://appsilon.github.io/box.linters/reference/box_separate_calls_linter.md)
