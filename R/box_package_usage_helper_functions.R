box_package_base_path <- function() {
  "//SYMBOL_PACKAGE[(text() = 'box' and following-sibling::SYMBOL_FUNCTION_CALL[text() = 'use'])]
  /parent::expr
  /parent::expr[
    not(./expr/OP-SLASH)
  ]
  "
}

get_packages_exports <- function(pkg_list) {
  exported_funs <- lapply(pkg_list, function(pkg) {
    tryCatch(
      getNamespaceExports(pkg),
      error = function(e) character()
    )
  })

  names(exported_funs) <- pkg_list

  exported_funs
}

get_attached_packages <- function(xml) {
  box_package_import <- "
  /child::expr[
    SYMBOL
  ]
  "

  xpath_package_import <- paste(box_package_base_path(), box_package_import)
  attached_packages <- extract_xml_and_text(xml, xpath_package_import)
  nested_list <- get_packages_exports(attached_packages$text)

  whole_package_imports <- "
  /child::*[
    preceding-sibling::OP-LEFT-PAREN and
    following-sibling::OP-RIGHT-PAREN and
    not(
      child::expr[
        following-sibling::OP-LEFT-BRACKET
      ]
    )
  ]
"
  xpath_whole_packages <- paste(box_package_base_path(), whole_package_imports)
  xml_whole_packages <- xml2::xml_find_all(xml, xpath_whole_packages)

  aliased_whole_packages <- paste(xml2::xml_text(xml_whole_packages), collapse = "")
  pkgs <- strsplit(gsub("`", "", aliased_whole_packages), ",")[[1]]
  output <- do.call(rbind, strsplit(pkgs, "="))

  aliases_list <- list()
  if (!all(output == "")) {
    if (ncol(output) == 1) {
      output <- cbind(output, output)
    }
    aliases_list <- output[, 1]
    names(aliases_list) <- output[, 2]

    attached_packages$text <- aliases_list[attached_packages$text]
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
    xml = attached_packages$xml_nodes,
    nested = nested_list,
    aliases = aliases_list,
    text = flat_list
  )
}

get_attached_pkg_three_dots <- function(xml) {
  box_package_three_dots <- "
  /child::expr[
    expr/SYMBOL[text() = '...']
  ]
  /expr[
    following-sibling::OP-LEFT-BRACKET
  ]
  /SYMBOL
  "

  xpath_package_three_dots <- paste(box_package_base_path(), box_package_three_dots)
  attached_three_dots <- extract_xml_and_text(xml, xpath_package_three_dots)
  nested_list <- get_packages_exports(attached_three_dots$text)
  flat_list <- unlist(nested_list, use.names = FALSE)

  list(
    xml = attached_three_dots$xml_nodes,
    nested = nested_list,
    text = flat_list
  )
}

get_attached_pkg_functions <- function(xml) {
  xpath_package_functions <- "
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
  xpath_package_functions <- paste(box_package_base_path(), xpath_package_functions)
  xml_package_functions <- xml2::xml_find_all(xml, xpath_package_functions)

  xpath_just_functions <- "
  /expr[
    preceding-sibling::OP-LEFT-BRACKET and
    following-sibling::OP-RIGHT-BRACKET
  ]
  /SYMBOL[
    not(
      text() = '...'
    )
  ]
"
  xpath_attached_functions <- paste(xpath_package_functions, xpath_just_functions)
  attached_functions <- extract_xml_and_text(xml, xpath_attached_functions)

  aliases <- lapply(xml_package_functions, function(xml_node) {
    xpath_each_function <- "
  ./*[
    preceding-sibling::OP-LEFT-BRACKET and
    following-sibling::OP-RIGHT-BRACKET and
    not(
    self::expr/SYMBOL[
        text() = '...'
      ]
    )
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

