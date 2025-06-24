# nolint start: line_length_linter
#' `box` library repeated imports of packages
#'
#' Checks that modules and libraries imports are not repeated.
#'
#' For use in `rhino`, see the
#' [Explanation: Rhino style guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
#' to learn about the details.
#'
#' @return A custom linter function for use with `r-lib/lintr`.
#'
#' @examples
#' \dontrun{
#' # will produce lints
#' lintr::lint(
#'   text = "box::use(packageA, packageA, packageB)",
#'   linters = box_repeated_calls_linter()
#' )
#'
#' code <- "
#' box::use(
#'   dplyr,
#'   shiny,
#' )
#'
#' box::use(
#'   dplyr,
#' )
#' "
#' lintr::lint(text = code, linters = box_repeated_calls_linter())
#'
#' code <- "
#' box::use(
#'   dplyr[mutate, select],
#'   dplyr[group_by],
#' )
#'
#' box::use(
#'   path/to/A,
#'   path/to/A[f1, f2]
#' )
#' "
#' lintr::lint(text = code, linters = box_repeated_calls_linter())
#'
#' # okay
#' code <- "
#' box::use(
#'   path/to/fileA,
#'   path/to/fileB,
#'   path/to/fileC,
#' )
#' "
#' lintr::lint(text = code, linters = box_repeated_calls_linter())
#'
#' code <- "
#' box::use(
#'   path/to/fileA,
#'   path/to/fileB[f1, f2],
#'   path/to/fileC[f3, f4],
#' )
#' "
#' lintr::lint(text = code, linters = box_repeated_calls_linter())
#'}
#' @export
# nolint end
box_repeated_calls_linter <- function() {


  lintr::Linter(function(source_expression) {

    if (!lintr::is_lint_level(source_expression, "file")) {
      return(list())
    }

    xml <- source_expression$full_xml_parsed_content

    all_imports <- find_all_imports(xml)
    duplicated_imports <- duplicated(all_imports$text)
    duplicated_import_nodes <- all_imports$xml[duplicated_imports]

    lapply(duplicated_import_nodes, function(duplicate_node) {
      import_text <- retrieve_text_before_bracket(lintr::get_r_string(duplicate_node))

      lintr::xml_nodes_to_lints(
        duplicate_node,
        source_expression = source_expression,
        lint_message = sprintf("Module or package '%s' is imported more than once.", import_text),
        type = "warning"
      )
    })
  })
}

#' Get all modules and packages called as a whole, functions, or three-dots
#'
#' @param xml An XML node list
#' @return `xml` list of `xml_nodes`, `text` list of module/package names.
#' @keywords internal
find_all_imports <- function(xml) {
  xpath_imports <- "
  //SYMBOL_PACKAGE[(text() = 'box' and following-sibling::SYMBOL_FUNCTION_CALL[text() = 'use'])]
  /parent::expr
  /parent::expr
  /expr[
    descendant::SYMBOL
  ]
"

  called_imports <- extract_xml_and_text(xml, xpath_imports)
  called_imports$text <- retrieve_text_before_bracket(called_imports$text)

  list(
    xml = called_imports$xml,
    text = called_imports$text
  )
}

#' Extract the text before the `[` bracket
#'
#' @param text_vector A character vector
#' @return character vector of text before the first `[`
#' @keywords internal
retrieve_text_before_bracket <- function(text_vector) {
  unlist(
    lapply(text_vector, function(text) {
      text_before_bracket <- stringr::str_match(text, "^(.*?)\\[")
      if (!is.na(text_before_bracket[1, 2])) {
        text_before_bracket[1, 2]
      } else {
        text
      }
    })
  )
}
