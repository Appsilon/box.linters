test_that("use_box_lintr works as expected", {
  tmp <- withr::local_tempdir()

  lintr_file <- use_box_lintr(path = tmp)
  expect_true(file.exists(lintr_file))

  expect_identical(
    normalizePath(lintr_file, winslash = "/"),
    file.path(normalizePath(tmp, winslash = "/"), ".lintr")
  )

  lints <- lintr::lint_dir(tmp)
  expect_length(lints, 0L)
})

test_that("use_box_lintr with type = rhino also works", {
  tmp <- withr::local_tempdir()

  lintr_file <- use_box_lintr(path = tmp, type = "rhino")
  expect_true(file.exists(lintr_file))

  expect_identical(
    normalizePath(lintr_file, winslash = "/"),
    file.path(normalizePath(tmp, winslash = "/"), ".lintr")
  )

  lints <- lintr::lint_dir(tmp)
  expect_length(lints, 0L)
})
