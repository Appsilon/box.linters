#' Rhino default linters
#'
#' See the [Explanation: Rhino style guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
#' to learn about the details.
#'
#' @examples
#' linters <- lintr::linters_with_defaults(defaults = box.linters::rhino_default_linters)
#'
#' names(linters)
#'
#' @export
rhino_default_linters <- lintr::modify_defaults(
  defaults = lintr::default_linters,
  line_length_linter = lintr::line_length_linter(100),
  box_alphabetical_calls_linter = box_alphabetical_calls_linter(),
  box_func_import_count_linter = box_func_import_count_linter(),
  box_separate_calls_linter = box_separate_calls_linter(),
  box_trailing_commas_linter = box_trailing_commas_linter(),
  box_universal_import_linter = box_universal_import_linter(),
  object_usage_linter = NULL  # Does not work with `box::use()`
)
