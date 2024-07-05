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
#' @param indent_spaces Number of spaces per indent level
#' @export
style_box_use_text <- function(text, indent_spaces = 2) {
  tree_root <- ts_root(text)

  ts_pkgs <- ts_find_all(tree_root, ts_query_pkg)
  sorted_pkgs <- sort_mod_pkg_calls(ts_pkgs, "pkg")
  sorted_pkg_funcs <- process_func_calls(sorted_pkgs, indent_spaces)
  box_use_pkgs <- rebuild_pkg_mod_calls(sorted_pkg_funcs, indent_spaces)

  ts_mods <- ts_find_all(tree_root, ts_query_mod)
  sorted_mods <- sort_mod_pkg_calls(ts_mods, "mod")
  sorted_mod_funcs <- process_func_calls(sorted_mods, indent_spaces)
  box_use_mods <- rebuild_pkg_mod_calls(sorted_mod_funcs, indent_spaces)

  cat(sprintf("%s\n\n%s", box_use_pkgs, box_use_mods))

  invisible(
    list(
      pkgs = box_use_pkgs,
      mods = box_use_mods
    )
  )
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
      "mod_path",
      "pkg_call",
      "pkg_mod_name",
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

#' @keywords internal
find_func_calls <- function(pkg_mod_call) {
  pkg_mod_tree <- ts_root(pkg_mod_call)
  ts_find_all(pkg_mod_tree, ts_query_funcs)
}

#' @keywords internal
ts_get_start_end_rows <- function(node) {
  start_row <- treesitter::point_row(
    treesitter::node_start_point(node)
  )
  end_row <- treesitter::point_row(
    treesitter::node_end_point(node)
  )

  list(
    "start" = start_row,
    "end" = end_row
  )
}

#' @keywords internal
is_single_line_func_list <- function(pkg_mod_call) {
  first_item <- pkg_mod_call[[1]]
  idx_full_call <- match("full_call", first_item$name)
  node <- first_item$node[[idx_full_call]]
  rows <- ts_get_start_end_rows(node)
  rows$start == rows$end
}

#' @keywords internal
build_pkg_mod_name <- function(call_with_funcs) {
  unique_mod_path <- unique(
    get_nodes_text_by_type(call_with_funcs, "mod_path")
  )
  unique_pkg_mod_name <- unique(
    get_nodes_text_by_type(call_with_funcs, "pkg_mod_name")
  )

  if (length(unique_mod_path) > 1) {
    stop("multiple mod_paths found in one module call")
  }

  if (length(unique_pkg_mod_name) > 1) {
    stop("multiple package or module names found in one call")
  }

  path_prefix <- ""
  if (nchar(unique_mod_path) > 0) {
    path_prefix <- sprintf("%s/", unique_mod_path)
  }

  sprintf("%s%s", path_prefix, unique_pkg_mod_name)
}

#' @keywords internal
sort_func_calls <- function(call_with_funcs) {
  pkg_mod_name <- build_pkg_mod_name(call_with_funcs)
  func_names <- get_nodes_text_by_type(call_with_funcs, "func_name")
  func_calls <- get_nodes_text_by_type(call_with_funcs, "func_call")
  comments <- get_nodes_text_by_type(call_with_funcs, "comment")
  names(func_calls) <- comments

  order_func_names <- order(func_names)
  list(
    pkg_mod_name = pkg_mod_name,
    funcs = func_calls[order_func_names]
  )
}

#' @keywords internal
rebuild_func_calls <- function(func_calls, single_line = c(TRUE, FALSE), indent_spaces = 2) {
  if (single_line) {
    func_calls_comma <- sprintf("%s, ", func_calls$funcs)
    flat_func_calls <- paste0(func_calls_comma, collapse = "")
    sprintf("%s[%s]", func_calls$pkg_mod_name, flat_func_calls)
  } else {
    names(func_calls$funcs) <- ifelse(
      nchar(names(func_calls$funcs)) > 0,
      sprintf(" %s", names(func_calls$funcs)),
      names(func_calls$funcs)
    )

    func_calls_comma_line <- sprintf(
      "%s%s,%s",
      strrep(' ', 2 * indent_spaces),
      func_calls$funcs,
      names(func_calls$funcs)
    )
    flat_func_calls <- paste0(func_calls_comma_line, collapse = "\n")
    sprintf(
      "%s[\n%s\n%s]",
      func_calls$pkg_mod_name,
      flat_func_calls,
      strrep(' ', indent_spaces)
    )
  }
}

#' @keywords internal
process_func_calls <- function(pkg_mod_calls, indent_spaces = 2) {
  result <- lapply(pkg_mod_calls, function(call_item) {
    matches <- find_func_calls(call_item)
    if (rlang::is_empty(matches[[1]])) {
      call_item
    } else {
      sorted_func_calls <- sort_func_calls(matches)
      single_line <- is_single_line_func_list(matches[[1]])
      rebuild_func_calls(sorted_func_calls, single_line, indent_spaces)
    }
  })

  unlist(result)
}

#' @keywords internal
rebuild_pkg_mod_calls <- function(pkg_mod_calls, indent_spaces = 2) {
  names(pkg_mod_calls) <- ifelse(
    nchar(names(pkg_mod_calls)) > 0,
    sprintf(" %s", names(pkg_mod_calls)),
    names(pkg_mod_calls)
  )

  pkg_mod_calls_comma_line <- sprintf(
    "%s%s,%s",
    strrep(' ', indent_spaces),
    pkg_mod_calls,
    names(pkg_mod_calls)
  )
  flat_pkg_mod_calls <- paste0(pkg_mod_calls_comma_line, collapse = "\n")
  sprintf(
    "box::use(\n%s\n)",
    flat_pkg_mod_calls
  )
}
