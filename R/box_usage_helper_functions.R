#' Extracts XML nodes and text strings matched by XML search
#'
#' @param xml An XML node list.
#' @param xpath An XPath to search xml nodes.
#' @return A list of `xml_nodes` and `text`.
#' @keywords internal
extract_xml_and_text <- function(xml, xpath) {
  xml_nodes <- xml2::xml_find_all(xml, xpath)
  text <- lintr::get_r_string(xml_nodes)
  text <- gsub("[`'\"]", "", text)

  list(
    xml_nodes = xml_nodes,
    text = text
  )
}

#' Get locally declared/defined functions
#'
#' @param xml An XML node list.
#' @return A list of `xml_nodes` and `text`.
#' @keywords internal
get_declared_functions <- function(xml) {
  xpath_function_assignment <- "
  //expr[
      (LEFT_ASSIGN or EQ_ASSIGN) and ./expr[2][FUNCTION or OP-LAMBDA]
    ]
    /expr[1]/SYMBOL
  | //expr_or_assign_or_help[EQ_ASSIGN and ./expr[2][FUNCTION or OP-LAMBDA]]
  | //equal_assign[EQ_ASSIGN and ./expr[2][FUNCTION or OP-LAMBDA]]
  | //SYMBOL_FUNCTION_CALL[text() = 'assign']/parent::expr[
      ./following-sibling::expr[2][FUNCTION or OP-LAMBDA]
    ]
    /following-sibling::expr[1]/STR_CONST
  "

  extract_xml_and_text(xml, xpath_function_assignment)
}

#' Get locally declared/defined data objects
#'
#' @param xml An XML node list
#' @return A list of `xml_nodes` and `text`.
#' @keywords internal
get_declared_objects <- function(xml) {
  xpath_object_assignment <- "
  //expr[LEFT_ASSIGN]/expr[1]/SYMBOL[1 and not(preceding-sibling::OP-DOLLAR)] |
  //equal_assign/expr[1]/SYMBOL[1] |
  //expr_or_assign_or_help/expr[1]/SYMBOL[1] |
  //expr[expr[1][SYMBOL_FUNCTION_CALL/text()='assign']]/expr[2]/* |
  //expr[expr[1][SYMBOL_FUNCTION_CALL/text()='setMethod']]/expr[2]/*
  "

  extract_xml_and_text(xml, xpath_object_assignment)
}

#' Get functions called in current source file
#'
#' Will not return `package::function()` form. [namespaced_function_calls()] is responsible for
#' checking `package_function()` use.
#'
#' @param xml An XML node list
#' @return A list of `xml_nodes` and `text`.
#' @keywords internal
get_function_calls <- function(xml) {
  xpath_box_function_calls <- "
  //expr[
    SYMBOL_FUNCTION_CALL and
    not(NS_GET) and
    not(SYMBOL_PACKAGE)
  ] |
  //SPECIAL
  "

  # lintr::get_r_string throws an error when seeing SYMBOL %>%
  xml_nodes <- xml2::xml_find_all(xml, xpath_box_function_calls)
  text <- xml2::xml_text(xml_nodes, trim = TRUE)
  r6_refs <- internal_r6_refs(text)

  xml_nodes <- xml_nodes[!r6_refs]
  text <- text[!r6_refs]

  list(
    xml_nodes = xml_nodes,
    text = text
  )
}

#' Get objects called in current source file
#'
#' @param xml An XML node list
#' @return a list of `xml_nodes` and `text`.
#' @keywords internal
get_object_calls <- function(xml) {
  xpath_all_lines <- "/exprlist/*"
  xml_all_lines <- xml2::xml_find_all(xml, xpath_all_lines)

  xpath_box_use <- "
  //expr[
    SYMBOL_PACKAGE[
      (text() = 'box' and following-sibling::SYMBOL_FUNCTION_CALL[text() = 'use'])
    ]
  ]
  /parent::expr
  "

  xml_box_use <- xml2::xml_find_all(xml, xpath_box_use)
  xml_no_box_use <- xml_all_lines[!xml_all_lines %in% xml_box_use]

  xpath_all_object_calls <- "
  .//expr[
    ./SYMBOL and
    not(
      following-sibling::LEFT_ASSIGN or
      following-sibling::EQ_ASSIGN
    )
  ]
  "
  xml_object_calls <- xml2::xml_find_all(xml_no_box_use, xpath_all_object_calls)
  text <- xml2::xml_text(xml_object_calls, trim = TRUE)

  list(
    xml_nodes = xml_object_calls,
    text = text
  )
}

#' Get objects names in function signatures from all functions in current source file
#'
#' @description
#' This is a brute-force extraction of `SYMBOL_FORMALS` and is not scope-aware.
#'
#' @param xml An XML node list
#' @return a list of `xml_nodes` and `text`.
#' @keywords internal
get_function_signature_objs <- function(xml) {
  xpath_all_func_sig_objs <- "//SYMBOL_FORMALS"
  extract_xml_and_text(xml, xpath_all_func_sig_objs)
}

internal_r6_refs <- function(func_list) {
  r6_refs <- "self|private\\$.+"
  grepl(r6_refs, func_list)
}
