# nolint start: line_length_linter
#' `box` library alphabetical module and function imports linter
#'
#' Checks that module and function imports are sorted alphabetically. Aliases are
#' ignored. The sort check is on package/module names and attached function names.
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
#'   text = "box::use(package[functionB, functionA])",
#'   linters = box_alphabetical_calls_linter()
#' )
#'
#' lintr::lint(
#'   text = "box::use(path/to/B, path/to/A)",
#'   linters = box_alphabetical_calls_linter()
#' )
#'
#' lintr::lint(
#'   text = "box::use(path/to/A[functionB, functionA])",
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
#' lintr::lint(
#'   text = "box::use(package[functionA, functionB])",
#'   linters = box_alphabetical_calls_linter()
#' )
#'
#' lintr::lint(
#'   text = "box::use(path/to/A, path/to/B)",
#'   linters = box_alphabetical_calls_linter()
#' )
#'
#' lintr::lint(
#'   text = "box::use(path/to/A[functionA, functionB])",
#'   linters = box_alphabetical_calls_linter()
#' )
#'
#' lintr::lint(
#'   text = "box::use(path/to/A[functionA, alias = functionB])",
#'   linters = box_alphabetical_calls_linter()
#' )
#'
#' @export
# nolint end
box_alphabetical_calls_linter <- function() {
  xpath_base <- "//SYMBOL_PACKAGE[(text() = 'box' and
  following-sibling::SYMBOL_FUNCTION_CALL[text() = 'use'])]
  /parent::expr
  /parent::expr"

  xpath <- paste(xpath_base, "
  /child::expr[
    descendant::SYMBOL
  ]")

  xpath_modules_with_functions <- paste(xpath_base, "
  /child::expr[
    descendant::SYMBOL and
    descendant::OP-LEFT-BRACKET
  ]")

  xpath_functions <- "./descendant::expr/SYMBOL[
    ../preceding-sibling::OP-LEFT-BRACKET and
    ../following-sibling::OP-RIGHT-BRACKET
  ]"

  lint_message <- "Module and function imports must be sorted alphabetically."

  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "expression")) {
      return(list())
    }

    xml <- source_expression$xml_parsed_content
    xml_nodes <- xml2::xml_find_all(xml, xpath)
    modules_called <- xml2::xml_text(xml_nodes)
    modules_check <- modules_called == sort(modules_called)

    unsorted_modules <- which(modules_check == FALSE)
    module_lint <- lintr::xml_nodes_to_lints(
      xml_nodes[unsorted_modules],
      source_expression = source_expression,
      lint_message = lint_message,
      type = "style"
    )

    xml_nodes_with_functions <- xml2::xml_find_all(xml_nodes, xpath_modules_with_functions)

    function_lint <- lapply(xml_nodes_with_functions, function(xml_node) {
      imported_functions <- xml2::xml_find_all(xml_node, xpath_functions)
      functions_called <- xml2::xml_text(imported_functions)
      functions_check <- functions_called == sort(functions_called)
      unsorted_functions <- which(functions_check == FALSE)
      unsorted <- any(!functions_check)

      if (unsorted) {
        lint_nodes <- imported_functions[unsorted_functions[1]]
        lintr::xml_nodes_to_lints(
          lint_nodes,
          source_expression = source_expression,
          lint_message = lint_message,
          type = "style"
        )
      }
    })

    c(module_lint, function_lint)
  })
}
