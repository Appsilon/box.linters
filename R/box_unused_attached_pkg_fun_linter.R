# nolint start: line_length_linter
#' `box` library unused attached package function linter
#'
#' Checks that all attached package functions are used within the source file.
#'
#' For use in `rhino`, see the
#' [Explanation: Rhino style guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
#' to learn about the details.
#'
#' @return A custom linter function for use with `r-lib/lintr`.
#'
#' @examples
#' # will produce lints
#' code <- "
#' box::use(
#'   stringr[str_pad],
#' )
#' "
#'
#' lintr::lint(text = code, linters = box_unused_att_pkg_fun_linter())
#'
#' code <- "
#' box::use(
#'   stringr[alias_func = str_pad],
#' )
#' "
#'
#' lintr::lint(text = code, linters = box_unused_att_pkg_fun_linter())
#'
#' # okay
#' code <- "
#' box::use(
#'   stringr[str_pad],
#' )
#'
#' str_pad()
#' "
#'
#' lintr::lint(text = code, linters = box_unused_att_pkg_fun_linter())
#'
#' code <- "
#' box::use(
#'   stringr[alias_func = str_pad],
#' )
#'
#' alias_func()
#' "
#'
#' lintr::lint(text = code, linters = box_unused_att_pkg_fun_linter())
#'
#' @export
# nolint end
box_unused_att_pkg_fun_linter <- function() {
  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "file")) {
      return(list())
    }

    xml <- source_expression$full_xml_parsed_content

    attached_functions <- get_attached_pkg_functions(xml)
    function_calls <- get_function_calls(xml)

    lapply(attached_functions$xml, function(fun_import) {
      fun_import_text <- xml2::xml_text(fun_import)
      fun_import_text <- gsub("[`'\"]", "", fun_import_text)
      aliased_fun_import_text <- attached_functions$text[fun_import_text]

      if (!aliased_fun_import_text %in% function_calls$text) {
        lintr::xml_nodes_to_lints(
          fun_import,
          source_expression = source_expression,
          lint_message = "Imported function unused.",
          type = "warning"
        )
      }
    })
  })
}
