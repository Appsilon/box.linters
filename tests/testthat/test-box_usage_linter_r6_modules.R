options(box.path = file.path(getwd(), "mod"))

test_that("box_usage_linter skips allowed R6 object instantiation", {
  linter <- box_usage_linter()

  code <- "box::use(
    R6[R6Class],
  )

  SomeClass <- R6Class(\"SomeClass\",     # nolint
    public = list()
  )

  s <- SomeClass$new()
  "

  lintr::expect_lint(code, NULL, linter)
})

test_that("box_usage_linter skips allowed box-imported R6 object instantiation", {
  linter <- box_usage_linter()

  code <- "box::use(
    path/to/module_r6[SomeClass]
  )

  s <- SomeClass$new()
  "

  lintr::expect_lint(code, NULL, linter)
})

test_that("box_usage_linter skips allowed whole-module-imported R6 object instantiation", {
  linter <- box_usage_linter()

  code <- "box::use(
    path/to/module_r6
  )

  s <- module_r6$SomeClass$new()
  "

  lintr::expect_lint(code, NULL, linter)
})

test_that("box_usage_linter skips allowed dynamically added data members to R6 class", {
  linter <- box_usage_linter()

  code <- "box::use(
    R6[R6Class],
  )

  SomeClass <- R6Class(\"SomeClass\",     # nolint
    public = list()
  )

  SomeClass$set(\"public\", \"x\", 10)
  s <- SomeClass$new()
  s$x
  "

  lintr::expect_lint(code, NULL, linter)
})

test_that("box_usage_linter skips allowed dynamically added data members to box-imported R6 class", {
  linter <- box_usage_linter()

  code <- "box::use(
    path/to/module_r6[SomeClass]
  )

  SomeClass$set(\"public\", \"x\", 10)
  s <- SomeClass$new()
  s$x
  "

  lintr::expect_lint(code, NULL, linter)
})

test_that("box_usage_linter skips allowed dynamically added data members to whole-module-imported
          R6 class", {
  linter <- box_usage_linter()

  code <- "box::use(
    path/to/module_r6
  )

  module_r6$SomeClass$set(\"public\", \"x\", 10)
  s <- module_r6$SomeClass$new()
  s$x
  "

  lintr::expect_lint(code, NULL, linter)
})

test_that("box_usage_linter skips allowed dynamically added methods to R6 class", {
  linter <- box_usage_linter()

  code <- "box::use(
    R6[R6Class],
  )

  SomeClass <- R6Class(\"SomeClass\",     # nolint
    public = list()
  )

  SomeClass$set(\"public\", \"x\", function() {
    \"X\"
  })
  s <- SomeClass$new()
  s$x()
  "

  lintr::expect_lint(code, NULL, linter)
})

test_that("box_usage_linter skips allowed dynamically added methods to box-imported R6 class", {
  linter <- box_usage_linter()

  code <- "box::use(
    path/to/module_r6[SomeClass]
  )

  SomeClass$set(\"public\", \"x\", function() {
    \"X\"
  })
  s <- SomeClass$new()
  s$x()
  "

  lintr::expect_lint(code, NULL, linter)
})

test_that("box_usage_linter skips allowed dynamically added data members to whole-module-imported
          R6 class", {
            linter <- box_usage_linter()

            code <- "box::use(
    path/to/module_r6
  )

  module_r6$SomeClass$set(\"public\", \"x\", function() {
    \"X\"
  })
  s <- module_r6$SomeClass$new()
  s$x()
  "

  lintr::expect_lint(code, NULL, linter)
})
