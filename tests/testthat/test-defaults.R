test_that("rhino_default_linters skips properly styled code", {
  linters <- lintr::linters_with_defaults(defaults = rhino_default_linters)

  good_code <- "
box::use(
  dplyr,
  stringr[
    mutate,
    select
  ],
)"

  lintr::expect_lint(good_code, NULL, linters)
})

test_that("rhino_default_linters blocks improper use of box", {
  linters <- lintr::linters_with_defaults(defaults = rhino_default_linters)

  bad_code <- "
box::use(
  dplyr,
  stringr[
    select,
    mutate
  ],
)"

  lint_message <- rex::rex("Module and function imports must be sorted alphabetically.")
  lintr::expect_lint(bad_code, list(
    list(message = lint_message, line_number = 5),
    list(message = lint_message, line_number = 6)
  ), linters)
})

test_that("rhino_default_linters skips violation of lintr default linters", {
  linters <- lintr::linters_with_defaults(defaults = rhino_default_linters)

  bad_code_1 <- "
box::use(
dplyr,
stringr[
  mutate,
  select
],
)"

  bad_code_2 <- as.character(glue::glue(
    '"12345678901234567890123456789012345678901234567890',
    '12345678901234567890123456789012345678901234567890"'
  ))

  lint_message_1 <- rex::rex("Indentation should be 2 spaces but is 0 spaces.")
  lintr::expect_lint(bad_code_1, list(message = lint_message_1), linters)

  lint_message_2 <- rex::rex(
    "Lines should not be more than 100 characters. This line is 102 characters"
  )
  lintr::expect_lint(bad_code_2, list(message = lint_message_2), linters)
})
