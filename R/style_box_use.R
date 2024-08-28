#' Style the box::use() calls for a directory
#'
#' @param path Path to a directory with files to style.
#' @param recursive A logical value indicating whether or not files in sub-directories
#' @param exclude_files A character vector of regular expressions to exclude files (not paths)
#' from styling.
#' @param exclude_dirs A character vector of directories to exclude.
#' @param indent_spaces An integer scalar indicating tab width in units of spaces
#' @param trailing_commas_func A boolean to activate adding a trailing comma to the end of the lists
#' of functions to attach.
#'
#' @details
#' Refer to [style_box_use_text()] for styling details.
#'
#' @examples
#' \dontrun{
#' style_box_use_dir("path/to/dir")
#'
#' # to exclude `__init__.R` files from styling
#' style_box_use_dir("path/to/dir", exclude_files = c("__init__\\.R"))
#' }
#'
#' @export
style_box_use_dir <- function(
  path = ".",
  recursive = TRUE,
  exclude_files = c(),
  exclude_dirs = c("packrat", "renv"),
  indent_spaces = 2,
  trailing_commas_func = FALSE
) {
  check_treesitter_installed()
  changed <- withr::with_dir(
    path,
    style_box_use_files(recursive, exclude_files, exclude_dirs, indent_spaces, trailing_commas_func)
  )

  total_files_looked_at <- length(changed)
  changed_files <- names(which(unlist(changed)))
  unchanged_files <- total_files_looked_at - length(changed_files)

  if (length(changed_files) > 0) {
    cli::cli_warn("Please review the modifications made.
    Comments near box::use() are moved to the top of the file.")

    cat("Modified the following files:\n")
    cli::cli_bullets(changed_files)
  }

  cli::cat_rule()
  cat("Count\tLegend\n")
  cat(unchanged_files, "\tFile/s unchanged.\n")
  cat(length(changed_files), "\tFile/s changed.\n")
  cli::cat_rule()

  invisible(changed)
}

#' @keywords internal
style_box_use_files <- function(
  recursive,
  exclude_files,
  exclude_dirs,
  indent_spaces,
  trailing_commas_func
) {
  regex_excluded_dirs <- paste(exclude_dirs, collapse = "|")
  files <- fs::dir_ls(".", regexp = "\\.[rR]$", recurse = recursive, all = FALSE)
  files <- files[stringr::str_starts(files, regex_excluded_dirs, negate = TRUE)]

  if (!is.null(exclude_files)) {
    regex_excluded_files <- paste(exclude_files, collapse = "|")
    files <- files[stringr::str_ends(files, regex_excluded_files, negate = TRUE)]
  }

  purrr::map(files, transform_file, indent_spaces, trailing_commas_func)
}

#' Style the box::use() calls of a source code
#'
#' @param filename A file path to style.
#' @param indent_spaces An integer scalar indicating tab width in units of spaces
#' @param trailing_commas_func A boolean to activate adding a trailing comma to the end of the lists
#' of functions to attach.
#' @details
#' Refer to [style_box_use_text()] for styling details.
#'
#' @examples
#' code <- "box::use(stringr[str_trim, str_pad], dplyr)"
#' file <- tempfile("style", fileext = ".R")
#' writeLines(code, file)
#'
#' style_box_use_file(file)
#'
#' @export
style_box_use_file <- function(filename, indent_spaces = 2, trailing_commas_func = FALSE) {
  check_treesitter_installed()
  transformed_file <- transform_file(filename, indent_spaces, trailing_commas_func)

  if (!isFALSE(transformed_file)) {
    cli::cli_warn("`{filename}` was modified. Please review the modifications made.
                  Comments near box::use() are moved to the top of the file.")
  } else {
    cli::cli_inform("Nothing to modify in `{filename}`.")
  }
}

#' @keywords internal
transform_file <- function(filename, indent_spaces, trailing_commas_func) {
  normal_filename <- normalizePath(filename)
  source_file_lines <- xfun::read_utf8(normal_filename)

  box_lines <- find_box_lines(paste(source_file_lines, collapse = "\n"))
  if (length(box_lines$all) == 0) {
    return(FALSE)
  }
  retain_lines <- find_source_lines_to_retain(source_file_lines, box_lines)

  transformed_box_use <- transform_box_use_text(
    paste(source_file_lines, collapse = "\n"),
    indent_spaces,
    trailing_commas_func
  )

  new_source_lines <- rebuild_source_file(source_file_lines, retain_lines, transformed_box_use)

  was_changed <- !identical(source_file_lines, new_source_lines)

  if (was_changed) {
    xfun::write_utf8(new_source_lines, filename)
    TRUE
  } else {
    FALSE
  }
}

#' Style the box::use() calls of source code text
#'
#' Styles `box::use()` calls.
#' * All packages are called under one `box::use()`.
#' * All modules are called under one `box::use()`.
#' * Package and module levels are re-formatted to multiple lines. One package per line.
#' * Packages and modules are sorted alphabetically, ignoring the aliases.
#' * Functions attached in a single line retain the single line format.
#' * Functions attached in multiple lines retain the multiple line format.
#' * Functions are sorted alphabetically, ignoring the aliases.
#' * A trailing comma is added to packages, modules, and functions.
#'
#' @param text Source code in text format
#' @param indent_spaces Number of spaces per indent level
#' @param trailing_commas_func A boolean to activate adding a trailing comma to the end of the lists
#' of functions to attach.
#' @param colored Boolean. For syntax highlighting using \{prettycode\}
#' @param style A style from \{prettycode\}
#'
#' @examples
#' code <- "box::use(stringr[str_trim, str_pad], dplyr)"
#'
#' style_box_use_text(code)
#'
#' code <- "box::use(stringr[
#'   str_trim,
#'   str_pad
#' ],
#' shiny[...], # nolint
#' dplyr[alias = select, mutate], alias = tidyr
#' path/to/module)
#' "
#'
#' style_box_use_text(code)
#'
#' style_box_use_text(code, trailing_commas_func = TRUE)
#'
#' @export
style_box_use_text <- function(
  text,
  indent_spaces = 2,
  trailing_commas_func = FALSE,
  colored = getOption("styler.colored_print.vertical", default = FALSE),
  style = prettycode::default_style()
) {
  check_treesitter_installed()
  source_text_lines <- stringr::str_split_1(text, "\n")

  box_lines <- find_box_lines(text)
  if (length(box_lines$all) == 0) {
    cli::cli_alert_info("No `box::use()` calls found. No changes were made to the text.")
    return(invisible(text))
  }
  retain_lines <- find_source_lines_to_retain(source_text_lines, box_lines)

  transformed_text <- transform_box_use_text(text, indent_spaces, trailing_commas_func)

  new_source_lines <- rebuild_source_file(source_text_lines, retain_lines, transformed_text)

  was_changed <- !identical(source_text_lines, new_source_lines)

  if (was_changed) {
    if (colored) {
      if (!rlang::is_empty(find.package("prettycode", quiet = TRUE))) {
        new_source_lines <- prettycode::highlight(new_source_lines, style = style)
      } else {
        cli::cli_warn(
          paste(
            "Could not use `colored = TRUE`, as the package `{{prettycode}}` was not found.",
            "Please install it if you want colored output."
          )
        )
      }
    }

    cat(new_source_lines, sep = "\n")
    cli::cli_warn("Changes were made. Please review the modifications made.
                  Comments near box::use() are moved to the top of the file.")
  } else {
    cli::cli_inform("No changes were made to the text.")
  }
}

#' @keywords internal
transform_box_use_text <- function(text, indent_spaces = 2, trailing_commas_func = FALSE) {
  tree_root <- ts_root(text)

  box_use_pkgs <- character(0)
  ts_pkgs <- ts_find_all(tree_root, ts_query_pkg)
  if (!rlang::is_empty(ts_pkgs[[1]])) {
    sorted_pkgs <- sort_mod_pkg_calls(ts_pkgs, "pkg")
    sorted_pkg_funcs <- process_func_calls(sorted_pkgs, indent_spaces, trailing_commas_func)
    box_use_pkgs <- rebuild_pkg_mod_calls(sorted_pkg_funcs, indent_spaces)
  }

  box_use_mods <- character(0)
  ts_mods <- ts_find_all(tree_root, ts_query_mod)
  if (!rlang::is_empty(ts_mods[[1]])) {
    sorted_mods <- sort_mod_pkg_calls(ts_mods, "mod")
    sorted_mod_funcs <- process_func_calls(sorted_mods, indent_spaces, trailing_commas_func)
    box_use_mods <- rebuild_pkg_mod_calls(sorted_mod_funcs, indent_spaces)
  }

  list(
    pkgs = box_use_pkgs,
    mods = box_use_mods
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
  switch(
    pkg_or_mod,
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
rebuild_func_calls <- function(
  func_calls,
  single_line = c(TRUE, FALSE),
  indent_spaces = 2,
  trailing_commas_func = FALSE
) {
  if (single_line) {
    func_calls_comma <- func_calls$funcs
    if (trailing_commas_func) {
      func_calls_comma <- c(func_calls$funcs, "")
    }
    flat_func_calls <- paste0(func_calls_comma, collapse = ", ")
    sprintf("%s[%s]", func_calls$pkg_mod_name, flat_func_calls)
  } else {
    names(func_calls$funcs) <- ifelse(
      nchar(names(func_calls$funcs)) > 0,
      sprintf(" %s", names(func_calls$funcs)),
      names(func_calls$funcs)
    )

    func_calls_indent <- sprintf(
      "%s%s",
      strrep(" ", 2 * indent_spaces),
      func_calls$funcs
    )
    if (trailing_commas_func) {
      func_calls_indent <- c(func_calls_indent, "")
    }
    func_calls_comma_lines <- paste(func_calls_indent, collapse = ",\n")
    func_calls_commas <- stringr::str_split_1(func_calls_comma_lines, "\n")
    func_calls_commas_comments <- paste0(
      func_calls_commas[seq_along(func_calls$funcs)],
      names(func_calls$funcs)
    )

    flat_func_calls <- paste0(func_calls_commas_comments, collapse = "\n")
    sprintf(
      "%s[\n%s\n%s]",
      func_calls$pkg_mod_name,
      flat_func_calls,
      strrep(" ", indent_spaces)
    )
  }
}

#' @keywords internal
process_func_calls <- function(pkg_mod_calls, indent_spaces = 2, trailing_commas_func = FALSE) {
  result <- lapply(pkg_mod_calls, function(call_item) {
    matches <- find_func_calls(call_item)
    if (rlang::is_empty(matches[[1]])) {
      call_item
    } else {
      sorted_func_calls <- sort_func_calls(matches)
      single_line <- is_single_line_func_list(matches[[1]])
      rebuild_func_calls(sorted_func_calls, single_line, indent_spaces, trailing_commas_func)
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
    strrep(" ", indent_spaces),
    pkg_mod_calls,
    names(pkg_mod_calls)
  )
  flat_pkg_mod_calls <- paste0(pkg_mod_calls_comma_line, collapse = "\n")
  sprintf(
    "box::use(\n%s\n)",
    flat_pkg_mod_calls
  )
}

#' @keywords internal
get_box_lines <- function(ts_box_use) {
  result <- lapply(ts_box_use[[1]], function(item) {
    idx <- match("box_call", item$name)
    node <- item$node[[idx]]
    rows <- ts_get_start_end_rows(node)
    seq(rows$start, rows$end)
  })
  unlist(result)
}

#' @keywords internal
find_box_lines <- function(source_text) {
  source_tree <- ts_root(source_text)
  ts_box_use_calls <- ts_find_all(source_tree, ts_query_box_use)
  box_lines <- get_box_lines(ts_box_use_calls) + 1
  if (rlang::is_empty(box_lines)) {
    list(
      "all" = box_lines,
      "min" = -1,
      "max" = -1
    )
  } else {
    list(
      "all" = box_lines,
      "min" = min(box_lines),
      "max" = max(box_lines)
    )
  }
}

#' @keywords internal
find_source_lines_to_retain <- function(source_file_lines, box_lines) {
  source_lines <- seq(1, length(source_file_lines))
  empty_source_lines <- which(grepl(pattern = "^[:space:]*$", source_file_lines))
  non_box_lines <- source_lines[!source_lines %in% box_lines$all]
  end_of_box_calls <- ifelse(
    empty_source_lines[empty_source_lines > box_lines$max][1] == box_lines$max + 1,
    box_lines$max + 1,
    box_lines$max
  )
  lines_before_box <- non_box_lines[
    !non_box_lines %in% empty_source_lines &
      non_box_lines < box_lines$max
  ]
  lines_after_box <- non_box_lines[non_box_lines > end_of_box_calls]

  list(
    "before" = lines_before_box,
    "after" = lines_after_box
  )
}

#' @keywords internal
rebuild_source_file <- function(source_file_lines, retain_lines, transformed_box_use) {
  box_use_pkgs <- character(0)
  if (!rlang::is_empty(transformed_box_use$pkgs)) {
    box_use_pkgs <- c(
      stringr::str_split_1(transformed_box_use$pkgs, "\n"),
      ""
    )
  }

  box_use_mods <- character(0)
  if (!rlang::is_empty(transformed_box_use$mods)) {
    box_use_mods <- c(
      stringr::str_split_1(transformed_box_use$mods, "\n"),
      ""
    )
  }

  output <- c(
    source_file_lines[retain_lines$before],
    box_use_pkgs,
    box_use_mods,
    source_file_lines[retain_lines$after]
  )
  unlist(output)
}

#' @keywords internal
check_treesitter_installed <- function() {
  if (!is_treesitter_installed()) {
    cli::cli_abort(
      paste(
        "The packages {{treesitter}} and {{treesitter.r}} are required for styling.",
        "Please install these packages to perform styling. They require R version >= 4.3.0."
      )
    )
  }
}

#' Check if treesitter and dependencies are installed
#'
#' Treesitter required R >= 4.3.0. Treesitter is required by a few `{box.linters}` functions.
#'
#'
#' @examples
#' \dontrun{
#'
#' # Bare environment
#'
#' is_treesitter_installed()
#' #> [1] FALSE
#'
#' install.packages(c("treesitter", "treesitter.r"))
#' is_treesitter_installed()
#' #> [1] TRUE
#' }
#'
#' @return Logical TRUE/FALSE if the `treesitter` dependencies exist.
#' @export
is_treesitter_installed <- function() {
  treesitter_pkgs <- c("treesitter", "treesitter.r")
  length(find.package(treesitter_pkgs, quiet = TRUE)) >= length(treesitter_pkgs)
}
