test_that("ts_root returns the root node", {
  code <- "
box::use(
  stringr,
  tidyr,
)"

  ts_tree <- ts_root(code)

  testthat::expect_true(treesitter::is_node(ts_tree))
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

##### is_single_line_func_list #####

##### sort_func_calls #####

##### process_func_calls #####
