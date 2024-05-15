options(box.path = file.path(getwd(), "mod"))

test_that("get_box_module_exports returns correct list of exported functions", {
  module <- "path/to/module_a"
  result <- get_box_module_exports(module)
  expected_output <- c("a_fun_a", "a_fun_b")
  expect_equal(result, expected_output)
})

test_that("get_box_module_exports returns correct list of exported data objects", {
  module <- "path/to/module_b"
  result <- get_box_module_exports(module)
  expected_output <- c("b_fun_a", "b_fun_b", "b_obj_a")
  expect_equal(result, expected_output)
})
