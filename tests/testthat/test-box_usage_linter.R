options(box.path = file.path(getwd(), "mod"))

test_that("box_usage_linter skips allowed base packages functions", {
  linter <- box_usage_linter()

  good_box_usage_4 <- "box::use(
    dplyr[`%>%`, filter, pull],
  )

  mpg <- mtcars %>%
    filter(mpg <= 10) %>%
    pull(mpg)

  mean(mpg)
  "

  lintr::expect_lint(good_box_usage_4, NULL, linter)
})

test_that("box_usage_linter blocks package functions not box-imported", {
  linter <- box_usage_linter()
  lint_message_1 <- rex::rex("Function not imported nor defined.")

  # filter not imported
  bad_box_usage_1 <- "box::use(
    dplyr[`%>%`, select],
  )

  mtcars %>%
    select(mpg, cyl) %>%
    mutate(
      m = mean(mpg)
    )
  "

  lintr::expect_lint(bad_box_usage_1, list(message = lint_message_1), linter)
})

test_that("box_usage_linter blocks package aliased functions not attached", {
  linter <- box_usage_linter()
  lint_message_1 <- rex::rex("Function not imported nor defined.")

  # filter not imported
  bad_box_usage_1 <- "box::use(
    dplyr[`%>%`, select],
  )

  mtcars %>%
    select(mpg, cyl) %>%
    bad_alias(
      m = mean(mpg)
    )
  "

  lintr::expect_lint(bad_box_usage_1, list(message = lint_message_1), linter)
})

test_that("box_usage_linter blocks package/module aliased not attached", {
  linter <- box_usage_linter()
  lint_message <- rex::rex("<package/module>$function does not exist.")

  good_box_usage_2 <- "box::use(
    shiny[NS],
    pkg_alias = glue,
    fs[path_file],
  )

  name <- 'Fred'
  bad_alias$glue('My name is {name}.')

  path_file('dir/file.zip')

  ns <- NS()
  "

  lintr::expect_lint(good_box_usage_2, list(message = lint_message), linter)
})

test_that("box_usage_linter blocks package functions not in global namespace", {
  linter <- box_usage_linter()
  lint_message_1 <- rex::rex("Function not imported nor defined.")

  # xyz function does not exist
  bad_box_usage_3 <- "box::use(
    glue[...]
  )

  name <- 'Fred'
  xyz('My name is {name}')
  "

  lintr::expect_lint(bad_box_usage_3, list(message = lint_message_1), linter)
})

test_that("box_usage_linter skips data object names used in function signatures", {
  linter <- box_usage_linter()

  code <- "
  some_function <- function(x, y) {
    x
    sum(x, y)
  }

  result <- some_function(4, 3)
  "

  lintr::expect_lint(code, NULL, linter)
})

test_that("box_usage_linter skips allowed functions passed as function arguments", {
  linter <- box_usage_linter()

  code <- "
  some_function <- function(x, y, func = NULL) {
    func(x, y)
  }

  some_function(2, 3, sum)
  "

  lintr::expect_lint(code, NULL, linter)
})


test_that("box_usage_linter skips allowed referencing data objects in lists", {
  linter <- box_usage_linter()

  code <- "
  data <- list(element = \"AAA\")

  data$element
  "

  lintr::expect_lint(code, NULL, linter)
})

test_that("box_usage_linter skips allowed data objects as lists passed as function arguments", {
  linter <- box_usage_linter()

  code <- "
  some_function <- function(x) {
    x$element
  }

  data <- list(element = \"AAA\")

  some_function(data)
  "

  lintr::expect_lint(code, NULL, linter)
})

test_that("box_usage_linter skips allowed referencing functions in lists", {
  linter <- box_usage_linter()

  code <- "
  some_list <- list(
    func = function(i) {
      i + 1
    }
  )

  some_list$func(4)"

  lintr::expect_lint(code, NULL, linter)
})

test_that("box_usage_linter skips allowed functions in lists passed as function parameters", {
  linter <- box_usage_linter()

  code <- "
  some_function <- function(x, y) {
    x$func(y)
  }

  some_list <- list(
    func = function(i) {
      i + 1
    }
  )

  some_function(some_list, 4)"

  lintr::expect_lint(code, NULL, linter)
})

test_that("box_usage_linter skips allowed three-dots in function signature", {
  linter <- box_usage_linter()

  code <- "
  # ... passed through
  some_function <- function(x, y, ...) {
    sum(x, y, ...)
  }

  some_function(1, 2)

  # ... not passed through
  another_function <- function(x, ...) {
    mean(x)
  }
  "

  lintr::expect_lint(code, NULL, linter)
})

test_that("box_usage_linter skips allowed cloned functions", {
  linter <- box_usage_linter()

  code <- "
  some_function <- function(x) {
    x
  }

  this_fun <- some_function
  this_fun(2)
  "

  lintr::expect_lint(code, NULL, linter)
})

test_that("box_usage_linter skips allowed curried functions", {
  linter <- box_usage_linter()

  code <- "
  some_function <- function(x) {
    function(y) {
      x + y
    }
  }

  this_fun <- some_function(1)
  this_fun(2)
  "

  lintr::expect_lint(code, NULL, linter)
})

test_that("box_usage_linter skips function lists declared in function signature", {
  linter <- box_usage_linter()

  code <- "
    box::use(
      path/to/module_e
    )

    do_something <- function(data) {
      module_e$summary(data$summary())
    }
    "

  lintr::expect_lint(code, NULL, linter)
})

test_that("box_usage_linter skips allowed destructure assignment objects", {
  linter <- box_usage_linter()

  code <- "box::use(
    rhino[`%<-%`],
  )

  # this linter does not look at the right side of the operation
  c(object1, object2) %<-% list()

  # to simulate a non-reactive object
  print(object1)

  # to simulate a reactive object
  print(object2())
  "

  lintr::expect_lint(code, NULL, linter)
})
