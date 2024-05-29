# nolint start: line_length_linter
#' `box` library unused attached module linter
#'
#' Checks that all attached modules are used within the source file. This also covers modules
#' attached using the `...`.
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
#'   path/to/module
#' )
#' "
#'
#' lintr::lint(code, linters = box_unused_attached_mod_linter())
#'
#' code <- "
#' box::use(
#'   alias = path/to/module
#' )
#' "
#'
#' lintr::lint(code, linters = box_unused_attached_mod_linter())
#'
#' code <- "
#' box::use(
#'   path/to/module[...]
#' )
#' "
#'
#' lintr::lint(code, linters = box_unused_attached_mod_linter())
#'
#' # okay
#' code <- "
#' box::use(
#'   path/to/module
#' )
#'
#' module$some_function()
#' "
#'
#' lintr::lint(code, linters = box_unused_attached_mod_linter())
#'
#' code <- "
#' box::use(
#'   alias = path/to/module
#' )
#'
#' alias$some_function()
#' "
#'
#' lintr::lint(code, linters = box_unused_attached_mod_linter())
#'
#' code <- "
#' box::use(
#'   path/to/module[...]     # module exports some_function()
#' )
#'
#' some_function()
#' "
#'
#' lintr::lint(code, linters = box_unused_attached_mod_linter())
#' }
#'
#' @export
# nolint end
box_unused_attached_mod_linter <- function() {
  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "file")) {
      return(list())
    }

    xml <- source_expression$full_xml_parsed_content

    attached_modules <- get_attached_modules(xml)
    attached_three_dots <- get_attached_mod_three_dots(xml)
    function_calls <- get_function_calls(xml)
    glue_object_calls <- get_objects_in_strings(xml)
    possible_module_calls <- get_object_calls(xml)

    all_calls_text <- c(function_calls$text, glue_object_calls)

    unused_module <- lapply(attached_modules$xml, function(attached_module) {
      module_text <- basename(lintr::get_r_string(attached_module))
      aliased_module_text <- attached_modules$aliases[module_text]

      func_list <- paste(
        aliased_module_text,
        attached_modules$nested[[aliased_module_text]],
        sep = "$"
      )

      functions_used <- length(intersect(func_list, all_calls_text))
      modules_used <- length(intersect(aliased_module_text, possible_module_calls$text))

      if (functions_used == 0 && modules_used == 0) {
        lintr::xml_nodes_to_lints(
          attached_module,
          source_expression = source_expression,
          lint_message = "Attached module unused.",
          type = "warning"
        )
      }
    })

    unused_three_dots <- lapply(attached_three_dots$xml, function(attached_module) {
      module_text <- basename(lintr::get_r_string(attached_module))
      module_text <- sub("\\[\\.\\.\\.\\]", "", module_text)
      func_list <- attached_three_dots$nested[[module_text]]
      functions_used <- length(intersect(func_list, all_calls_text))

      if (functions_used == 0) {
        lintr::xml_nodes_to_lints(
          attached_module,
          source_expression = source_expression,
          lint_message = "Three-dots attached module unused.",
          type = "warning"
        )
      }
    })

    c(
      unused_module,
      unused_three_dots
    )
  })
}
