options(box.path = file.path(getwd(), "mod"))

test_that("all linters skip valid box test for interface", {
  linters <- lintr::linters_with_defaults(
    defaults = box.linters::rhino_default_linters
  )

  code <- "
box::use(
  testthat[expect_true, test_that],
)

box::use(
  path/to/module_a,
)

impl <- attr(module_a, \"namespace\")

test_that(\"implementation detail X works\", {
  expect_true(impl$this_works())
})"

  lintr::expect_lint(code, NULL, linters = linters)
})
