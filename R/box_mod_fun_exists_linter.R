#' `box` library attached function exists in module linter
#' @export
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

    mod_fun_not_exists <- check_attached_mod_funs(xml, xpath_module_functions)

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

check_attached_mod_funs <- function(xml, xpath) {
  mod_imports <- xml2::xml_find_all(xml, xpath)

  mod_import_names <- xml2::xml_text(mod_imports)

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
