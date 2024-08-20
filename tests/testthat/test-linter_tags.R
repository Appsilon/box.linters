#'
#' This file tests whether the lintr::available_linters() and lintr::available_tags()
#' functions can read the csv file with linter definitions.
#'
#' lintr expects the package to be already installed. Those tests need to be run
#' using devtools::check(), otherwise will be skipped.
#'
#' Manual checks can also be performed by installing the package and setting the
#' `linters_csv_location` variable to "./inst/lintr/linters.csv", then running
#' tests in the console.
#'
linters_csv_location <- "../../box.linters/lintr/linters.csv"

test_that("lintr::available_linters() reads csv file with linters and tags", {
  skip_if(!file.exists(linters_csv_location))

  expected_linters <- read.csv(linters_csv_location)
  detected_linters <- lintr::available_linters("box.linters")

  expect_identical(detected_linters$linter, expected_linters$linter)
  expect_identical(detected_linters$tags, strsplit(expected_linters$tags, " "))
})

test_that("lintr::available_tags() reads list of tags for the package", {
  skip_if(!file.exists(linters_csv_location))

  expected_tags <- read.csv(linters_csv_location)$tags |>
    strsplit(" ") |>
    unlist() |>
    unique() |>
    sort()

  detected_tags <- lintr::available_tags("box.linters")

  expect_identical(detected_tags, expected_tags)
})
