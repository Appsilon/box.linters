options(box.path = file.path(getwd(), "mod"))

test_that("box_usage_linter skips allowed R6 object instantiation", {
  linter <- box_usage_linter()

  code <- "box::use(
    R6[R6Class],
  )

  some_class <- R6Class(\"SomeClass\",
    public = list()
  )

  s <- some_class$new()
  "

  lintr::expect_lint(code, NULL, linter)
})

test_that("box_usage_linter skips allowed box-imported R6 object instantiation", {
  linter <- box_usage_linter()

  code <- "box::use(
    path/to/module_r6[some_class]
  )

  s <- some_class$new()
  "

  lintr::expect_lint(code, NULL, linter)
})

test_that("box_usage_linter skips allowed whole-module-imported R6 object instantiation", {
  linter <- box_usage_linter()

  code <- "box::use(
    path/to/module_r6
  )

  s <- module_r6$some_class$new()
  "

  lintr::expect_lint(code, NULL, linter)
})

test_that("box_usage_linter skips allowed dynamically added data members to R6 class", {
  linter <- box_usage_linter()

  code <- "box::use(
    R6[R6Class],
  )

  some_class <- R6Class(\"SomeClass\",
    public = list()
  )

  some_class$set(\"public\", \"x\", 10)
  s <- some_class$new()
  s$x
  "

  lintr::expect_lint(code, NULL, linter)
})

test_that(
  "box_usage_linter skips allowed dynamically added data members to box-imported R6 class",
  {
    linter <- box_usage_linter()

    code <- "box::use(
      path/to/module_r6[some_class]
    )

    some_class$set(\"public\", \"x\", 10)
    s <- some_class$new()
    s$x
    "

    lintr::expect_lint(code, NULL, linter)
  }
)

test_that(
  "box_usage_linter skips allowed dynamically added data members to whole-module-imported R6 class",
  {
    linter <- box_usage_linter()

    code <- "box::use(
      path/to/module_r6
    )

    module_r6$some_class$set(\"public\", \"x\", 10)
    s <- module_r6$some_class$new()
    s$x
    "

    lintr::expect_lint(code, NULL, linter)
  }
)

test_that("box_usage_linter skips allowed dynamically added methods to R6 class", {
  linter <- box_usage_linter()

  code <- "box::use(
    R6[R6Class],
  )

  some_class <- R6Class(\"SomeClass\",
    public = list()
  )

  some_class$set(\"public\", \"x\", function() {
    \"X\"
  })
  s <- some_class$new()
  s$x()
  "

  lintr::expect_lint(code, NULL, linter)
})

test_that("box_usage_linter skips allowed dynamically added methods to box-imported R6 class", {
  linter <- box_usage_linter()

  code <- "box::use(
    path/to/module_r6[some_class]
  )

  some_class$set(\"public\", \"x\", function() {
    \"X\"
  })
  s <- some_class$new()
  s$x()
  "

  lintr::expect_lint(code, NULL, linter)
})

test_that(
  "box_usage_linter skips allowed dynamically added data members to whole-module-imported R6 class",
  {
    linter <- box_usage_linter()

    code <- "box::use(
      path/to/module_r6
    )

    module_r6$some_class$set(\"public\", \"x\", function() {
      \"X\"
    })
    s <- module_r6$some_class$new()
    s$x()
    "

    lintr::expect_lint(code, NULL, linter)
  }
)

test_that("box_usage_linter skips allowed R6 object cloning", {
  linter <- box_usage_linter()

  code <- "box::use(
    R6[R6Class],
  )

  some_class <- R6Class(\"SomeClass\",
    public = list(
      method = function() {
        \"do something\"
      }
    )
  )

  s <- some_class$new()
  t <- s$clone()
  t$method()
  "

  lintr::expect_lint(code, NULL, linter)
})

test_that("box_usage_linter skips allowed box-imported R6 object cloning", {
  linter <- box_usage_linter()

  code <- "box::use(
    path/to/module_r6[some_class]
  )

  s <- some_class$new()
  t <- s$clone()
  t$method()
  "

  lintr::expect_lint(code, NULL, linter)
})

test_that("box_usage_linter skips allowed whole-module-imported R6 object cloning", {
  linter <- box_usage_linter()

  code <- "box::use(
    path/to/module_r6
  )

  s <- module_r6$some_class$new()
  t <- s$clone()
  t$method()
  "

  lintr::expect_lint(code, NULL, linter)
})

test_that("box_usage_linter skips allowed box-imported aliased R6 object instantiation", {
  linter <- box_usage_linter()

  code <- "box::use(
    path/to/module_r6[class_alias = some_class]
  )

  s <- class_alias$new()
  s$method()
  "

  lintr::expect_lint(code, NULL, linter)
})

test_that("box_usage_linter skips allowed whole-module-imported aliased R6 object instantiation", {
  linter <- box_usage_linter()

  code <- "box::use(
    mod_alias = path/to/module_r6
  )

  s <- mod_alias$some_class$new()
  s$method()
  "

  lintr::expect_lint(code, NULL, linter)
})
