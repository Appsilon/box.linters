# Running lintr with box.linters on a project

## Setup box.linters

The function
[`use_box_lintr()`](https://appsilon.github.io/box.linters/reference/use_box_lintr.html)
creates a minimal `.lintr` config file.

``` r
box.linters::use_box_lintr()
```

This would create a `.lintr` file in your project root:

``` yaml
linters:
  linters_with_defaults(
    defaults = box.linters::box_default_linters
  )
encoding: "UTF-8"
```

## Active `box`-compatible linters

Because
[`lintr::object_usage_linter()`](https://lintr.r-lib.org/reference/object_usage_linter.html)
is not compatible with `box`, the following linter functions are
provided in place of `object_usage_linter()`. Examples of what are
considered lint are included in the function reference pages.

- [`box_pkg_fun_exists_linter()`](https://appsilon.github.io/box.linters/reference/box_pkg_fun_exists_linter.html)
- [`box_unused_att_mod_obj_linter()`](https://appsilon.github.io/box.linters/reference/box_unused_att_mod_obj_linter.html)
- [`box_unused_att_pkg_fun_linter()`](https://appsilon.github.io/box.linters/reference/box_unused_att_pkg_fun_linter.html)
- [`box_unused_attached_mod_linter()`](https://appsilon.github.io/box.linters/reference/box_unused_attached_mod_linter.html)
- [`box_unused_attached_pkg_linter()`](https://appsilon.github.io/box.linters/reference/box_unused_attached_pkg_linter.html)
- [`box_usage_linter()`](https://appsilon.github.io/box.linters/reference/box_usage_linter.html)
- [`r6_usage_linter()`](https://appsilon.github.io/box.linters/reference/r6_usage_linter.html)
- [`unused_declared_object_linter()`](https://appsilon.github.io/box.linters/reference/unused_declared_object_linter.html)

## Run lintr

Use `lintr` functions to lint a file or a directory.

``` r
# Lint a file
lintr::lint("some_file.R")

# Lint a directory
lintr::lint_dir("some_dir")
```

## Example

``` r
box::use(
  stringr[function_not_exists],
  dplyr[`%>%`, filter, select, mutate],
  shiny
)

unused_function <- function() {
  1
}

unused_object <- mtcars %>%
  select(mpg, cyl) %>%
  filter(mpg >= 10) %>%
  undefined_function()
```

Lint results

    <text>:2:11: warning: [box_pkg_fun_exists_linter] Function not exported by package.
      stringr[function_not_exists],
              ^~~~~~~~~~~~~~~~~~~
    <text>:2:11: warning: [box_unused_attached_pkg_fun_linter] Imported function unused.
      stringr[function_not_exists],
              ^~~~~~~~~~~~~~~~~~~
    <text>:3:32: warning: [box_unused_attached_pkg_fun_linter] Imported function unused.
      dplyr[`%>%`, filter, select, mutate],
                                   ^~~~~~
    <text>:4:3: warning: [box_unused_att_pkg_linter] Attached package unused.
      shiny
      ^~~~~
    <text>:7:1: warning: [unused_declared_object_linter] Declared function/object unused.
    unused_function <- function() {
    ^~~~~~~~~~~~~~~
    <text>:11:1: warning: [unused_declared_object_linter] Declared function/object unused.
    unused_object <- mtcars %>%
    ^~~~~~~~~~~~~
    <text>:14:3: warning: [box_usage_linter] Function not imported nor defined.
      undefined_function()
      ^~~~~~~~~~~~~~~~~~
