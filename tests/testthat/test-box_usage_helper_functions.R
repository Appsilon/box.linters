code_to_xml_expr <- function(text_code) {
  xml2::read_xml(
    xmlparsedata::xml_parse_data(
      parse(text = text_code, keep.source = TRUE)
    )
  )
}

test_that("get_declared_functions returns correct list of function definitions", {
  function_definitions <- "
fun_a <- function() {

}

fun_b <- function(x, y) {

}

obj_a <- c(1, 2, 3)
"

  xml_function_definitions <- code_to_xml_expr(function_definitions)
  result <- get_declared_functions(xml_function_definitions)
  expected_result <- c("fun_a", "fun_b")

  expect_equal(result$text, expected_result)
})

test_that("get_function_calls returns correct list of function calls", {
  function_calls <- "
fun_a()
fun_b(1, 2)
obj_a <- obj_b
"

  xml_function_calls <- code_to_xml_expr(function_calls)
  result <- get_function_calls(xml_function_calls)
  expected_result <- c("fun_a", "fun_b")

  expect_setequal(result$text, expected_result)
})

test_that("get_function_calls returns correct list of function calls", {
  function_calls <- "
container$fun_a()
another$fun_b(1, 2)
obj_a <- obj_b
"

  xml_function_calls <- code_to_xml_expr(function_calls)
  result <- get_function_calls(xml_function_calls)
  expected_result <- c("container$fun_a", "another$fun_b")

  expect_setequal(result$text, expected_result)
})

test_that("get_declared_objects returns correct list of object definitions", {
  # TODO
  expect_true(TRUE)
})

test_that("get_object_calls returns correct list of object calls", {
  object_calls <- "
    obj <- a + b + c
  "

  xml_object_calls <- code_to_xml_expr(object_calls)
  result <- get_object_calls(xml_object_calls)
  expected_result <- c("a", "b", "c")

  expect_equal(result$text, expected_result)
})

test_that("get_object_calls returns correct list of object calls with equal assignment", {
  object_calls <- "
    obj = a + b + c
  "

  xml_object_calls <- code_to_xml_expr(object_calls)
  result <- get_object_calls(xml_object_calls)
  expected_result <- c("a", "b", "c")

  expect_equal(result$text, expected_result)
})

test_that("get_object_calls returns list objects", {
  object_list_calls <- "
    sum(container$object)
    mean(another$object)
  "

  xml_object_calls <- code_to_xml_expr(object_list_calls)
  result <- get_object_calls(xml_object_calls)
  expected_result <- c("container$object", "another$object", "container", "another")

  expect_setequal(result$text, expected_result)
})

test_that("get_object_calls returns objects passed to functions", {
  object_calls <- "
    obj_a <- 5
    some_function(obj_b)
  "

  xml_object_calls <- code_to_xml_expr(object_calls)
  result <- get_object_calls(xml_object_calls)
  expected_result <- c("obj_b")

  expect_equal(result$text, expected_result)
})

test_that("get_object_calls returns objects passed to functions with named params", {
  object_calls <- "
    obj_a <- 5
    some_function(param = obj_b)
  "

  xml_object_calls <- code_to_xml_expr(object_calls)
  result <- get_object_calls(xml_object_calls)
  expected_result <- c("obj_b")

  expect_equal(result$text, expected_result)
})

test_that("get_function_signature_objs returns object names from all function signatures", {
  function_definitions <- "
    some_function <- function(x, y) {
      x + y
    }

    another_function <- function(a, b) {
      a * b
    }
  "

  xml_function_definitions <- code_to_xml_expr(function_definitions)
  result <- get_function_signature_objs(xml_function_definitions)
  expected_result <- c("x", "y", "a", "b")

  expect_equal(result$text, expected_result)
})

test_that("get_declared_objects returns object names declared", {
  object_definitions <- "
    some_function <- function() {
      2
    }

    some_object <- 3
    another_object = 4

    assign(\"assigned_object\", 5)
  "

  xml_object_definitions <- code_to_xml_expr(object_definitions)
  result <- get_declared_objects(xml_object_definitions)
  expected_results <- c("some_function", "some_object", "another_object", "assigned_object")

  expect_equal(result$text, expected_results)
})
