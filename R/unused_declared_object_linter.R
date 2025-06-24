# nolint start: line_length_linter
#' Unused declared function and data objects linter
#'
#' Checks that all defined/declared functions and data objects are used within the source file.
#' Functions and data objects that are marked with \code{@export} are ignored.
#'
#' For use in `rhino`, see the
#' [Explanation: Rhino style guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
#' to learn about the details.
#'
#' @return A custom linter function for use with `r-lib/lintr`.
#'
#' @examples
#' # will produce lint
#' code <- "
#' #' @export
#' public_function <- function() {
#'
#' }
#'
#' private_function <- function() {
#'
#' }
#'
#' local_data <- \"A\"
#' "
#'
#' lintr::lint(text = code, linters = unused_declared_object_linter())
#'
#' # okay
#' code <- "
#' #' @export
#' public_function <- function(local_data) {
#'   private_function(local_data)
#' }
#'
#' private_function <- function() {
#'
#' }
#'
#' local_data <- \"A\"
#' "
#'
#' lintr::lint(text = code, linters = unused_declared_object_linter())
#'
#' @export
# nolint end
unused_declared_object_linter <- function() {
  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "file")) {
      return(list())
    }

    xml <- source_expression$full_xml_parsed_content

    object_assignments <- get_declared_objects(xml)
    destructure_assignments <- get_destructure_objects(xml)
    exported_objects <- get_exported_objects(xml)

    if (length(exported_objects$xml_nodes) == 0) {
      exported_objects <- object_assignments
    }

    function_calls <- get_function_calls(xml)
    special_calls <- get_special_calls(xml)
    object_calls <- get_object_calls(xml)
    glue_object_calls <- get_objects_in_strings(xml)
    local_calls_text <- c(
      function_calls$text,
      special_calls$text,
      object_calls$text,
      glue_object_calls
    )

    all_assignments <- c(object_assignments$xml_nodes, destructure_assignments$xml_nodes)

    lapply(all_assignments, function(obj_assign) {
      obj_assign_text <- xml2::xml_text(obj_assign)
      obj_assign_text <- gsub("[`'\"]", "", obj_assign_text)

      if (!obj_assign_text %in% local_calls_text &
            !obj_assign_text %in% exported_objects$text) {
        lintr::xml_nodes_to_lints(
          obj_assign,
          source_expression = source_expression,
          lint_message = "Declared function/object unused.",
          type = "warning"
        )
      }
    })
  })
}

get_exported_objects <- function(xml) {
  xpath_exported_objects <- "
  //COMMENT[text() = \"#' @export\"]
  /following-sibling::expr[1]
  /expr/SYMBOL
  "

  extract_xml_and_text(xml, xpath_exported_objects)
}
