# Check that `namespace::function()` calls except for `box::*()` are not made.

Check that `namespace::function()` calls except for `box::*()` are not
made.

## Usage

``` r
namespaced_function_calls(allow = NULL)
```

## Arguments

- allow:

  Character vector of `namespace` or `namespace::function` to allow in
  the source code. Take not that the `()` are not included. The `box`
  namespace will always be allowed

## Examples

``` r
# will produce lints
code <- "box::use(package)
tidyr::pivot_longer()"

lintr::lint(text = code, linters = namespaced_function_calls())
#> <text>:2:1: warning: [namespaced_function_calls] Explicit `package::function()` calls are not advisible when using `box` modules.
#> tidyr::pivot_longer()
#> ^~~~~~~~~~~~~~~~~~~

## allow `tidyr::pivot_longer()`
code <- "box::use(package)
tidyr::pivot_longer()
tidyr::pivot_wider()"

lintr::lint(text = code, linters = namespaced_function_calls(allow = c("tidyr::pivot_longer")))
#> <text>:3:1: warning: [namespaced_function_calls] Explicit `package::function()` calls are not advisible when using `box` modules.
#> tidyr::pivot_wider()
#> ^~~~~~~~~~~~~~~~~~

# okay
code <- "box::use(package)"

lintr::lint(text = code, linters = namespaced_function_calls())
#> ℹ No lints found.

## allow all `tidyr`
code <- "box::use(package)
tidyr::pivot_longer()
tidyr::pivot_wider()"

lintr::lint(text = code, linters = namespaced_function_calls(allow = c("tidyr")))
#> ℹ No lints found.

## allow `tidyr::pivot_longer()`
code <- "box::use(package)
tidyr::pivot_longer()"

lintr::lint(text = code, linters = namespaced_function_calls(allow = c("tidyr::pivot_longer")))
#> ℹ No lints found.
```
