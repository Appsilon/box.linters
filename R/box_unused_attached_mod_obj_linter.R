# nolint start: line_length_linter
#' `box` library unused attached module object linter
#'
#' Checks that all attached module functions and data objects are used within the source file.
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
#' code <- "
#' box::use(
#'   path/to/module[some_function, some_object],
#' )
#' "
#'
#' lintr::lint(text = code, linters = box_unused_att_mod_obj_linter())
#'
#' code <- "
#' box::use(
#'   path/to/module[alias_func = some_function, alias_obj = some_object],
#' )
#' "
#'
#' lintr::lint(text = code, linters = box_unused_att_mod_obj_linter())
#'
#' # okay
#' code <- "
#' box::use(
#'   path/to/module[some_function, some_object],
#' )
#'
#' x <- sum(some_object)
#' some_function()
#' "
#'
#' lintr::lint(text = code, linters = box_unused_att_mod_obj_linter())
#'
#' code <- "
#' box::use(
#'   path/to/module[alias_func = some_function, alias_obj = some_object],
#' )
#'
#' x <- sum(alias_obj)
#' alias_func()
#' "
#'
#' lintr::lint(text = code, linters = box_unused_att_mod_obj_linter())
#' }
#' @export
# nolint end
box_unused_att_mod_obj_linter <- function() {
  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "file")) {
      return(list())
    }

    xml <- source_expression$full_xml_parsed_content

    attached_functions_objects <- get_attached_mod_functions(xml)
    function_calls <- get_function_calls(xml)
    object_calls <- get_object_calls(xml)
    all_object_calls_text <- c(function_calls$text, object_calls$text)

    lapply(attached_functions_objects$xml, function(fun_obj_import) {
      fun_obj_import_text <- xml2::xml_text(fun_obj_import)
      fun_obj_import_text <- gsub("[`'\"]", "", fun_obj_import_text)
      aliased_fun_import_text <- attached_functions_objects$text[fun_obj_import_text]

      if (!aliased_fun_import_text %in% all_object_calls_text) {
        lintr::xml_nodes_to_lints(
          fun_obj_import,
          source_expression = source_expression,
          lint_message = "Imported function/object unused.",
          type = "warning"
        )
      }
    })
  })
}
