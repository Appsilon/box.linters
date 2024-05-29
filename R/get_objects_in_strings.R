#' Get objects used in `glue` string templates
#'
#' @description
#' In `glue`, all text between `{` and `}` is considered code. Literal braces are defined as
#' `{{` and `}}`. Text between double braces are not interpolated.
#'
#' @param xml An xml node list.
#' @return A character vector of object and function names found inside `glue` string templates.
#' @keywords internal
get_objects_in_strings <- function(xml) {
  xpath_str_consts <- "
    //expr/STR_CONST
  "

  all_strings <- extract_xml_and_text(xml, xpath_str_consts)
  text_between_braces <- stringr::str_match_all(all_strings$text, "(\\{(?:\\{??[^\\{]*?\\}))")

  tryCatch({
    unlist(
      lapply(text_between_braces, function(each_text) {
        if (identical(each_text[, 2], character(0))) {
          return(NULL)
        }

        parsed_code <- parse(text = each_text[, 2], keep.source = TRUE)
        xml_parsed_code <- xml2::read_xml(xmlparsedata::xml_parse_data(parsed_code))
        objects_called <- get_object_calls(xml_parsed_code)
        functions_calls <- get_function_calls(xml_parsed_code)

        return(
          c(
            objects_called$text,
            functions_calls$text
          )
        )
      })
    )
  }, error = function(e) {
    return(NULL)
  })
}
