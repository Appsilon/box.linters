# Custom Configuration

## Activating linters

Unlike
[`rhino_default_linters`](https://appsilon.github.io/box.linters/reference/rhino_default_linters.html),
[`box_default_linters`](https://appsilon.github.io/box.linters/reference/box_default_linters.html)
comes with only a subset of the linters provided in `box.linters`.
Inactive linters can be added as needed.

The following activates
[`box_func_import_count_linter()`](https://appsilon.github.io/box.linters/reference/box_func_import_count_linter.md)
for `box_default_linters`

``` yaml
linters:
  linters_with_defaults(
    defaults = box.linters::box_default_linters,
    box_func_import_count_linter = box.linters::box_func_import_count_linter()
  )
encoding: "UTF-8"
```

## Disabling linters

Specific linters can be disabled by setting the appropriate linter name
to `NULL`:

The following disables
[`box_func_import_count_linter()`](https://appsilon.github.io/box.linters/reference/box_func_import_count_linter.md):

``` yaml
linters:
  linters_with_defaults(
    defaults = box.linters::rhino_default_linters,
    box_func_import_count_linter = NULL
  )
```

``` yaml
linters:
  linters_with_defaults(
    defaults = box.linters::box_default_linters,
    box_pkg_fun_exists_linter = NULL
  )
```

## Customizable linters

A few of the linters provided can be configured such as
[`box_func_import_count_linter()`](https://appsilon.github.io/box.linters/reference/box_func_import_count_linter.html).

The following changes the maximum quantity of attached functions from 8
to 12:

``` yaml
linters:
  linters_with_defaults(
    defaults = box.linters::rhino_default_linters,
    box_func_import_count_linter = box.linters::box_func_import_count_linter(max = 12)
  )
```

The [default
linters](https://lintr.r-lib.org/reference/linters_with_defaults.html)
provided by `lintr` can also be configured:

``` yaml
linters:
  linters_with_defaults(
    defaults = box.linters::box_default_linters,
    line_length_linter = lintr::line_length_linter(100)
  )
```

## More information

For more detailed information on customizing linters, please proceed to
the `lintr` documentation on [Configuring
linters](https://lintr.r-lib.org/articles/lintr.html#configuring-linters)
