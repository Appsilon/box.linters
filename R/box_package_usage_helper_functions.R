#' Get functions exported by packages
#'
#' @param pkg_list A vector of packages
#' @return A list of (`package_name` = list(`of_functions`))
#' @keywords internal
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

#' Get all packages imported whole
#'
#' @param xml An XML node list
#' @return `xml` list of `xml_nodes`, `nested` list of `package: functions`, `aliases` a named list
#' of `package` = `alias`, `text` list of all `package$function` names.
#' @keywords internal
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

  xml_whole_packages_text <- xml2::xml_text(xml_whole_packages)

  hacky_comma_fix <- hacky_comma_fix(xml_whole_packages_text)

  aliased_whole_packages <- paste(hacky_comma_fix, collapse = "")
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

#' Get all functions exported from packages by ...
#'
#' @param xml An XML node list
#' @return `xml` list of `xml_nodes`, `nested` list of `package: function`, `text` a list of
#' function names.
#' @keywords internal
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

#' Get imported functions from packages
#'
#' @param xml An XML node list
#' @return `xml` list of xml nodes, `text` a list of function names.
#' @keywords internal
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

  xpath_just_functions <- "
  /expr[
    preceding-sibling::OP-LEFT-BRACKET and
    following-sibling::OP-RIGHT-BRACKET
  ]
  /SYMBOL
"

  xpath_attached_functions <- paste(xpath_package_functions, xpath_just_functions)
  attached_functions <- extract_xml_and_text(xml, xpath_attached_functions)

  aliases <- lapply(xml_package_functions, function(xml_node) {
    xpath_each_function <- "
  ./*[
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
hacky_comma_fix <- function(pkg_imports) {
  punc <- c("=", ",")

  if (rlang::is_empty(pkg_imports)) {
    return(pkg_imports)
  }

  hacky_comma_fix <- pkg_imports[1]
  if (length(pkg_imports) == 1) {
    return(hacky_comma_fix)
  }
  for (i in seq(2, length(pkg_imports))) {
    curr <- pkg_imports[i]
    prev <- pkg_imports[i - 1]

    if (!curr %in% punc && !prev %in% punc) {
      hacky_comma_fix <- c(hacky_comma_fix, ",", curr)
    } else {
      hacky_comma_fix <- c(hacky_comma_fix, curr)
    }
  }
  hacky_comma_fix
}
