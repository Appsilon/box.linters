box::use(
  R6[R6Class],
)

#' @export
SomeClass <- R6Class("SomeClass",    # nolint
  public = list(
    char_attribute = "char",
    method = function() {
      "method"
    }
  )
)
