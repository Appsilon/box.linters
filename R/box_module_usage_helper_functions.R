box_module_base_path <- function() {
  "//SYMBOL_PACKAGE[(text() = 'box' and following-sibling::SYMBOL_FUNCTION_CALL[text() = 'use'])]
  /parent::expr
  /parent::expr[
    ./expr/OP-SLASH
  ]
  "
}

get_module_exports <- function(mod_list) {
  exported_funs <- lapply(mod_list, function(mod) {
    tryCatch(
      get_box_module_exports(mod),
      error = function(e) print(e)
    )
  })

  names(exported_funs) <- mod_list
  exported_funs
}

get_attached_modules <- function(xml) {
  box_module_import <- "
  /child::expr[
    child::expr/SYMBOL
  ]
"

  xpath_module_import <- paste(box_module_base_path(), box_module_import)
  attached_modules <- extract_xml_and_text(xml, xpath_module_import)
  attached_modules$text <- basename(attached_modules$text)
  # nested_list <- get_module_exports(attached_modules$text)
  nested_list <- list()

  whole_module_imports <- "
  /child::*[
    preceding-sibling::OP-LEFT-PAREN and
    following-sibling::OP-RIGHT-PAREN and
    not(
      child::expr/expr[
        following-sibling::OP-LEFT-BRACKET
      ]
    )
  ]
"
  xpath_whole_modules <- paste(box_module_base_path(), whole_module_imports)
  xml_whole_modules <- xml2::xml_find_all(xml, xpath_whole_modules)

  aliased_whole_modules <- paste0(xml2::xml_text(xml_whole_modules), collapse = "")
  mods <- strsplit(gsub("`", "", aliased_whole_modules), ",")[[1]]
  output <- do.call(rbind, strsplit(mods, "="))

  aliases_list <- list()
  if (!all(output == "")) {
    if (ncol(output) == 1) {
      output <- cbind(output, output)
    }
    aliases_list <- output[, 1]
    names(aliases_list) <- output[, 2]

    # attached_modules$text <- aliases_list[attached_modules$text]
    # names(nested_list) <- aliases_list[names(nested_list)]
  }

  flat_list <- list()
  # flat_list <- unlist(
  #   lapply(names(nested_list), function(pkg) {
  #     paste(
  #       pkg,
  #       nested_list[[pkg]],
  #       sep = "$"
  #     )
  #   })
  # )

  list(
    xml = attached_modules$xml_nodes,
    nested = nested_list,
    aliases = aliases_list,
    text = flat_list
  )
}

get_attached_mod_three_dots <- function(xml) {

}

get_attached_mod_functions <- function(xml) {

}
