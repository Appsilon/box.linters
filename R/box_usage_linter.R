# nolint start: line_length_linter
#' `box` library-aware object usage linter
#'
#' Checks that all function and data object calls made within a source file are valid.
#' There are three ways for functions and data object calls to be come "valid". First is via base
#' R packages. Second is via local declaration/definition. The third is via `box::use()` attachment.
#'
#' For use in `rhino`, see the
#' [Explanation: Rhino style guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
#' to learn about the details.
#'
#' @return A custom linter function for use with `r-lib/lintr`.
#'
#' @examples
#' \dontrun{
#' box::use(
#'   dplyr[`%>%`, filter, pull],
#'   stringr,
#' )
#'
#' mpg <- mtcars %>%
#'   filter(mpg <= 10) %>%
#'   pull(mpg)
#'
#' mpg <- mtcars %>%
#'   filter(mpg <= 10) %>%
#'   select(mpg)             # will lint
#'
#' trimmed_string <- stringr$str_trim("  some string  ")
#' trimmed_string <- stringr$strtrim("  some string  ")     # will lint
#'
#' existing_function <- function(x, y, z) {
#'   mean(c(x, y, z))
#' }
#'
#' existing_function(1, 2, 3)
#' non_existing_function(1, 2, 3)     # will lint
#'
#' average(1, 2, 3)       # will lint
#' }
#'
#' @export
# nolint end
box_usage_linter <- function() {
  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "file")) {
      return(list())
    }

    xml <- source_expression$full_xml_parsed_content

    attached_pkg_functions <- get_attached_pkg_functions(xml)
    attached_pkg_three_dots <- get_attached_pkg_three_dots(xml)
    all_attached_pkg_fun <- c(attached_pkg_functions$text, attached_pkg_three_dots$text)

    attached_mod_functions <- get_attached_mod_functions(xml)
    attached_mod_three_dots <- get_attached_mod_three_dots(xml)
    all_attached_mod_fun <- c(attached_mod_three_dots$text, attached_mod_functions$text)

    fun_assignments <- get_declared_functions(xml)
    obj_assignments <- get_declared_objects(xml)
    fun_sig_objects <- get_function_signature_objs(xml)
    all_known_fun <- c(all_attached_pkg_fun,
                       all_attached_mod_fun,
                       fun_assignments$text,
                       fun_sig_objects$text,
                       obj_assignments$text)

    attached_packages <- get_attached_packages(xml)
    attached_modules <- get_attached_modules(xml)
    all_attached_pkg_mod_aliases <- c(attached_packages$aliases, attached_modules$aliases)
    all_attached_box_mods <- c(attached_packages$text, attached_modules$text)
    all_attached_pkg_mod_fun_flat <- c(unlist(attached_packages$nested),
                                       unlist(attached_modules$nested))
    base_pkgs <- get_base_packages()
    function_calls <- get_function_calls(xml)

    lapply(function_calls$xml_nodes, function(fun_call) {
      fun_call_text <- xml2::xml_text(fun_call)

      if (!fun_call_text %in% base_pkgs$text) {
        if (grepl(".+\\$.+", fun_call_text)) {
          if (!fun_call_text %in% all_attached_box_mods) {
            split_call_names <- strsplit(fun_call_text, "\\$")[[1]]
            pkg_mod_name_called <- split_call_names[1]
            function_name_called <- split_call_names[2]
            if (xor(pkg_mod_name_called %in% all_attached_pkg_mod_aliases,
                    function_name_called %in% all_attached_pkg_mod_fun_flat)) {
              lintr::xml_nodes_to_lints(
                fun_call,
                source_expression = source_expression,
                lint_message = "<package/module>$function does not exist.",
                type = "warning"
              )
            }
          }
        } else {
          if (!fun_call_text %in% all_known_fun) {
            lintr::xml_nodes_to_lints(
              fun_call,
              source_expression = source_expression,
              lint_message = "Function not imported nor defined.",
              type = "warning"
            )
          }
        }
      }
    })
  })
}

get_base_packages <- function() {
  base_pkgs_names <- utils::sessionInfo()$basePkgs
  base_pkgs_funs <- get_packages_exports(base_pkgs_names)
  base_pkgs_funs_flat <- unlist(base_pkgs_funs, use.names = FALSE)

  list(
    nested = base_pkgs_funs,
    text = base_pkgs_funs_flat
  )
}
