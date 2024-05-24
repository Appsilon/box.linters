# nolint start: line_length_linter
#' `box` library attached function exists and exported by package linter
#'
#' Checks that functions being attached exist and are exported by the package/library being called.
#'
#' For use in `rhino`, see the
#' [Explanation: Rhino style guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
#' to learn about the details.
#' @return A custom linter function for use with `r-lib/lintr`
#'
#' @examples
#' # will produce lint
#' lintr::lint(
#'   text = "box::use(stringr[function_not_exists],)",
#'   linter = box_pkg_fun_exists_linter()
#' )
#'
#' # okay
#' lintr::lint(
#'   text = "box::use(stringr[str_pad],)",
#'   linter = box_pkg_fun_exists_linter()
#' )
#' @export
# nolint end
box_pkg_fun_exists_linter <- function() {
  box_package_functions <- "
  /child::expr[
    expr/SYMBOL and
    OP-LEFT-BRACKET and
    not(
      expr[
        preceding-sibling::OP-LEFT-BRACKET and
        SYMBOL[
          text() = '...'
        ]
      ]
    )
  ]
  "

  xpath_package_functions <- paste(box_package_base_path(), box_package_functions)

  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "file")) {
      return(list())
    }

    xml <- source_expression$full_xml_parsed_content

    pkg_fun_not_exists <- check_attached_pkg_funs(xml, xpath_package_functions)

    lapply(pkg_fun_not_exists$xml, function(xml_node) {
      lintr::xml_nodes_to_lints(
        xml_node,
        source_expression = source_expression,
        lint_message = "Function not exported by package.",
        type = "warning"
      )
    })
  })
}

#' Check if functions being attached exist and are being exported by the library/package
#'
#' @return An XML node list
#'
#' @seealso [get_packages_exports()]
#' @keywords internal
check_attached_pkg_funs <- function(xml, xpath) {
  pkg_imports <- xml2::xml_find_all(xml, xpath)

  xpath_pkg_names <- "
    expr/SYMBOL[
      parent::expr/following-sibling::OP-LEFT-BRACKET
    ]"

  xpath_just_functions <- "
      expr[
        preceding-sibling::OP-LEFT-BRACKET and
        following-sibling::OP-RIGHT-BRACKET
      ]
      /SYMBOL[
        not(
          text() = '...'
        )
      ]
    "

  not_exported <- lapply(pkg_imports, function(pkg_import) {
    packages <- extract_xml_and_text(pkg_import, xpath_pkg_names)
    exported_functions <- unlist(get_packages_exports(packages$text))
    attached_functions <- extract_xml_and_text(pkg_import, xpath_just_functions)

    attached_functions$xml[!attached_functions$text %in% exported_functions]
  })

  list(
    xml = not_exported
  )
}
