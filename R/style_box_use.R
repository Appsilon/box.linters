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

  ts_mods <- ts_find_all(tree_root, ts_query_mod)
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
