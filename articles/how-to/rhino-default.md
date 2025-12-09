# Running lintr with box.linters on a rhino project

## Rhino (\>= 1.8.0)

Projects created with `rhino` version 1.8.0 and later come preconfigured
with a `.lintr` file.

``` yaml
linters:
  linters_with_defaults(
    defaults = box.linters::rhino_default_linters,
    line_length_linter = lintr::line_length_linter(100)
  )
```

## Using `box.linters` with an existing Rhino (\< 1.8.0) project

Refer to the [Rhino 1.8 Migration
Guide](https://appsilon.github.io/rhino/articles/how-to/migrate-1-8.html)
to upgrade to the latest version.

The following code is used to setup your `.lintr` config file.

``` r
box.linters::use_box_lintr(type = "rhino")
```

## Active `box`-compatible linters for `rhino`

All linter functions included in the `box.linters` package are activated
for Rhino projects. Please refer to the [Rhino style
guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
for more information.

## Linting a Rhino project

Use the helper function included in the `rhino` package to lint your
Rhino project.

``` r
rhino::lint_r()
```
