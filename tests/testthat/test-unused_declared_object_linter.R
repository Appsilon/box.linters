code_to_xml_expr <- function(text_code) {
  xml2::read_xml(
    xmlparsedata::xml_parse_data(
      parse(text = text_code, keep.source = TRUE)
    )
  )
}

test_that("unused_declared_object_linter skips used declared functions", {
  linter <- unused_declared_object_linter()

  good_box_usage_1 <- "sample_fun <- function(x, y) {
    x + y
  }

  sample_fun(2, 3)
  "

  good_box_usage_2 <- "assign('x', function(y) {y + 1})
  assign('y', 4)
  x(y)
  "

  good_box_usage_3 <- 'assign("x", function(y) {y + 1})
  assign("y", 4)
  x(y)
  '

  lintr::expect_lint(good_box_usage_1, NULL, linter)
  lintr::expect_lint(good_box_usage_2, NULL, linter)
  lintr::expect_lint(good_box_usage_3, NULL, linter)
})

test_that("unused_declared_object_linter blocks unused declared functions", {
  linter <- unused_declared_object_linter()
  lint_message <- rex::rex("Declared function/object unused.")

  bad_box_usage_1 <- "sample_fun <- function(x, y) {
    x + y
  }
  "

  bad_box_usage_2 <- "assign('x', function(y) {y + 1})
  assign('y', 4)
  "

  bad_box_usage_3 <- 'assign("x", function(y) {y + 1})
  assign("y", 4)
  '

  lintr::expect_lint(bad_box_usage_1, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_usage_2, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_usage_3, list(message = lint_message), linter)
})

test_that("get_exported_objects returns correct list of exported objects", {
  code <- "
  #' @export
  fun_a <- function() {

  }

  #' @export
  fun_b <- function() {

  }

  fun_c <- function() {

  }

  #' @export
  data_a <- 1

  #' @export
  data_b <- 2

  data_c <- 3
  "

  xml_exported_objects <- code_to_xml_expr(code)
  result <- get_exported_objects(xml_exported_objects)
  expected_result <- c("fun_a", "fun_b", "data_a", "data_b")

  expect_equal(result$text, expected_result)
})

test_that("unused_declared_object_linter skips exported functions", {
  linter <- unused_declared_object_linter()

  code <- "
  #' @export
  fun_a <- function() {

  }

  #' @export
  fun_b <- function() {
    fun_c()
  }

  fun_c <- function() {

  }
  "

  lintr::expect_lint(code, NULL, linter)
})

test_that("unused_declared_object_linter blocks not locally used private functions", {
  linter <- unused_declared_object_linter()
  lint_message <- rex::rex("Declared function/object unused.")

  code <- "
  #' @export
  fun_a <- function() {

  }

  #' @export
  fun_b <- function() {

  }

  fun_c <- function() {

  }
  "

  lintr::expect_lint(code, list(message = lint_message), linter)
})





test_that("unused_declared_object_linter skips exported data objects", {
  linter <- unused_declared_object_linter()

  code <- "
  #' @export
  fun_a <- function() {

  }

  #' @export
  fun_b <- function() {
    fun_c()
  }

  fun_c <- function() {
    obj_c
  }

  #' @export
  obj_a <- 1

  #' @export
  obj_b <- 2

  obj_c <- 3
  "

  lintr::expect_lint(code, NULL, linter)
})

test_that("unused_declared_object_linter not locally used private data objects", {
  linter <- unused_declared_object_linter()
  lint_message <- rex::rex("Declared function/object unused.")

  code <- "
  #' @export
  fun_a <- function() {

  }

  #' @export
  fun_b <- function() {
    fun_c()
  }

  fun_c <- function() {

  }

  #' @export
  obj_a <- 1

  #' @export
  obj_b <- 2

  obj_c <- 3
  "

  lintr::expect_lint(code, list(message = lint_message), linter)
})

test_that("unused_declared_object_linter skips assignment to list elements", {
  linter <- unused_declared_object_linter()

  path_to_shiny_app <- "shiny/simple/app.R"

  lintr::expect_lint(path_to_shiny_app, NULL, linters = linter)
})
