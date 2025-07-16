options(box.path = file.path(getwd(), "mod"))

test_that("box_unique_names_linter should skip an attached package and specific function", {
  linter <- box_unique_names_linter()

  good_box_usage_1 <- "box::use(
    dplyr,
    dplyr[filter],
  )
  "

  good_box_usage_2 <- "box::use(
    path/to/nested1/module,
    path/to/nested1/module[fun_a],
  )
  "

  lintr::expect_lint(good_box_usage_1, NULL, linter)
  lintr::expect_lint(good_box_usage_2, NULL, linter)
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

  good_box_usage_3 <- "box::use(
    path/to/nested1/module[alias = fun_a],
    path/to/nested2/module[fun_a]
  )
  "

  good_box_usage_4 <- "box::use(
    path/to/nested1/module[alias_a = fun_a],
    path/to/nested2/module[alias_b = fun_a]
  )
  "

  lintr::expect_lint(good_box_usage_1, NULL, linter)
  lintr::expect_lint(good_box_usage_2, NULL, linter)
  lintr::expect_lint(good_box_usage_3, NULL, linter)
  lintr::expect_lint(good_box_usage_4, NULL, linter)
})

test_that("box_unique_names_linter blocks duplicated packages or modules", {
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

  bad_box_usage_3 <- "box::use(
    path/to/nested1/module,
    path/to/nested1/module
  )
  "

  bad_box_usage_4 <- "box::use(
    path/to/nested1/module,
    path/to/nested2/module
  )
  "

  bad_box_usage_5 <- "box::use(
    dplyr,
  )

  box::use(
    path/to/nested1/dplyr
  )
  "

  lintr::expect_lint(bad_box_usage_1, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_usage_2, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_usage_3, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_usage_4, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_usage_5, list(message = lint_message), linter)
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

  bad_box_usage_4 <- "box::use(
    path/to/nested1/module[fun_a],
    path/to/nested2/module[fun_a],
  )
  "

  bad_box_usage_5 <- "box::use(
    path/to/nested1/module[fun_a],
    path/to/nested2/module[...],
  )
  "

  bad_box_usage_6 <- "box::use(
    path/to/nested1/module[...],
    path/to/nested2/module[...],
  )
  "

  bad_box_usage_7 <- "box::use(
    dplyr[filter],
  )

  box::use(
    path/to/nested1/module[filter],
  )
  "

  bad_box_usage_8 <- "box::use(
    dplyr[...],
  )

  box::use(
    path/to/nested1/module[filter],
  )
  "

  bad_box_usage_9 <- "box::use(
    dplyr[filter],
  )

  box::use(
    path/to/nested1/module[...],
  )
  "

  lintr::expect_lint(bad_box_usage_1, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_usage_2, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_usage_3, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_usage_4, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_usage_5, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_usage_6, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_usage_7, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_usage_8, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_usage_9, list(message = lint_message), linter)
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

  bad_box_usage_5 <- "box::use(
    duplicate = path/to/nested1/module,
    duplicate = path/to/nested2/module,
  )
  "

  bad_box_usage_6 <- "box::use(
    path/to/nested1/module[duplicate = fun_a],
    path/to/nested2/module[duplicate = fun_a],
  )
  "

  bad_box_usage_7 <- "box::use(
    duplicate = path/to/nested1/module,
    path/to/nested2/module[duplicate = fun_a]
  )
  "

  bad_box_usage_8 <- "box::use(
    duplicate = dplyr
  )

  box::use(
    duplicate = path/to/nested1/module
  )
  "

  bad_box_usage_9 <- "box::use(
    duplicate = dplyr
  )

  box::use(
    path/to/nested1/module[duplicate = fun_a]
  )
  "

  bad_box_usage_10 <- "box::use(
    dplyr[duplicate = filter]
  )

  box::use(
    duplicate = path/to/nested1/module
  )
  "

  lintr::expect_lint(bad_box_usage_1, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_usage_2, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_usage_3, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_usage_4, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_usage_5, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_usage_6, list(message = lint_message), linter)
  lintr::expect_lint(bad_box_usage_7, list(message = lint_message), linter)
})

test_that("cross_duplicated_values returns the correct result finding a duplicate", {
  vec1 <- c("A", "B", "C")
  vec2 <- c("C", "D", "E")
  vectors <- list(vec1, vec2)

  expected_result <- list(
    flags = c(FALSE, TRUE),
    values = list(character(0), "C")
  )

  result <- cross_duplicated_values(vectors)
  expect_equal(result, expected_result)
})

test_that("cross_duplicated_values returns the correct result not finding a duplicate", {
  vec1 <- c("A", "B", "C")
  vec2 <- c("E", "F", "G")
  vectors <- list(vec1, vec2)

  expected_result <- list(
    flags = c(FALSE, FALSE),
    values = list(character(0), character(0))
  )

  result <- cross_duplicated_values(vectors)
  expect_equal(result, expected_result)
})

test_that("cross_duplicated_values returns the correct result for duplicates in three vectors", {
  vec1 <- c("A", "B", "C")
  vec2 <- c("C", "D", "E")
  vec3 <- c("D", "E", "F")
  vectors <- list(vec1, vec2, vec3)

  expected_result <- list(
    flags = c(FALSE, TRUE, TRUE),
    values = list(character(0), "C", c("D", "E"))
  )

  result <- cross_duplicated_values(vectors)
  expect_equal(result, expected_result)

  vec3 <- c("C", "E", "F")
  vectors <- list(vec1, vec2, vec3)

  expected_result <- list(
    flags = c(FALSE, TRUE, TRUE),
    values = list(character(0), "C", c("C", "E"))
  )

  result <- cross_duplicated_values(vectors)
  expect_equal(result, expected_result)
})
