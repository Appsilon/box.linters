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

  glue_open <- getOption("glue.open", default = "\\{")
  glue_close <- getOption("glue.close", default = "\\}")

  all_strings$text <- gsub(glue_open, "{", all_strings$text)
  all_strings$text <- gsub(glue_close, "}", all_strings$text)

  text_between_braces <- stringr::str_match_all(all_strings$text, "(\\{(?:\\{??[^\\{]*?\\}))")

  tryCatch({
    unlist(
      lapply(text_between_braces, function(each_text) {
        if (identical(each_text[, 2], character(0))) {
          return(NULL)
        }

        text_to_parse <- each_text[substr(each_text[, 2], 1, 2) != "{{", 2]
        parsed_code <- parse(text = text_to_parse, keep.source = TRUE)
        xml_parsed_code <- xml2::read_xml(xmlparsedata::xml_parse_data(parsed_code))
        objects_called <- get_object_calls(xml_parsed_code)
        functions_calls <- get_function_calls(xml_parsed_code)
        special_calls <- get_special_calls(xml_parsed_code)

        c(
          objects_called$text,
          functions_calls$text,
          special_calls$text
        )
      })
    )
  }, error = function(e) {
    NULL
  })
}
