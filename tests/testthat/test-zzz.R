test_that("rhino_default_linters skips properly styled code", {
  linters <- lintr::linters_with_defaults(defaults = rhino_default_linters)

  good_code <- "
box::use(
  dplyr,
  stringr[
    str_pad,
    str_trim
  ],
)

dplyr$select()
str_pad()
str_trim()"

  lintr::expect_lint(good_code, NULL, linters)
})

test_that("rhino_default_linters allows customization of lintr default linters", {
  linters <- lintr::linters_with_defaults(
    defaults = rhino_default_linters,
    line_length_linter = lintr::line_length_linter(102)
  )

  long_code <- as.character(glue::glue(
    '"12345678901234567890123456789012345678901234567890',
    '12345678901234567890123456789012345678901234567890"'
  ))

  lintr::expect_lint(long_code, NULL, linters)
})

test_that("rhino_default_linters blocks improper use of box", {
  linters <- lintr::linters_with_defaults(defaults = rhino_default_linters)

  bad_code <- "
box::use(
  dplyr,
  stringr[
    str_trim,
    str_pad
  ],
)

dplyr$select()
str_pad()
str_trim()"

  lint_message <- rex::rex("Module and function imports must be sorted alphabetically.")
  lintr::expect_lint(bad_code, list(
    list(message = lint_message, line_number = 5, column_number = 5)
  ), linters)
})

test_that("rhino_default_linters blocks violation of lintr default linters", {
  linters <- lintr::linters_with_defaults(defaults = rhino_default_linters)

  bad_code_1 <- "
box::use(
dplyr,
stringr[
  str_pad,
  str_trim
],
)

dplyr$select()
str_pad()
str_trim()"

  bad_code_2 <- as.character(glue::glue(
    '"12345678901234567890123456789012345678901234567890',
    '12345678901234567890123456789012345678901234567890"'
  ))

  lint_message_1 <- rex::rex("Indentation should be 2 spaces but is 0 spaces.")
  lintr::expect_lint(bad_code_1, list(message = lint_message_1), linters)

  lint_message_2 <- rex::rex(
    "Lines should not be more than 80 characters. This line is 102 characters"
  )
  lintr::expect_lint(bad_code_2, list(message = lint_message_2), linters)
})

test_that("box_default_linters works as expected", {
  linters <- lintr::linters_with_defaults(defaults = box_default_linters)

  good_code <- "
box::use(
  dplyr,
  stringr[str_pad, str_trim]
)

dplyr$select()
str_pad()
str_trim()"

  lintr::expect_lint(good_code, NULL, linters)
})
