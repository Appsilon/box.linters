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
    dplyr[filter, mutate, select],
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

test_that("box_alphabetical_calls_linter() blocks unsorted imports in box::use() call", {
  linter <- box_repeated_calls_linter()

  bad_box_calls_1 <- "box::use(
    dplyr,
    tidyr,
    dplyr,
  )"

  bad_box_calls_2 <- "box::use(
    path/to/fileA,
    path/to/fileB[...],
    path/to/fileA[a, b, c],
  )"

  bad_box_calls_3 <- "box::use(
    global/mod,
    mod2 = local/mod,
    purrr,
    tbl = tibble,
    dplyr = dplyr[filter, select],
    stats[st_filter = filter, ...],
    tibble[x, ...],
    local/mod
)"


  # bad_box_calls_6 <- "box::use(
  #   shiny,
  #   purrr
  # )
  #
  # box::use(
  #   shiny,
  #   dplyr
  # )"


  lintr::lint(
    text = bad_box_calls_3,
    linters = box_repeated_calls_linter()
  )


  lint_message <- function(package) {
    rex::rex(paste0("Package '", package, "' is imported more than once."))
  }

  lintr::expect_lint(bad_box_calls_1, list(
    list(message = lint_message('dplyr'), line_number = 4)
  ), linter)

  lintr::expect_lint(bad_box_calls_2, list(
    list(message = lint_message('path/to/fileA'), line_number = 4)
  ), linter)

  lintr::expect_lint(bad_box_calls_3, list(
    list(message = lint_message('tibble'), line_number = 8)
    ,list(message = lint_message('local/mod'), line_number = 9)
  ), linter)
})
