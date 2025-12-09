# Find `box::use` calls for R libraries/packages

Find [`box::use`](http://klmr.me/box/reference/use.md) calls for R
libraries/packages

## Usage

``` r
box_package_base_path()
```

## Value

An XPath

## Details

Base XPath to find [`box::use`](http://klmr.me/box/reference/use.md)
declarations that match the following pattern: ` box::use( package, ) `

## See also

[`box_separate_calls_linter()`](https://appsilon.github.io/box.linters/reference/box_separate_calls_linter.md)
