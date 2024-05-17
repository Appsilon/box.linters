# nolint start: line_length_linter
#' `box` library separate packages and module imports linter
#'
#' Checks that packages and modules are imported in separate `box::use()` statements.
#'
#' For use in `rhino`, see the
#' [Explanation: Rhino style guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
#' to learn about the details.
#'
#' @return A custom linter function for use with `r-lib/lintr`
#'
#' @examples
#' # will produce lints
#' lintr::lint(
#'   text = "box::use(package, path/to/file)",
#'   linters = box_separate_calls_linter()
#' )
#'
#' lintr::lint(
#'   text = "box::use(path/to/file, package)",
#'   linters = box_separate_calls_linter()
#' )
#'
#' # okay
#' lintr::lint(
#'   text = "box::use(package1, package2)
#'     box::use(path/to/file1, path/to/file2)",
#'   linters = box_separate_calls_linter()
#' )
#'
#' @export
# nolint end
box_separate_calls_linter <- function() {
  xpath <- "
  //SYMBOL_PACKAGE[(text() = 'box' and following-sibling::SYMBOL_FUNCTION_CALL[text() = 'use'])]
  /parent::expr
  /parent::expr[
    (
      ./child::expr[child::SYMBOL] or
      ./child::expr[
        child::expr[child::SYMBOL] and child::OP-LEFT-BRACKET
      ]
    ) and
    ./child::expr[child::expr[child::OP-SLASH]]
  ]
  "
  lint_message <- "Separate packages and modules in their respective box::use() calls."

  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "file")) {
      return(list())
    }

    xml <- source_expression$full_xml_parsed_content

    bad_expr <- xml2::xml_find_all(xml, xpath)

    lintr::xml_nodes_to_lints(
      bad_expr,
      source_expression = source_expression,
      lint_message = lint_message,
      type = "style"
    )
  })
}
