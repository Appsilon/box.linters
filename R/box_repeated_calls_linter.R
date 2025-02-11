# nolint start: line_length_linter
#' `box` library repeated imports of packages
#'
#' Checks that package imports are not repeated.
#'
#' For use in `rhino`, see the
#' [Explanation: Rhino style guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
#' to learn about the details.
#'
#' @return A custom linter function for use with `r-lib/lintr`.
#'
#' @examples
#' # will produce lints
#' lintr::lint(
#'   text = "box::use(packageB, packageA)",
#'   linters = box_alphabetical_calls_linter()
#' )
#'
#' lintr::lint(
#'   text = "box::use(path/to/A[alias = functionB, functionA])",
#'   linters = box_alphabetical_calls_linter()
#' )
#'
#' # okay
#' lintr::lint(
#'   text = "box::use(packageA, packageB)",
#'   linters = box_alphabetical_calls_linter()
#' )
#'
#' @export
# nolint end
box_repeated_calls_linter <- function() {

  # XPath finds all box::use() calls
  # Looks for expressions where:
  # - Package namespace is "box"
  # - Function called is "use"
  xpath_base <- "//SYMBOL_PACKAGE[(text() = 'box' and
  following-sibling::SYMBOL_FUNCTION_CALL[text() = 'use'])]
  /parent::expr
  /parent::expr"

  lintr::Linter(function(source_expression) {

    # Only process full expressions (not individual lines)
    if (!lintr::is_lint_level(source_expression, "expression")) {
      return(list())
    }

    xml <- source_expression$xml_parsed_content

    box_use_calls <- xml2::xml_find_all(xml, xpath_base)

    lint_list <- lapply(box_use_calls, function(call_node) {
      # Gets all arguments to box::use()
      # position() > 1 skips the first element (box::use itself)
      args <- xml2::xml_find_all(call_node, "./expr[position() > 1]")

      arg_texts <- vapply(args, function(arg) {
        str = xml2::xml_text(arg)
        str_split = stringr::str_split_1(string = str, pattern = '\\[')[1]
      }, character(1))

      # duplicated() flags duplicates after first occurrence
      # Returns logical vector (TRUE for duplicates)
      duplicates <- base::duplicated(arg_texts)

      # Skip processing if no duplicates found
      if (!any(duplicates)) return(NULL)

      # Finds positions of duplicate packages
      duplicate_indices <- which(duplicates)

      # Creates lint warning for each duplicate
      # Positions the lint at the duplicate's location
      # Uses meaningful error message with package name
      lapply(duplicate_indices, function(i) {
        lintr::xml_nodes_to_lints(
          args[[i]],
          source_expression = source_expression,
          lint_message = sprintf("Package '%s' is imported more than once.", arg_texts[i]),
          type = "warning"
        )
      })
    })

    unlist(lint_list, recursive = FALSE)
  })

}
