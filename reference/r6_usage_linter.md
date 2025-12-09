# R6 class usage linter

Checks method and attribute calls within an R6 class. Covers public,
private, and active objects. All internal calls should exist. All
private methods and attributes should be used.

## Usage

``` r
r6_usage_linter()
```

## Value

A custom linter function for use with `r-lib/lintr`.

## Details

For use in `rhino`, see the [Explanation: Rhino style
guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
to learn about the details.

## Examples

``` r
# will produce lints
code = "
box::use(
  R6[R6Class],
)

badClass <- R6Class('badClass',
  public = list(
    initialize = function() {
      private$not_exists()
    }
  ),
  private = list(
    unused_attribute = 'private data',
    unused_method = function() {
      self$attribute_not_exists
      self$function_not_exists()
    }
  )
)
"

lintr::lint(
  text = code,
  linters = r6_usage_linter()
)
#> <text>:9:7: warning: [r6_usage_linter] Internal object call not found.
#>       private$not_exists()
#>       ^~~~~~~~~~~~~~~~~~
#> <text>:13:5: warning: [r6_usage_linter] Private object not used.
#>     unused_attribute = 'private data',
#>     ^~~~~~~~~~~~~~~~
#> <text>:14:5: warning: [r6_usage_linter] Private object not used.
#>     unused_method = function() {
#>     ^~~~~~~~~~~~~
#> <text>:15:7: warning: [r6_usage_linter] Internal object call not found.
#>       self$attribute_not_exists
#>       ^~~~~~~~~~~~~~~~~~~~~~~~~
#> <text>:16:7: warning: [r6_usage_linter] Internal object call not found.
#>       self$function_not_exists()
#>       ^~~~~~~~~~~~~~~~~~~~~~~~

# okay
code = "
box::use(
  R6[R6Class],
)

goodClass <- R6Class('goodClass',
  public = list(
    public_attr = NULL,
    initialize = function() {
      private$private_func()
    },
    some_function = function () {
      private$private_attr
    }
  ),
  private = list(
    private_attr = 'private data',
    private_func = function() {
      self$public_attr
    }
  )
)
"

lintr::lint(
  text = code,
  linters = r6_usage_linter()
)
#> ℹ No lints found.
```
