box::use(
  R6[R6Class],
)

#' @export
some_class <- R6Class("SomeClass",
  public = list(
    char_attribute = "char",
    method = function() {
      "method"
    }
  )
)
