code_to_xml_expr <- function(text_code) {
  xml2::read_xml(
    xmlparsedata::xml_parse_data(
      parse(text = text_code, keep.source = TRUE)
    )
  )
}

test_that("retrive_text_before_bracket returns correct text", {

  test_vector <- c(
    "packageA",
    "packageB[function, function]",
    "packageC[...]",
    "path/modA",
    "path/modB[function, function]",
    "path/modC[...]"
  )

  output <- retrieve_text_before_bracket(test_vector)

  expected_result <- c(
    "packageA",
    "packageB",
    "packageC",
    "path/modA",
    "path/modB",
    "path/modC"
  )

  expect_equal(output, expected_result)
})

test_that("find_all_imports really finds all imports", {

  code <- "box::use(dplyr, purrr, shiny)"
  xml <- code_to_xml_expr(code)
  expected_result <- c("dplyr", "purrr", "shiny")
  expect_equal(find_all_imports(xml)$text, expected_result)

  code <- "
box::use(
  dplyr,
  purrr,
  )

box::use(
  path/to/A[
    f1,
    f2
  ],
  path/to/B,
  )

box::use(
  dplyr[...],
  )
"
  xml <- code_to_xml_expr(code)
  expected_result <- c("dplyr", "purrr", "path/to/A", "path/to/B", "dplyr")
  expect_equal(find_all_imports(xml)$text, expected_result)

  code <- "
box::use(
  a = dplyr[...],
  b = purrr[map],

  c = shiny[d = runApp]
  )
"
  xml <- code_to_xml_expr(code)
  expected_result <- c("dplyr", "purrr", "shiny")
  expect_equal(find_all_imports(xml)$text, expected_result)


  code <- "box::use()"
  xml <- code_to_xml_expr(code)
  expected_result <- ""
  expect_null(find_all_imports(xml)$text)
})

test_that("box_repeated_calls_linter() skips non-repeated imports", {
  linter <- box_repeated_calls_linter()

  good_box_calls_1 <- "box::use(
    dplyr,
    shiny,
    tidyr,
  )"

  good_box_calls_2 <- "box::use(
    path/to/fileA,
    path/to/fileB,
    path/to/fileC,
  )"

  good_box_calls_3 <- "box::use(
    dplyr[
      filter,
      mutate,
      select
    ],
    shiny,
    tidyr[long, pivot, wide],
  )"

  good_box_calls_4 <- "box::use(
    path/to/fileA[functionA, functionB, functionC],
    path/to/fileB,
    path/to/fileC[functionD, functionE, functionF],
  )"

  lintr::expect_lint(good_box_calls_1, NULL, linter)
  lintr::expect_lint(good_box_calls_2, NULL, linter)
  lintr::expect_lint(good_box_calls_3, NULL, linter)
  lintr::expect_lint(good_box_calls_4, NULL, linter)
})

test_that("box_repeated_calls_linter() points to repeated imports", {
  linter <- box_repeated_calls_linter()

  bad_box_calls_1 <- "box::use(
    dplyr,
    tidyr,
    dplyr,
  )"

  bad_box_calls_2 <- "box::use(
    path/to/fileA[a = f1],
    path/to/fileB[...],
    path/to/fileA[
      b = f2,
      c = f3
    ],
  )"

  bad_box_calls_3 <- "box::use(
    global/mod,
    mod2 = local/mod,
    purrr,
    tbl = tibble,
    dplyr = dplyr[filter, select],
    stats[st_filter = filter, ...],
    tibble[x, ...],
    local/mod[
      f1,
      f2,
      f3
    ]
)"

  bad_box_calls_4 <- "box::use(shiny)

  box::use(my/dir)

  box::use(shiny)"

  lint_message <- function(package) {
    rex::rex(paste0("Module or package '", package, "' is imported more than once."))
  }

  lintr::expect_lint(bad_box_calls_1, list(
    list(message = lint_message("dplyr"), line_number = 4)
  ), linter)

  lintr::expect_lint(bad_box_calls_2, list(
    list(message = lint_message("path/to/fileA"), line_number = 4)
  ), linter)

  lintr::expect_lint(bad_box_calls_3, list(
    list(message = lint_message("tibble"), line_number = 8),
    list(message = lint_message("local/mod"), line_number = 9)
  ), linter)

  lintr::expect_lint(bad_box_calls_4, list(
    list(message = lint_message("shiny"), line_number = 5)
  ), linter)

})
