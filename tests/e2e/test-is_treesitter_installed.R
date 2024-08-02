# How to test is_treesitter_installed()
#
# `withr` provides a function to temporarily install packages `withr::with_package()` in an
# environment. There is, however, no currently existing way to temporarily uninstalled packages
# to test environments without certain packages.
#
# To test `is_treesitter_installed()`, a manual test has to be executed.

devtools::load_all()

remove.packages(c("treesitter", "treesitter.r"))

testthat::test_that("is_treesitter_installed() returns FALSE when none is installed", {
  result <- is_treesitter_installed()

  testthat::expect_false(result)
})

testthat::test_that("is_treesitter_installed() returns FALSE when only treesitter is installed", {
  install.packages("treesitter")

  result <- is_treesitter_installed()

  testthat::expect_false(result)
  remove.packages("treesitter")
})

testthat::test_that("is_treesitter_installed() returns FALSE when only treesitter.r is installed", {
  install.packages("treesitter.r")

  result <- is_treesitter_installed()

  testthat::expect_false(result)
  remove.packages("treesitter.r")
})

install.packages(c("treesitter", "treesitter.r"))

testthat::test_that("is_treesitter_installed() returns TRUE", {
  result <- is_treesitter_installed()

  testthat::expect_true(result)
})
