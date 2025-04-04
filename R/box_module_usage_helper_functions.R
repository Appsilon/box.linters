#' Get functions exported by modules
#'
#' @param mod_list A vector of packages
#' @return A list of (`package_name` = list(`of_functions`))
#' @keywords internal
get_module_exports <- function(mod_list) {
  exported_funs <- lapply(mod_list, function(mod) {
    tryCatch({
      get_box_module_exports(mod)
    }, error = function(e) {
      NULL
    })
  })

  names(exported_funs) <- mod_list
  exported_funs
}

#' Get all modules imported whole
#'
#' @param xml An XML node list
#' @return `xml` list of `xml_nodes`, `nested` list of `module: functions`, `aliases` a named list
#' of `module` = `alias`, `text` list of all `module$function` names.
#' @keywords internal
get_attached_modules <- function(xml) {
  box_module_import <- "
  /child::expr[
    child::expr/SYMBOL[
      parent::expr[
        preceding-sibling::OP-SLASH
      ]
    ]
  ]
"

  xpath_module_import <- paste(box_module_base_path(), box_module_import)
  attached_modules <- extract_xml_and_text(xml, xpath_module_import)
  nested_list <- get_module_exports(attached_modules$text)
  # normalize module names
  attached_modules$text <- basename(attached_modules$text)
  names(nested_list) <- gsub("`", "", basename(names(nested_list)))

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

  xml_whole_modules_text <- xml2::xml_text(xml_whole_modules)

  hacky_comma_fix <- hacky_comma_fix(xml_whole_modules_text)

  aliased_whole_modules <- paste0(hacky_comma_fix, collapse = "")
  mods <- strsplit(gsub("`", "", aliased_whole_modules), ",")[[1]]
  output <- do.call(rbind, strsplit(mods, "="))

  aliases_list <- list()
  if (!all(output == "")) {
    if (ncol(output) == 1) {
      output <- cbind(output, output)
    }
    aliases_list <- basename(output[, 1])
    names(aliases_list) <- basename(output[, 2])

    attached_modules$text <- aliases_list[attached_modules$text]
    names(nested_list) <- aliases_list[names(nested_list)]
  }

  flat_list <- unlist(
    lapply(names(nested_list), function(pkg) {
      paste(
        pkg,
        nested_list[[pkg]],
        sep = "$"
      )
    })
  )

  list(
    xml = attached_modules$xml_nodes,
    nested = nested_list,
    aliases = aliases_list,
    text = flat_list
  )
}

#' Get all functions exported from modules by ...
#'
#' @param xml An XML node list
#' @return `xml` list of `xml_nodes`, `nested` list of `module: function`, `text` list of function
#' names.
#' @keywords internal
get_attached_mod_three_dots <- function(xml) {
  box_module_three_dots <- "
  /child::expr[
    expr/expr/SYMBOL[text() = '...']
  ]
  "

  xpath_module_three_dots <- paste(box_module_base_path(), box_module_three_dots)
  attached_three_dots <- extract_xml_and_text(xml, xpath_module_three_dots)
  attached_three_dots$text <- sub("\\[\\.\\.\\.\\]", "", attached_three_dots$text)

  nested_list <- get_module_exports(attached_three_dots$text)
  names(nested_list) <- basename(names(nested_list))
  flat_list <- unlist(nested_list, use.names = FALSE)

  list(
    xml = attached_three_dots$xml_nodes,
    nested = nested_list,
    text = flat_list
  )
}

#' Get imported functions from modules
#'
#' @param xml An XML node list
#' @return `xml` list of xml nodes, `text` a list of function names.
#' @keywords internal
get_attached_mod_functions <- function(xml) {
  xpath_module_functions <- "
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

  xpath_module_functions <- paste(box_module_base_path(), xpath_module_functions)
  xml_module_functions <- xml2::xml_find_all(xml, xpath_module_functions)

  xpath_just_functions <- "
  /expr/expr[
    preceding-sibling::OP-LEFT-BRACKET and
    following-sibling::OP-RIGHT-BRACKET
  ]
  /SYMBOL
"

  xpath_attached_functions <- paste(xpath_module_functions, xpath_just_functions)
  attached_functions <- extract_xml_and_text(xml, xpath_attached_functions)

  aliases <- lapply(xml_module_functions, function(xml_node) {
    xpath_each_function <- "
  ./expr/*[
    preceding-sibling::OP-LEFT-BRACKET and
    following-sibling::OP-RIGHT-BRACKET
  ]
"

    package_function_call <- xml2::xml_find_all(xml_node, xpath_each_function)
    aliased_functions <- paste(xml2::xml_text(package_function_call), collapse = "")

    functions <- strsplit(gsub("`", "", aliased_functions), ",")[[1]]

    output <- do.call(rbind, strsplit(functions, "="))
    if (ncol(output) == 1) {
      output <- cbind(output, output)
    }
    list_output <- output[, 1]
    names(list_output) <- output[, 2]
    list_output
  })

  attached_functions$text <- unlist(aliases)[attached_functions$text]
  list(
    xml = attached_functions$xml_nodes,
    text = attached_functions$text
  )
}

#' @keywords internal
get_module_working_dir <- function(source_expression) {
  box_path <- getOption("box.path")
  if (is.null(box_path)) {
    working_dir <- fs::path_dir(source_expression$filename)
  } else {
    working_dir <- box_path
  }
  working_dir
}
