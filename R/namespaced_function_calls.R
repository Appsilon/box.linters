#' Check that `namespace::function()` calls except for `box::*()` are not made.
#'
#' @param allow Character vector of `namespace` or `namespace::function` to allow in the source
#' code. Take not that the `()` are not included. The `box` namespace will always be allowed
#'
#' @examples
#' # will produce lints
#' code <- "box::use(package)
#' tidyr::pivot_longer()"
#'
#' lintr::lint(text = code, linters = namespaced_function_calls())
#'
#' ## allow `tidyr::pivot_longer()`
#' code <- "box::use(package)
#' tidyr::pivot_longer()
#' tidyr::pivot_wider()"
#'
#' lintr::lint(text = code, linters = namespaced_function_calls(allow = c("tidyr::pivot_longer")))
#'
#' # okay
#' code <- "box::use(package)"
#'
#' lintr::lint(text = code, linters = namespaced_function_calls())
#'
#' ## allow all `tidyr`
#' code <- "box::use(package)
#' tidyr::pivot_longer()
#' tidyr::pivot_wider()"
#'
#' lintr::lint(text = code, linters = namespaced_function_calls(allow = c("tidyr")))
#'
#' ## allow `tidyr::pivot_longer()`
#' code <- "box::use(package)
#' tidyr::pivot_longer()"
#'
#' lintr::lint(text = code, linters = namespaced_function_calls(allow = c("tidyr::pivot_longer")))
#'
#' @export
namespaced_function_calls <- function(allow = NULL) {
  if (!is_treesitter_installed()) {
    cli::cli_alert_warning(
      paste(
        "The packages {{treesitter}} and {{treesitter.r}} are required by",
        "namespaced_function_calls(). Please install these packages if you want to use",
        "namespaced_function_calls(). They require R version >= 4.3.0."
      )
    )
    return()
  }

  always_allow <- c("box")

  allow <- c(always_allow, allow)

  ts_query <- "
function: (namespace_operator
  lhs: (identifier) @pkg_namespace
  operator: \"::\"
  rhs: (identifier)
) @full_namespace"

  lint_message <- "Explicit `package::function()` calls are not advisible when using `box` modules."

  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "file")) {
      return(list())
    }
    source_text <- paste(source_expression$file_lines, collapse = "\n")

    tree_root <- ts_root(source_text)

    tree_namespaced <- ts_find_all(tree_root, ts_query)

    lapply(tree_namespaced[[1]], function(tree_node) {
      full_idx <- match("full_namespace", tree_node$name)
      full_text <- treesitter::node_text(tree_node$node[[full_idx]])
      pkg_idx <- match("pkg_namespace", tree_node$name)
      pkg_text <- treesitter::node_text(tree_node$node[[pkg_idx]])

      namespaced_calls <- c(full_text, pkg_text)

      if (all(!namespaced_calls %in% allow)) {
        start_where <- treesitter::node_start_point(tree_node$node[[full_idx]])
        line_number <- treesitter::point_row(start_where) + 1
        start_col_number <- treesitter::point_column(start_where) + 1
        end_where <- treesitter::node_end_point(tree_node$node[[full_idx]])
        end_col_number <- treesitter::point_column(end_where)
        lintr::Lint(
          source_expression$filename,
          line_number = line_number,
          column_number = start_col_number,
          type = "warning",
          message = lint_message,
          line = source_expression$file_lines[line_number],
          ranges = list(c(start_col_number, end_col_number))
        )
      }
    })
  })
}
