test_that("ts_root returns the root node", {
  code <- "
box::use(
  stringr,
  tidyr,
)"

  ts_tree <- ts_root(code)

  testthat::expect_true(treesitter::is_node(ts_tree))
})

test_that("ts_find_all(ts_query_pkg) returns box::use packages", {
  query <- ts_query_pkg

  code <- "
box::use(
  stringr,
  tidyr,
)"

  pkg_nodes <- ts_find_all(ts_root(code), query)
  qty_pkgs <- 2

  expect_length(pkg_nodes[[1]], qty_pkgs)
})

test_that("ts_find_all(ts_query_pkg) does not return box::use modules", {
  query <- ts_query_pkg

  code <- "
box::use(
  path/to/module_a,
  path/to/module_b,
)"

  pkg_nodes <- ts_find_all(ts_root(code), query)
  qty_pkgs <- 0

  expect_length(pkg_nodes[[1]], qty_pkgs)
})

test_that("ts_find_all(ts_query_pkg) does not return non box::use calls", {
  query <- ts_query_pkg

  code <- "
some_function <- function() {
  1 + 1
}"

  pkg_nodes <- ts_find_all(ts_root(code), query)
  qty_pkgs <- 0

  expect_length(pkg_nodes[[1]], qty_pkgs)
})


test_that("ts_find_all(ts_query_mod) returns box::use modules", {
  query <- ts_query_mod

  code <- "
box::use(
  path/to/module_a,
  path/to/module_b,
)"

  pkg_nodes <- ts_find_all(ts_root(code), query)
  qty_pkgs <- 2

  expect_length(pkg_nodes[[1]], qty_pkgs)
})

test_that("ts_find_all(ts_query_mod) does not return box::use packages", {
  query <- ts_query_mod

  code <- "
box::use(
  stringr,
  tidyr,
)"

  pkg_nodes <- ts_find_all(ts_root(code), query)
  qty_pkgs <- 0

  expect_length(pkg_nodes[[1]], qty_pkgs)
})
test_that("ts_find_all(ts_query_mod) does not return non box::use calls", {
  query <- ts_query_mod

  code <- "
some_function <- function() {
  1 + 1
}"

  pkg_nodes <- ts_find_all(ts_root(code), query)
  qty_pkgs <- 0

  expect_length(pkg_nodes[[1]], qty_pkgs)
})
