code_to_xml_expr <- function(text_code) {
  xml2::read_xml(
    xmlparsedata::xml_parse_data(
      parse(text = text_code, keep.source = TRUE)
    )
  )
}

test_that("get_objects_in_strings extracts a single variable name", {
  code <- "
    string <- \"Some {value} in a string.\"
  "
  xml_code <- code_to_xml_expr(code)
  results <- get_objects_in_strings(xml_code)
  should_find <- "value"

  expect_equal(results, should_find)
})

test_that("get_objects_in_strings extracts multiple variable names", {
  code <- "
    string <- \"Some {value_a} and {value_b} in a string.\"
  "
  xml_code <- code_to_xml_expr(code)
  results <- get_objects_in_strings(xml_code)
  should_find <- c("value_a", "value_b")

  expect_setequal(results, should_find)

  code <- "
    string <- \"Some {value_a}, {value_b}, and {value_c} in a string.\"
  "
  xml_code <- code_to_xml_expr(code)
  results <- get_objects_in_strings(xml_code)
  should_find <- c("value_a", "value_b", "value_c")

  expect_setequal(results, should_find)
})

test_that("get_objects_in_strings extracts function names", {
  code <- "
    string <- \"Some {func()} in a string.\"
  "
  xml_code <- code_to_xml_expr(code)
  results <- get_objects_in_strings(xml_code)
  should_find <- "func"

  expect_equal(results, should_find)
})

test_that("get_objects_in_strings extracts function names and parameter names", {
  code <- "
    string <- \"Some {func(value)} in a string.\"
  "
  xml_code <- code_to_xml_expr(code)
  results <- get_objects_in_strings(xml_code)
  should_find <- c("func", "value")

  expect_setequal(results, should_find)

  code <- "
    string <- \"Some {func(value_a, value_b)} in a string.\"
  "
  xml_code <- code_to_xml_expr(code)
  results <- get_objects_in_strings(xml_code)
  should_find <- c("func", "value_a", "value_b")

  expect_setequal(results, should_find)
})

test_that("get_objects_in_strings ignores other elements", {
  code <- "
    string <- \"Some {value + 1} in a string.\"
  "
  xml_code <- code_to_xml_expr(code)
  results <- get_objects_in_strings(xml_code)
  should_find <- "value"

  expect_equal(results, should_find)
})

test_that("get_objects_in_strings ignores literal glue objects {{ }}", {
  code <- "
    string <- \"Some {{value + 1}} in a string.\"
  "
  xml_code <- code_to_xml_expr(code)
  results <- get_objects_in_strings(xml_code)

  expect_equal(results, NULL)
})

test_that("get_objects_in_strings ignores literal glue objects {{ }} mixed in with { }", {
  code <- "
    string <- \"Some {{value_a + 1}} in a {value_b} string.\"
  "
  xml_code <- code_to_xml_expr(code)
  results <- get_objects_in_strings(xml_code)
  should_find <- "value_b"

  expect_equal(results, should_find)
})

test_that("get_objects_in_strings extracts objects from multiline code", {
  code <- "
    string <- \"Some text {
      {
        internal_var <- external_var
        some_function_call(internal_var, another_external_var)
      }
    } here.\"
  "
  xml_code <- code_to_xml_expr(code)
  results <- get_objects_in_strings(xml_code)
  should_find <- c("external_var", "some_function_call", "internal_var", "another_external_var")

  expect_setequal(results, should_find)
})

test_that("get_objects_in_strings handles multiple string constants in code", {
  code <- "
    string_1 <- \"Some text {value_a} here.\"
    string_2 <- \"Some text {value_b} here.\"
  "
  xml_code <- code_to_xml_expr(code)
  results <- get_objects_in_strings(xml_code)
  should_find <- c("value_a", "value_b")

  expect_setequal(results, should_find)
})

test_that("get_objects_in_strings handles multiple string constants in code", {
  code <- "
    string_1 <- \"No parseable object here.\"
    string_2 <- \"Some text {value_b} here.\"
  "
  xml_code <- code_to_xml_expr(code)
  results <- get_objects_in_strings(xml_code)
  should_find <- c("value_b")

  expect_setequal(results, should_find)
})

test_that("get_objects_in_strings handles custom glue .open and .close symbols", {
  withr::with_options(
    list(
      glue.open = "<<",
      glue.close = ">>"
    ),
    {
      code <- "
        string <- \"Some <<value_a>> and <<value_b>> in a string.\"
      "
      xml_code <- code_to_xml_expr(code)
      results <- get_objects_in_strings(xml_code)
      should_find <- c("value_a", "value_b")

      expect_setequal(results, should_find)

      code <- "
        string <- \"Some <<value_a>> and <value_b> in a string.\"
      "
      xml_code <- code_to_xml_expr(code)
      results <- get_objects_in_strings(xml_code)
      should_find <- c("value_a")

      expect_setequal(results, should_find)

      code <- "
        string <- \"Some <<value_a>> and <<<<value_b>>>> in a string.\"
      "
      xml_code <- code_to_xml_expr(code)
      results <- get_objects_in_strings(xml_code)
      should_find <- c("value_a")

      expect_setequal(results, should_find)

      code <- "
        string <- \"Some text <<
          {
            internal_var <- external_var
            some_function_call(internal_var, another_external_var)
          }
        >> here.\"
      "
      xml_code <- code_to_xml_expr(code)
      results <- get_objects_in_strings(xml_code)
      should_find <- c("external_var", "some_function_call", "internal_var", "another_external_var")

      expect_setequal(results, should_find)
    }
  )
})
