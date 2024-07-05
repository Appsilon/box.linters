test_that("ts_root returns the root node", {
  code <- "
box::use(
  stringr,
  tidyr,
)"

  ts_tree <- ts_root(code)

  expect_true(treesitter::is_node(ts_tree))
})

##### ts_find_all #####

test_that("ts_find_all(ts_query_pkg) returns box::use packages", {
  query <- ts_query_pkg

  code <- "
box::use(
  stringr,
  tidyr,
)"

  matches <- ts_find_all(ts_root(code), query)
  qty_pkgs <- 2

  expect_length(matches[[1]], qty_pkgs)
})

test_that("ts_find_all(ts_query_pkg) does not return box::use modules", {
  query <- ts_query_pkg

  code <- "
box::use(
  path/to/module_a,
  path/to/module_b,
)"

  matches <- ts_find_all(ts_root(code), query)
  qty_pkgs <- 0

  expect_length(matches[[1]], qty_pkgs)
})

test_that("ts_find_all(ts_query_pkg) does not return non box::use calls", {
  query <- ts_query_pkg

  code <- "
some_function <- function() {
  1 + 1
}"

  matches <- ts_find_all(ts_root(code), query)
  qty_pkgs <- 0

  expect_length(matches[[1]], qty_pkgs)
})

test_that("ts_find_all(ts_query_mod) returns box::use modules", {
  query <- ts_query_mod

  code <- "
box::use(
  path/to/module_a,
  path/to/module_b,
)"

  matches <- ts_find_all(ts_root(code), query)
  qty_pkgs <- 2

  expect_length(matches[[1]], qty_pkgs)
})

test_that("ts_find_all(ts_query_mod) does not return box::use packages", {
  query <- ts_query_mod

  code <- "
box::use(
  stringr,
  tidyr,
)"

  matches <- ts_find_all(ts_root(code), query)
  qty_pkgs <- 0

  expect_length(matches[[1]], qty_pkgs)
})

test_that("ts_find_all(ts_query_mod) does not return non box::use calls", {
  query <- ts_query_mod

  code <- "
some_function <- function() {
  1 + 1
}"

  matches <- ts_find_all(ts_root(code), query)
  qty_pkgs <- 0

  expect_length(matches[[1]], qty_pkgs)
})

##### get_nodes_text_by_type() #####

test_that("get_nodes_text_by_type() returns correct results in order as found", {
  query <- ts_query_pkg

  code <- "
box::use(
  tidyr,
  stringr,
)"

  matches <- ts_find_all(ts_root(code), query)
  pkgs <- get_nodes_text_by_type(matches, "pkg_name")

  expected_result <- c("tidyr", "stringr")

  expect_identical(pkgs, expected_result)
})

test_that("get_nodes_text_by_type() does not return other types", {
  query <- ts_query_pkg

  code <- "
box::use(
  tidyr,
  stringr,
  path/to/module,
)"

  matches <- ts_find_all(ts_root(code), query)
  pkgs <- get_nodes_text_by_type(matches, "pkg_name")

  expected_result <- c("tidyr", "stringr")

  expect_identical(pkgs, expected_result)
})

test_that("get_nodes_text_by_type() returns results from separate box::use() calls", {
  query <- ts_query_pkg

  code <- "
box::use(
  tidyr,
  stringr,
)

box::use(
  shiny,
)"

  matches <- ts_find_all(ts_root(code), query)
  pkgs <- get_nodes_text_by_type(matches, "pkg_name")

  expected_result <- c("tidyr", "stringr", "shiny")

  expect_identical(pkgs, expected_result)
})

##### sort_mod_pkg_calls #####

test_that("sort_mod_pkg_calls('pkg') returns sorted packages", {
  query <- ts_query_pkg

  code <- "
box::use(
  tidyr,
  dplyr,
  stringr,
)"

  matches <- ts_find_all(ts_root(code), query)
  sorted_pkgs <- sort_mod_pkg_calls(matches, "pkg")

  expected_result <- c("dplyr", "stringr", "tidyr")
  names(expected_result) <- c("", "", "")   # comments are used as names

  expect_identical(sorted_pkgs, expected_result)
})

test_that("sort_mod_pkg_calls('pkg') ignores package aliases", {
  query <- ts_query_pkg

  code <- "
box::use(
  alias = tidyr,
  dplyr,
  stringr,
)"

  matches <- ts_find_all(ts_root(code), query)
  sorted_pkgs <- sort_mod_pkg_calls(matches, "pkg")

  expected_result <- c("dplyr", "stringr", "alias = tidyr")
  names(expected_result) <- c("", "", "")   # comments are used as names

  expect_identical(sorted_pkgs, expected_result)
})

test_that("sort_mod_pkg_calls('pkg') does not touch single-line attached functions", {
  query <- ts_query_pkg

  code <- "
box::use(
  tidyr[pivot_wider, pivot_longer],
  dplyr,
  stringr,
)"

  matches <- ts_find_all(ts_root(code), query)
  sorted_pkgs <- sort_mod_pkg_calls(matches, "pkg")

  expected_result <- c("dplyr", "stringr", "tidyr[pivot_wider, pivot_longer]")
  names(expected_result) <- c("", "", "")   # comments are used as names

  expect_identical(sorted_pkgs, expected_result)
})

test_that("sort_mod_pkg_calls('pkg') does not touch multi-line attached functions", {
  query <- ts_query_pkg

  code <- "
box::use(
  tidyr[
    pivot_wider,
    pivot_longer
  ],
  dplyr,
  stringr,
)"

  matches <- ts_find_all(ts_root(code), query)
  sorted_pkgs <- sort_mod_pkg_calls(matches, "pkg")

  expected_result <- c("dplyr", "stringr", "tidyr[\n    pivot_wider,\n    pivot_longer\n  ]")
  names(expected_result) <- c("", "", "")   # comments are used as names

  expect_identical(sorted_pkgs, expected_result)
})

test_that("sort_mod_pkg_calls('pkg') returns sorted packages with comments as names", {
  query <- ts_query_pkg

  code <- "
box::use(
  tidyr[...], # nolint
  dplyr,
  stringr[...], # nolint
)"

  matches <- ts_find_all(ts_root(code), query)
  sorted_pkgs <- sort_mod_pkg_calls(matches, "pkg")

  expected_result <- c("dplyr", "stringr[...]", "tidyr[...]")
  names(expected_result) <- c("", "# nolint", "# nolint")   # comments are used as names

  expect_identical(sorted_pkgs, expected_result)
})

test_that("sort_mod_pkg_calls('pkg') does not touch multi-line attached functions comments", {
  query <- ts_query_pkg

  code <- "
box::use(
  tidyr[
    pivot_wider, # nolint
    pivot_longer
  ],
  dplyr,
  stringr,
)"

  matches <- ts_find_all(ts_root(code), query)
  sorted_pkgs <- sort_mod_pkg_calls(matches, "pkg")

  expected_result <- c(
    "dplyr",
    "stringr",
    "tidyr[\n    pivot_wider, # nolint\n    pivot_longer\n  ]"
  )
  names(expected_result) <- c("", "", "")   # comments are used as names

  expect_identical(sorted_pkgs, expected_result)
})





test_that("sort_mod_pkg_calls('mod') returns sorted modules", {
  query <- ts_query_mod

  code <- "
box::use(
  path/a/module_b,
  path/b/module_a,
  path/a/module_a,
)"

  matches <- ts_find_all(ts_root(code), query)
  sorted_mods <- sort_mod_pkg_calls(matches, "mod")

  expected_result <- c(
    "path/a/module_a",
    "path/a/module_b",
    "path/b/module_a"
  )
  names(expected_result) <- c("", "", "")   # comments are used as names

  expect_identical(sorted_mods, expected_result)
})

test_that("sort_mod_pkg_calls('mod') ignores module aliases", {
  query <- ts_query_mod

  code <- "
box::use(
  alias = path/a/module_b,
  path/b/module_a,
  path/a/module_a,
)"

  matches <- ts_find_all(ts_root(code), query)
  sorted_mods <- sort_mod_pkg_calls(matches, "mod")

  expected_result <- c(
    "path/a/module_a",
    "alias = path/a/module_b",
    "path/b/module_a"
  )
  names(expected_result) <- c("", "", "")   # comments are used as names

  expect_identical(sorted_mods, expected_result)
})

test_that("sort_mod_pkg_calls('mod') does not touch single-line attached functions", {
  query <- ts_query_mod

  code <- "
box::use(
  path/a/module_b[func_b, func_a],
  path/b/module_a,
  path/a/module_a,
)"

  matches <- ts_find_all(ts_root(code), query)
  sorted_mods <- sort_mod_pkg_calls(matches, "mod")

  expected_result <- c(
    "path/a/module_a",
    "path/a/module_b[func_b, func_a]",
    "path/b/module_a"
  )
  names(expected_result) <- c("", "", "")   # comments are used as names

  expect_identical(sorted_mods, expected_result)
})

test_that("sort_mod_pkg_calls('mod') does not touch multi-line attached functions", {
  query <- ts_query_mod

  code <- "
box::use(
  path/a/module_b[
    func_b,
    func_a
  ],
  path/b/module_a,
  path/a/module_a,
)"

  matches <- ts_find_all(ts_root(code), query)
  sorted_mods <- sort_mod_pkg_calls(matches, "mod")

  expected_result <- c(
    "path/a/module_a",
    "path/a/module_b[
    func_b,
    func_a
  ]",
    "path/b/module_a"
  )
  names(expected_result) <- c("", "", "")   # comments are used as names

  expect_identical(sorted_mods, expected_result)
})

test_that("sort_mod_pkg_calls('mod') returns sorted modules with comments as names", {
  query <- ts_query_mod

  code <- "
box::use(
  path/a/module_b[...], # nolint
  path/b/module_a,
  path/a/module_a[...], # nolint
)"

  matches <- ts_find_all(ts_root(code), query)
  sorted_mods <- sort_mod_pkg_calls(matches, "mod")

  expected_result <- c(
    "path/a/module_a[...]",
    "path/a/module_b[...]",
    "path/b/module_a"
  )
  names(expected_result) <- c("# nolint", "# nolint", "")   # comments are used as names

  expect_identical(sorted_mods, expected_result)
})

test_that("sort_mod_pkg_calls('mod') does not touch multi-line attached functions comments", {
  query <- ts_query_mod

  code <- "
box::use(
  path/a/module_b[
    func_b, # nolint
    func_a
  ],
  path/b/module_a,
  path/a/module_a,
)"

  matches <- ts_find_all(ts_root(code), query)
  sorted_mods <- sort_mod_pkg_calls(matches, "mod")

  expected_result <- c(
    "path/a/module_a",
    "path/a/module_b[
    func_b, # nolint
    func_a
  ]",
    "path/b/module_a"
  )
  names(expected_result) <- c("", "", "")   # comments are used as names

  expect_identical(sorted_mods, expected_result)
})

##### find_func_calls #####

test_that("find_func_calls() returns correct package name", {
  code_subset <- "stringr[str_trim, str_count, str_pos]"

  matches <- find_func_calls(code_subset)
  result <- get_nodes_text_by_type(matches, "pkg_mod_name")

  expected_result <- c("stringr", "stringr", "stringr")

  expect_identical(result, expected_result)
})

test_that("find_func_calls() returns correct list of attached functions from package", {
  code_subset <- "stringr[str_trim, str_count, str_pos]"

  matches <- find_func_calls(code_subset)
  result <- get_nodes_text_by_type(matches, "func_call")

  expected_result <- c("str_trim", "str_count", "str_pos")

  expect_identical(result, expected_result)
})

test_that("find_func_calls() returns correct list of aliased attached functions from package", {
  code_subset <- "stringr[str_trim, alias = str_count, str_pos]"

  matches <- find_func_calls(code_subset)
  result <- get_nodes_text_by_type(matches, "func_call")

  expected_result <- c("str_trim", "alias = str_count", "str_pos")

  expect_identical(result, expected_result)
})

test_that("find_func_calls() returns correct module path", {
  code_subset <- "path/to/module[func_c, func_a, func_b]"

  matches <- find_func_calls(code_subset)
  name_result <- get_nodes_text_by_type(matches, "pkg_mod_name")
  path_result <- get_nodes_text_by_type(matches, "mod_path")

  expected_name_result <- c("module", "module", "module")
  expect_identical(name_result, expected_name_result)

  expected_path_result <- c("path/to", "path/to", "path/to")
  expect_identical(path_result, expected_path_result)
})

test_that("find_func_calls() returns correct list of attached functions from module", {
  code_subset <- "path/to/module[func_c, func_a, func_b]"

  matches <- find_func_calls(code_subset)
  result <- get_nodes_text_by_type(matches, "func_call")

  expected_result <- c("func_c", "func_a", "func_b")

  expect_identical(result, expected_result)
})

test_that("find_func_calls() returns correct list of aliased attached functions from module", {
  code_subset <- "path/to/module[func_c, func_a, alias = func_b]"

  matches <- find_func_calls(code_subset)
  result <- get_nodes_text_by_type(matches, "func_call")

  expected_result <- c("func_c", "func_a", "alias = func_b")

  expect_identical(result, expected_result)
})

##### ts_get_start_end_rows #####

test_that("ts_get_start_end_rows() returns correct start and end rows", {
  code <- "box::use(
  stringr,
  tidyr,
)"

  ts_tree <- ts_root(code)
  result <- ts_get_start_end_rows(ts_tree)

  expected_result <- list("start" = 0, "end" = 3)
  expect_identical(result, expected_result)

  code <- "
box::use(
  stringr,
  tidyr,
)"

  ts_tree <- ts_root(code)
  result <- ts_get_start_end_rows(ts_tree)

  expected_result <- list("start" = 1, "end" = 4)
  expect_identical(result, expected_result)

  code <- "
box::use(
  stringr,
  tidyr,
  shiny,
)"

  ts_tree <- ts_root(code)
  result <- ts_get_start_end_rows(ts_tree)

  expected_result <- list("start" = 1, "end" = 5)
  expect_identical(result, expected_result)
})

##### is_single_line_func_list #####

test_that("is_single_line_func_list() returns TRUE given a single line of function attachments", {
  code_subset <- "stringr[str_trim, str_count, str_pos]"
  matches <- find_func_calls(code_subset)
  result <- is_single_line_func_list(matches[[1]])
  expect_true(result)

  code_subset <- "path/to/module[func_c, func_a, func_b]"
  matches <- find_func_calls(code_subset)
  result <- is_single_line_func_list(matches[[1]])
  expect_true(result)
})

test_that("is_single_line_func_list() returns FALSE given a multiple line function attachments", {
  code_subset <- "stringr[str_trim,
  str_count, str_pos]"
  matches <- find_func_calls(code_subset)
  result <- is_single_line_func_list(matches[[1]])
  expect_false(result)

  code_subset <- "stringr[
  str_trim,
  str_count, str_pos]"
  matches <- find_func_calls(code_subset)
  result <- is_single_line_func_list(matches[[1]])
  expect_false(result)

  code_subset <- "stringr[
  str_trim,
  str_count,
  str_pos,
]"
  matches <- find_func_calls(code_subset)
  result <- is_single_line_func_list(matches[[1]])
  expect_false(result)

  code_subset <- "path/to/module[func_c,
  func_a, func_b]"
  matches <- find_func_calls(code_subset)
  result <- is_single_line_func_list(matches[[1]])
  expect_false(result)

  code_subset <- "path/to/module[
  func_c,
  func_a, func_b]"
  matches <- find_func_calls(code_subset)
  result <- is_single_line_func_list(matches[[1]])
  expect_false(result)

  code_subset <- "path/to/module[
  func_c,
  func_a,
  func_b
]"
  matches <- find_func_calls(code_subset)
  result <- is_single_line_func_list(matches[[1]])
  expect_false(result)
})

##### build_pkg_mod_name #####

test_that("build_pkg_mod_name() returns a package name", {
  code_subset <- "stringr[str_trim, str_count, str_pos]"
  matches <- find_func_calls(code_subset)
  result <- build_pkg_mod_name(matches)
  expected_result <- "stringr"

  expect_identical(result, expected_result)
})

test_that("build_pkg_mod_name() returns a module path", {
  code_subset <- "path/to/module[func_a, func_b]"
  matches <- find_func_calls(code_subset)
  result <- build_pkg_mod_name(matches)
  expected_result <- "path/to/module"

  expect_identical(result, expected_result)
})

test_that("build_pkg_mod_name() given different path patterns returns a module path", {
  code_subset <- "path/module[func_a, func_b]"
  matches <- find_func_calls(code_subset)
  result <- build_pkg_mod_name(matches)
  expected_result <- "path/module"

  expect_identical(result, expected_result)

  code_subset <- "path/to/long/module[func_a, func_b]"
  matches <- find_func_calls(code_subset)
  result <- build_pkg_mod_name(matches)
  expected_result <- "path/to/long/module"

  expect_identical(result, expected_result)

  code_subset <- "path/to/long/longer/module[func_a, func_b]"
  matches <- find_func_calls(code_subset)
  result <- build_pkg_mod_name(matches)
  expected_result <- "path/to/long/longer/module"

  expect_identical(result, expected_result)

  code_subset <- "./module[func_a, func_b]"
  matches <- find_func_calls(code_subset)
  result <- build_pkg_mod_name(matches)
  expected_result <- "./module"

  expect_identical(result, expected_result)

  code_subset <- "../module[func_a, func_b]"
  matches <- find_func_calls(code_subset)
  result <- build_pkg_mod_name(matches)
  expected_result <- "../module"

  expect_identical(result, expected_result)
})

##### sort_func_calls #####

test_that("sort_func_call() returns a sorted package call", {
  code_subset <- "stringr[str_trim, str_count, str_pos]"
  matches <- find_func_calls(code_subset)
  result <- sort_func_calls(matches)
  expected_result <- list(
    "pkg_mod_name" = "stringr",
    "funcs" = c(
      "str_count",
      "str_pos",
      "str_trim"
    )
  )
  names(expected_result$funcs) <- c("", "", "")

  expect_identical(result, expected_result)
})

test_that("sort_func_call() given a multiple line call returns a sorted package call", {
  code_subset <- "stringr[
  str_trim,
  str_count,
  str_pos
]"
  matches <- find_func_calls(code_subset)
  result <- sort_func_calls(matches)
  expected_result <- list(
    "pkg_mod_name" = "stringr",
    "funcs" = c(
      "str_count",
      "str_pos",
      "str_trim"
    )
  )
  names(expected_result$funcs) <- c("", "", "")

  expect_identical(result, expected_result)
})

test_that("sort_func_call() given function aliases returns a sorted package call", {
  code_subset <- "stringr[
  str_trim,
  str_count,
  alias = str_pos
]"
  matches <- find_func_calls(code_subset)
  result <- sort_func_calls(matches)
  expected_result <- list(
    "pkg_mod_name" = "stringr",
    "funcs" = c(
      "str_count",
      "alias = str_pos",
      "str_trim"
    )
  )
  names(expected_result$funcs) <- c("", "", "")

  expect_identical(result, expected_result)
})

test_that("sort_func_call() returns a sorted package call with comments as funcs list names", {
  code_subset <- "stringr[
  str_trim,
  str_count, # nolint
  str_pos
]"
  matches <- find_func_calls(code_subset)
  result <- sort_func_calls(matches)
  expected_result <- list(
    "pkg_mod_name" = "stringr",
    "funcs" = c(
      "str_count",
      "str_pos",
      "str_trim"
    )
  )
  names(expected_result$funcs) <- c("# nolint", "", "")

  expect_identical(result, expected_result)
})

test_that("sort_func_call() returns a sorted module call", {
  code_subset <- "path/to/module_a[func_b, func_a, func_c]"
  matches <- find_func_calls(code_subset)
  result <- sort_func_calls(matches)
  expected_result <- list(
    "pkg_mod_name" = "path/to/module_a",
    "funcs" = c(
      "func_a",
      "func_b",
      "func_c"
    )
  )
  names(expected_result$funcs) <- c("", "", "")

  expect_identical(result, expected_result)
})

test_that("sort_func_call() given a multiple line call returns a sorted module call", {
  code_subset <- "path/to/module_a[
  func_b,
  func_a,
  func_c
]"
  matches <- find_func_calls(code_subset)
  result <- sort_func_calls(matches)
  expected_result <- list(
    "pkg_mod_name" = "path/to/module_a",
    "funcs" = c(
      "func_a",
      "func_b",
      "func_c"
    )
  )
  names(expected_result$funcs) <- c("", "", "")

  expect_identical(result, expected_result)
})

test_that("sort_func_call() given function aliases returns a sorted module call", {
  code_subset <- "path/to/module_a[
  alias = func_b,
  func_a,
  func_c
]"
  matches <- find_func_calls(code_subset)
  result <- sort_func_calls(matches)
  expected_result <- list(
    "pkg_mod_name" = "path/to/module_a",
    "funcs" = c(
      "func_a",
      "alias = func_b",
      "func_c"
    )
  )
  names(expected_result$funcs) <- c("", "", "")

  expect_identical(result, expected_result)
})

test_that("sort_func_call() returns a sorted module call with comments as func", {
  code_subset <- "path/to/module_a[
  func_b, # nolint
  func_a,
  func_c
]"
  matches <- find_func_calls(code_subset)
  result <- sort_func_calls(matches)
  expected_result <- list(
    "pkg_mod_name" = "path/to/module_a",
    "funcs" = c(
      "func_a",
      "func_b",
      "func_c"
    )
  )
  names(expected_result$funcs) <- c("", "# nolint", "")

  expect_identical(result, expected_result)
})

##### rebuild_func_calls #####

test_that("rebuild_func_calls(single_line = TRUE) returns a single line", {
  single_line <- TRUE

  sorted_func_calls <- list(
    "pkg_mod_name" = "stringr",
    "funcs" = c(
      "str_count",
      "str_pos",
      "str_trim"
    )
  )
  names(sorted_func_calls$funcs) <- c("", "", "")

  result <- rebuild_func_calls(sorted_func_calls, single_line)
  expected_result <- "stringr[str_count, str_pos, str_trim, ]"

  expect_identical(result, expected_result)
})

test_that("rebuild_func_calls(single_line = FALSE) returns multiple lines", {
  single_line <- FALSE

  sorted_func_calls <- list(
    "pkg_mod_name" = "stringr",
    "funcs" = c(
      "str_count",
      "str_pos",
      "str_trim"
    )
  )
  names(sorted_func_calls$funcs) <- c("", "", "")

  result <- rebuild_func_calls(sorted_func_calls, single_line)
  expected_result <- "stringr[
    str_count,
    str_pos,
    str_trim,
  ]"

  expect_identical(result, expected_result)
})

test_that("rebuild_func_calls(single_line = FALSE) returns multiple line with correct comments", {
  single_line <- FALSE

  sorted_func_calls <- list(
    "pkg_mod_name" = "stringr",
    "funcs" = c(
      "str_count",
      "str_pos",
      "str_trim"
    )
  )
  names(sorted_func_calls$funcs) <- c("", "# nolint", "")

  result <- rebuild_func_calls(sorted_func_calls, single_line)
  expected_result <- "stringr[
    str_count,
    str_pos, # nolint
    str_trim,
  ]"

  expect_identical(result, expected_result)
})

##### process_func_calls #####

test_that("process_func_calls() works with packages", {
  query <- ts_query_pkg

  code <- "
box::use(
  tidyr[
    pivot_wider,
    pivot_longer # nolint
  ],
  dplyr[...], # nolint
  stringr[alias = str_pos, str_cat],
  shiny
)"

  matches <- ts_find_all(ts_root(code), query)
  sorted_pkgs <- sort_mod_pkg_calls(matches, "pkg")
  result <- process_func_calls(sorted_pkgs)

  expected_result <- c(
    "dplyr[...]",
    "shiny",
    "stringr[str_cat, alias = str_pos, ]",
    "tidyr[
    pivot_longer, # nolint
    pivot_wider,
  ]"
  )
  names(expected_result) <- c("# nolint", "", "", "")  # pkg/mod level comments

  expect_identical(result, expected_result)
})

test_that("process_func_calls() works with modules", {
  query <- ts_query_mod

  code <- "
box::use(
  path/b/module[
    func_b,
    func_a # nolint
  ],
  path/a/module_a[...], # nolint
  path/a/module_c[alias = func_b, func_a],
  path/a/module_b
)"

  matches <- ts_find_all(ts_root(code), query)
  sorted_mods <- sort_mod_pkg_calls(matches, "mod")
  result <- process_func_calls(sorted_mods)

  expected_result <- c(
    "path/a/module_a[...]",
    "path/a/module_b",
    "path/a/module_c[func_a, alias = func_b, ]",
    "path/b/module[
    func_a, # nolint
    func_b,
  ]"
  )
  names(expected_result) <- c("# nolint", "", "", "") # pkg/mod level comments

  expect_identical(result, expected_result)
})

# rebuild pkg mod lines

test_that("rebuild_pkg_mod_calls() works with packages", {
  query <- ts_query_pkg

  code <- "box::use(
  tidyr[
    pivot_wider,
    pivot_longer # nolint
  ],
  dplyr[...], # nolint
  stringr[alias = str_pos, str_cat],
  shiny
)"

  matches <- ts_find_all(ts_root(code), query)
  sorted_pkgs <- sort_mod_pkg_calls(matches, "pkg")
  sorted_pkg_funcs <- process_func_calls(sorted_pkgs)
  result <- rebuild_pkg_mod_calls(sorted_pkg_funcs)

  expected_result <- "box::use(
  dplyr[...], # nolint
  shiny,
  stringr[str_cat, alias = str_pos, ],
  tidyr[
    pivot_longer, # nolint
    pivot_wider,
  ],
)"

  expect_identical(result, expected_result)
})

test_that("rebuild_pkg_mod_calls() works with modules", {
  query <- ts_query_mod

  code <- "box::use(
  path/b/module[
    func_b,
    func_a # nolint
  ],
  path/a/module_a[...], # nolint
  path/a/module_c[alias = func_b, func_a],
  path/a/module_b
)"

  matches <- ts_find_all(ts_root(code), query)
  sorted_mods <- sort_mod_pkg_calls(matches, "mod")
  sorted_mod_funcs <- process_func_calls(sorted_mods)
  result <- rebuild_pkg_mod_calls(sorted_mod_funcs)

  expected_result <- "box::use(
  path/a/module_a[...], # nolint
  path/a/module_b,
  path/a/module_c[func_a, alias = func_b, ],
  path/b/module[
    func_a, # nolint
    func_b,
  ],
)"

  expect_identical(result, expected_result)
})