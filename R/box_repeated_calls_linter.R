# nolint start: line_length_linter
#' `box` library repeated imports of packages
#'
#' Checks that modules and libraries imports are not repeated.
#'
#' For use in `rhino`, see the
#' [Explanation: Rhino style guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
#' to learn about the details.
#'
#' @return A custom linter function for use with `r-lib/lintr`.
#'
#' @examples
#' \dontrun{
#' # will produce lints
#' lintr::lint(
#'   text = "box::use(packageA, packageA, packageB)",
#'   linters = box_repeated_calls_linter()
#' )
#'
#' code <- "
#' box::use(
#'   dplyr,
#'   shiny,
#' )
#'
#' box::use(
#'   dplyr,
#' )
#' "
#' lintr::lint(text = code, linters = box_repeated_calls_linter())
#'
#' code <- "
#' box::use(
#'   dplyr[mutate, select],
#'   dplyr[group_by],
#' )
#'
#' box::use(
#'   path/to/A,
#'   path/to/A[f1, f2]
#' )
#' "
#' lintr::lint(text = code, linters = box_repeated_calls_linter())
#'
#' # okay
#' code <- "
#' box::use(
#'   path/to/fileA,
#'   path/to/fileB,
#'   path/to/fileC,
#' )
#' "
#' lintr::lint(text = code, linters = box_repeated_calls_linter())
#'
#' code <- "
#' box::use(
#'   path/to/fileA,
#'   path/to/fileB[f1, f2],
#'   path/to/fileC[f3, f4],
#' )
#' "
#' lintr::lint(text = code, linters = box_repeated_calls_linter())
#'}
#' @export
# nolint end
box_repeated_calls_linter <- function() {


  # Main linter function structure
  lintr::Linter(function(source_expression) {

    # Only process full files, not partial expressions
    if (!lintr::is_lint_level(source_expression, "file")) {
      return(list())
    }

    # Get parsed XML content of the source code
    xml <- source_expression$full_xml_parsed_content

    # Find all box::use() calls using XPath
    all_imports <- find_all_imports(xml)

    # Get all imports
    # all_imports <- find_all_imports(box_use_calls)

    # Detect duplicates across all imports
    texts <- sapply(all_imports, `[[`, "text")
    dupes <- duplicated(texts)

    # Create lint objects for duplicates
    lints <- lapply(which(dupes), function(i) {
      lintr::xml_nodes_to_lints(
        all_imports[[i]]$node,
        source_expression = source_expression,
        lint_message = sprintf("Module or package '%s' is imported more than once.", texts[i]),
        type = "warning"
      )
    })

    return(lints)
  })
}

#' Find all imports from an expression
#' @param xml A xml coming usually from `source_expression$full_xml_parsed_content`
find_all_imports <- function(xml) {
  xpath_base <- "//expr[expr[SYMBOL_PACKAGE/text()='box' and SYMBOL_FUNCTION_CALL/text()='use']]"

  # Find all box::use() calls using XPath
  box_use_calls <- xml2::xml_find_all(xml, xpath_base)

  # List to store all found imports
  all_imports <- list()

  # Process each box::use() call
  for (call_node in box_use_calls) {
    # Get all arguments (import specifications)
    args <- xml2::xml_find_all(call_node, "./expr[position() > 1]")

    # Process each argument
    for (arg in args) {
      # Handle alias assignments (like tbl = tibble)
      target_nodes <- xml2::xml_find_all(arg, ".//node()")

      #' Extract components before [ bracket
      import_parts <- extract_import_parts(target_nodes)

      # Combine parts to form full import specifier
      import_text <- paste(import_parts, collapse = "")

      # Store the import text and XML node
      all_imports <- append(all_imports, list(list(text = import_text, node = arg)))
    }
  }

  all_imports
}

#' Extract components before [ bracket
#' @param target_nodes An expression of target_nodes
extract_import_parts <- function(target_nodes) {
  import_parts <- character(0)
  found_bracket <- FALSE

  for (node in target_nodes) {
    node_name <- xml2::xml_name(node)
    if (node_name %in% c("SYMBOL", "OP-SLASH")) {
      # Collect symbols and slashes for path/package
      import_parts <- c(import_parts, xml2::xml_text(node))
    } else if (node_name == "OP-LEFT-BRACKET") {
      # Stop at first [ to ignore attachments
      found_bracket <- TRUE
      break
    }
  }

  import_parts
}
