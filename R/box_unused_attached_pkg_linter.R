# nolint start: line_length_linter
#' `box` library unused attached package linter
#'
#' Checks that all attached packages are used within the source file. This also covers packages
#' attached using the `...`.
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
#'   stringr
#' )
#' "
#'
#' lintr::lint(text = code, linters = box_unused_attached_pkg_linter())
#'
#' code <- "
#' box::use(
#'   alias = stringr
#' )
#' "
#'
#' lintr::lint(text = code, linters = box_unused_attached_pkg_linter())
#'
#' code <- "
#' box::use(
#'   stringr[...]
#' )
#' "
#'
#' lintr::lint(text = code, linters = box_unused_attached_pkg_linter())
#'
#' # okay
#' code <- "
#' box::use(
#'   stringr
#' )
#'
#' stringr$str_pad()
#' "
#'
#' lintr::lint(text = code, linters = box_unused_attached_pkg_linter())
#'
#' code <- "
#' box::use(
#'   alias = stringr
#' )
#'
#' alias$str_pad()
#' "
#'
#' lintr::lint(text = code, linters = box_unused_attached_pkg_linter())
#'
#' code <- "
#' box::use(
#'   stringr[...]
#' )
#'
#' str_pad()
#' "
#'
#' lintr::lint(text = code, linters = box_unused_attached_pkg_linter())
#'
#' @export
# nolint end
box_unused_attached_pkg_linter <- function() {
  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "file")) {
      return(list())
    }

    xml <- source_expression$full_xml_parsed_content

    attached_packages <- get_attached_packages(xml)
    attached_three_dots <- get_attached_pkg_three_dots(xml)
    function_calls <- get_function_calls(xml)
    glue_object_calls <- get_objects_in_strings(xml)
    object_calls <- get_object_calls(xml)

    all_calls_text <- c(function_calls$text, glue_object_calls, object_calls$text)

    unused_package <- lapply(attached_packages$xml, function(attached_package) {
      package_text <- lintr::get_r_string(attached_package)
      aliased_package_text <- attached_packages$aliases[package_text]

      func_list <- paste(
        aliased_package_text,
        attached_packages$nested[[aliased_package_text]],
        sep = "$"
      )

      functions_used <- length(intersect(func_list, all_calls_text))

      if (functions_used == 0) {
        lintr::xml_nodes_to_lints(
          attached_package,
          source_expression = source_expression,
          lint_message = "Attached package unused.",
          type = "warning"
        )
      }
    })

    unused_three_dots <- lapply(attached_three_dots$xml, function(attached_package) {
      package_text <- lintr::get_r_string(attached_package)
      func_list <- attached_three_dots$nested[[package_text]]
      functions_used <- length(intersect(func_list, all_calls_text))

      if (functions_used == 0) {
        lintr::xml_nodes_to_lints(
          attached_package,
          source_expression = source_expression,
          lint_message = "Three-dots attached package unused.",
          type = "warning"
        )
      }
    })

    c(
      unused_package,
      unused_three_dots
    )
  })
}
