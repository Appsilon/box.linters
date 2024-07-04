#' Style the box::use() calls of a source code
#'
#' @param filename A file to style.
#' @param run_styler Boolean to run styler::style_file() at the end of `box::use()` styling.
#' @export
style_box_use_file <- function(filename, run_styler = FALSE) {
  source_file_lines <- xfun::read_utf8(filename)

  style_box_use_text(paste(source_file_lines, collapse = "\n"))
}

#' Style the box::use() calls of source code text
#'
#' @param text Source code in text format
#' @export
style_box_use_text <- function(text) {
  tree_root <- ts_root(text)

  ts_pkgs <- ts_find_all(tree_root, ts_query_pkg)
  sorted_pkgs <- sort_mod_pkg_calls(ts_pkgs, "pkg")

  ts_mods <- ts_find_all(tree_root, ts_query_mod)
  sorted_mods <- sort_mod_pkg_calls(ts_mods, "mod")
}

#' @keywords internal
ts_root <- function(source_text) {
  ts_parser <- treesitter::parser(treesitter.r::language())
  parsed_tree <- treesitter::parser_parse(ts_parser, source_text)
  treesitter::tree_root_node(parsed_tree)
}

#' @keywords internal
ts_find_all <- function(tree, query) {
  query <- treesitter::query(treesitter.r::language(), query)
  treesitter::query_matches(query, tree)
}

#' @keywords internal
get_nodes_text_by_type <- function(
    items,
    type = c(
      "comment",
      "full_path",
      "func_call",
      "func_name",
      "mod_call",
      "pkg_call",
      "pkg_name"
    )
) {
  type <- match.arg(type)
  results <- lapply(items[[1]], function(item) {
    idx_pkg <- match(type, item$name)
    if (treesitter::is_node(item$node[[idx_pkg]])) {
      treesitter::node_text(item$node[[idx_pkg]])
    } else {
      ""
    }
  })

  unlist(results)
}

#' @keywords internal
sort_mod_pkg_calls <- function(tree_matches, pkg_or_mod = c("mod", "pkg")) {
  pkg_or_mod <- match.arg(pkg_or_mod)
  switch (pkg_or_mod,
          "mod" = {
            node_names <- "full_path"
            node_calls <- "mod_call"
          },
          "pkg" = {
            node_names <- "pkg_name"
            node_calls <- "pkg_call"
          }
  )

  attached_names <- get_nodes_text_by_type(tree_matches, node_names)
  order_attached_names <- order(attached_names)
  attached_calls <- get_nodes_text_by_type(tree_matches, node_calls)
  comments <- get_nodes_text_by_type(tree_matches, "comment")
  names(attached_calls) <- comments

  attached_calls[order_attached_names]
}
