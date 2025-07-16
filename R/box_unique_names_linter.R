# nolint start: line_length_linter
#' `box` calls duplicate object names linter
#'
#' This linter detects and warns about duplicate object names introduced via
#' `box::use()` calls from the `box` package. It catches duplicate package and
#' module names. It also catches repeated use of the same alias or function name across packages
#' or modules, including conflicts between explicitly imported functions and wildcard (`...`)
#' imports.
#'
#' This ensures that all names introduced via `box::use()` are unique in the
#' current namespace, helping to avoid accidental overwrites and unexpected
#' behavior.
#'
#' The linter supports the following `box::use()` import types:
#' - Packages
#' - Source modules
#' - Individual functions
#' - Wildcard (`...`) imports from packages or modules
#' - Aliased imports (e.g. `alias = package` or `alias = function`)
#'
#' @examples
#' \dontrun{
#' # will produce lints
#' box::use(
#'   app/logic/module,
#'   app/view/module,
#' )
#'
#' box::use(
#'   alias = app/logic/logic_module,
#'   alias = app/view/view_module,
#' )
#'
#' box::use(
#'   dplyr[filter],
#'   stats[filter],
#' )
#'
#' box::use(
#'   dplyr[filter],
#'   stats[...],
#' )
#'
#' box::use(
#'   alias = dplyr,
#'   stats[alias = filter],
#' )
#'
#' }
#' @export
# nolint end
box_unique_names_linter <- function() {
  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "file")) {
      return(list())
    }

    xml <- source_expression$full_xml_parsed_content

    attached_packages <- get_attached_packages(xml)
    attached_pkg_functions <- get_attached_pkg_functions(xml)
    attached_pkg_three_dots <- get_attached_pkg_three_dots(xml)

    attached_modules <- get_attached_modules(xml)
    attached_mod_functions <- get_attached_mod_functions(xml)
    attached_mod_three_dots <- get_attached_mod_three_dots(xml)

    combined_pkgs_mods_and_funs <- list()
    combined_pkgs_mods_and_funs$xml <- c(
      attached_packages$xml,
      attached_pkg_functions$xml,
      attached_modules$xml,
      attached_mod_functions$xml
    )
    class(combined_pkgs_mods_and_funs$xml) <- "xml_nodeset"
    combined_pkgs_mods_and_funs$aliases <- c(
      attached_packages$aliases,
      attached_pkg_functions$text,
      attached_modules$aliases,
      attached_mod_functions$text
    )
    duped_combined_pkgs_mods_funs <- duplicated(combined_pkgs_mods_and_funs$aliases)

    combined_funs_and_three_dots <- list()
    combined_funs_and_three_dots$xml <- c(
      attached_pkg_functions$xml,
      attached_pkg_three_dots$xml,
      attached_mod_functions$xml,
      attached_mod_three_dots$xml
    )
    class(combined_funs_and_three_dots$xml) <- "xml_nodeset"
    combined_funs_and_three_dots$text <- c(
      attached_pkg_functions$text,
      attached_pkg_three_dots$nested,
      attached_mod_functions$text,
      attached_mod_three_dots$nested
    )
    duped_comb_funs_and_three_dots <- cross_duplicated_values(
      combined_funs_and_three_dots$text
    )

    duplicate_pkgs_mods_functions <- Map(
      function(a, b) list("xml" = a, "text" = b),
      combined_pkgs_mods_and_funs$xml,
      combined_pkgs_mods_and_funs$aliases
    )[duped_combined_pkgs_mods_funs]

    duplicate_functions_three_dots <- Map(
      function(a, b) list("xml" = a, "text" = b),
      combined_funs_and_three_dots$xml,
      duped_comb_funs_and_three_dots$values
    )[duped_comb_funs_and_three_dots$flags]

    duped_import_combined_nodes <- unique(
      c(
        duplicate_pkgs_mods_functions,
        duplicate_functions_three_dots
      )
    )

    lapply(duped_import_combined_nodes, function(duplicate_node) {
      lint_name <- paste(duplicate_node$text, collapse = ", ")
      lintr::xml_nodes_to_lints(
        duplicate_node$xml,
        source_expression = source_expression,
        lint_message = glue::glue("Duplicated box-attached object: {lint_name}."),
        type = "warning"
      )
    })
  })
}

#' Identify Cross-Duplicated Values Across Vectors
#'
#' This function checks for duplicate values across a list of vectors.
#' It identifies whether each vector contains values that have already appeared
#' in any of the previous vectors in the list.
#'
#' @param vecs A list of atomic vectors. Each element of the list should be a vector
#'   (e.g., character, numeric, etc.) to check for cross-duplicates.
#'
#' @return A list with two elements:
#' \describe{
#'   \item{flags}{A logical vector indicating whether each vector contains any values that are duplicates of those in previous vectors.}
#'   \item{values}{A list of vectors containing the duplicated values (if any) for each input vector.}
#' }
#'
#' @examples
#' cross_duplicated_values(list(
#'   c("a", "b", "c"),
#'   c("d", "b", "e"),
#'   c("f", "g", "a"),
#'   c("h", "i", "j")
#' ))
#' # $flags
#' # [1] FALSE TRUE TRUE FALSE
#' #
#' # $values
#' # [[1]]
#' # character(0)
#' #
#' # [[2]]
#' # [1] "b"
#' #
#' # [[3]]
#' # [1] "a"
#' #
#' # [[4]]
#' # character(0)
cross_duplicated_values <- function(vecs) {
  result <- purrr::map(seq_along(vecs), function(i) {
    if (i == 1) {
      list(flag = FALSE, duplicates = character(0))
    } else {
      previous <- unlist(vecs[1:(i - 1)], use.names = FALSE)
      current <- vecs[[i]]
      duplicated_vals <- unique(current[current %in% previous])
      list(flag = length(duplicated_vals) > 0, duplicates = duplicated_vals)
    }
  })

  list(
    flags = purrr::map_lgl(result, "flag"),
    values = purrr::map(result, "duplicates")
  )
}
