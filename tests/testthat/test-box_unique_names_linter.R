test_that("box_unique_names_linter should skip an attached package, and an attached function from the same package", {
  linter <- box_unique_names_linter()

  good_box_usage_1 <- "box::use(
    dplyr,
    dplyr[filter],
  )
  "

  lintr::expect_lint(good_box_usage_1, NULL, linter)
})

test_that("box_unique_names_linter should skip same function names with different aliases", {
  linter <- box_unique_names_linter()

  good_box_usage_1 <- "box::use(
    stats[s_filter = filter],
    dplyr[filter],
  )
  "

  good_box_usage_2 <- "box::use(
    stats[s_filter = filter],
    dplyr[f_filter = filter],
  )
  "

  lintr::expect_lint(good_box_usage_1, NULL, linter)
  lintr::expect_lint(good_box_usage_2, NULL, linter)
})

test_that("box_unique_names_linter blocks duplicated packages", {
  linter <- box_unique_names_linter()
  lint_message <- rex::rex("Duplicated box-attached object:")

  bad_box_usage_1 <- "box::use(
    dplyr,
  )

  box::use(
    dplyr,
  )
  "

  bad_box_usage_2 <- "box::use(
    dplyr,
    dplyr,
  )
  "

  lintr::expect_lint(bad_box_usage_1, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_usage_2, list(message = lint_message), linter)
})

test_that("box_unique_names_linter blocks duplicated functions", {
  linter <- box_unique_names_linter()
  lint_message <- rex::rex("Duplicated box-attached object:")

  bad_box_usage_1 <- "box::use(
    stats[filter],
    dplyr[filter],
  )
  "

  bad_box_usage_2 <- "box::use(
    dplyr[filter],
    stats[...],
  )
  "

  # lint on filter(), lag(), select()
  bad_box_usage_3 <- "box::use(
    dplyr[...],
    stats[...],
  )
  "

  lintr::expect_lint(bad_box_usage_1, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_usage_2, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_usage_3, list(message = lint_message), linter)
})

test_that("box_unique_names_linter blocks duplicated aliases", {
  linter <- box_unique_names_linter()
  lint_message <- rex::rex("Duplicated box-attached object:")

  bad_box_usage_1 <- "box::use(
    dplyr,
    dplyr = stats
  )
  "

  bad_box_usage_2 <- "box::use(
    duplicate = dplyr,
    duplicate = stats
  )
  "

  bad_box_usage_3 <- "box::use(
    stats[duplicate = filter],
    dplyr[duplicate = filter],
  )
  "

  bad_box_usage_4 <- "box::use(
    duplicate = stats,
    dplyr[duplicate = filter],
  )
  "

  lintr::expect_lint(bad_box_usage_1, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_usage_2, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_usage_3, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_usage_4, list(message = lint_message), linter)
})
