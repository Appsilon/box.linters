# nolint start: line_length_linter
#' `box` library attached function exists and exported by called module linter
#'
#' Checks that functions being attached exist and are exported by the local module being called.
#'
#' For use in `rhino`, see the
#' [Explanation: Rhino style guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
#' to learn about the details.
#' @return A custom linter function for use with `r-lib/lintr`
#'
#' @examples
#' \dontrun{
#' # will produce lint
#' lintr::lint(
#'   text = "box::use(path/to/module_a[function_not_exists],)",
#'   linter = box_mod_fun_exists_linter()
#' )
#'
#' # okay
#' lintr::lint(
#'   text = "box::use(path/to/module_a[function_exists],)",
#'   linter = box_mod_fun_exists_linter()
#' )
#' }
#' @export
# nolint end
box_mod_fun_exists_linter <- function() {
  box_module_functions <- "
  /child::expr[
    child::expr[
      child::OP-LEFT-BRACKET and
      not(
        child::expr/SYMBOL[
          text() = '...'
        ]
      )
    ]
  ]"

  xpath_module_functions <- paste(box_module_base_path(), box_module_functions)

  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "file")) {
      return(list())
    }

    xml <- source_expression$full_xml_parsed_content

    working_dir <- get_module_working_dir(source_expression)

    withr::with_dir(working_dir, {
      mod_fun_not_exists <- check_attached_mod_funs(xml, xpath_module_functions)
    })

    lapply(mod_fun_not_exists$xml, function(xml_node) {
      lintr::xml_nodes_to_lints(
        xml_node,
        source_expression = source_expression,
        lint_message = "Function not exported by module.",
        type = "warning"
      )
    })
  })
}

#' Check if functions being attached exist and are being exported by the local module
#'
#' @return An XML node list
#'
#' @seealso [get_module_exports()]
#' @keywords internal
check_attached_mod_funs <- function(xml, xpath) {
  mod_imports <- xml2::xml_find_all(xml, xpath)

  xpath_just_functions <- "
  expr/expr[
    preceding-sibling::OP-LEFT-BRACKET and
    following-sibling::OP-RIGHT-BRACKET
  ]
  /SYMBOL
"

  not_exported <- lapply(mod_imports, function(mod_import) {
    mod_import_name <- xml2::xml_text(mod_import)
    exported_functions <- unlist(get_module_exports(mod_import_name))
    attached_functions <- extract_xml_and_text(mod_import, xpath_just_functions)

    attached_functions$xml[!attached_functions$text %in% exported_functions]
  })

  list(
    xml = not_exported
  )
}
