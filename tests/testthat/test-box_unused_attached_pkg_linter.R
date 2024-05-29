test_that("box_unused_pkg_linter skips used attached packages", {
  linter <- box_unused_attached_pkg_linter()

  good_box_usage <- "box::use(
    fs[dir_ls, path_file],
    glue,
    shiny[...]
  )

  box::use(
    path/to/module1,
    path/to/module2[a, b, c],
    path/to/module3[...]
  )

  path_file('path/to/file')

  glue$glue('Lorem ipsum sit dolor')

  ns <- NS(id)
  "

  lintr::expect_lint(good_box_usage, NULL, linter)
})

test_that("box_unused_pkg_linter skips used attached aliased packages", {
  linter <- box_unused_attached_pkg_linter()

  good_box_usage <- "box::use(
    fs[dir_ls, path_file],
    pkg_alias = glue,
    shiny[...]
  )

  box::use(
    path/to/module1,
    path/to/module2[a, b, c],
    path/to/module3[...]
  )

  path_file('path/to/file')

  pkg_alias$glue('Lorem ipsum sit dolor')

  ns <- NS(id)
  "

  lintr::expect_lint(good_box_usage, NULL, linter)
})

test_that("box_unused_pkg_linter blocks unused attached packages", {
  linter <- box_unused_attached_pkg_linter()
  lint_message <- rex::rex("Attached package unused.")

  bad_box_usage <- "box::use(
    fs[dir_ls, path_file],
    glue,
    shiny[...]
  )

  box::use(
    path/to/module1,
    path/to/module2[a, b, c],
    path/to/module3[...]
  )

  path_file('path/to/file')
  ns <- NS(id)
  "

  lintr::expect_lint(bad_box_usage, list(message = lint_message), linter)
})

test_that("box_unused_pkg_linter blocks unused attached aliased packages", {
  linter <- box_unused_attached_pkg_linter()
  lint_message <- rex::rex("Attached package unused.")

  bad_box_usage <- "box::use(
    fs[dir_ls, path_file],
    pkg_alias = glue,
    shiny[...]
  )

  box::use(
    path/to/module1,
    path/to/module2[a, b, c],
    path/to/module3[...]
  )

  path_file('path/to/file')
  ns <- NS(id)
  "

  lintr::expect_lint(bad_box_usage, list(message = lint_message), linter)
})

test_that("box_unused_pkg_linter blocks unused three-dots attached packages", {
  linter <- box_unused_attached_pkg_linter()
  lint_message <- rex::rex("Three-dots attached package unused.")

  bad_box_usage <- "box::use(
    fs[dir_ls, path_file],
    glue,
    shiny[...]
  )

  box::use(
    path/to/module1,
    path/to/module2[a, b, c],
    path/to/module3[...]
  )

  path_file('path/to/file')
  glue$glue('Lorem ipsum sit dolor')
  "

  lintr::expect_lint(bad_box_usage, list(message = lint_message), linter)
})


# Glue compatiblity

test_that("box_unused_attached_pkg_linter skips function used in glue string template", {
  linter <- box_unused_attached_pkg_linter()

  good_box_usage <- "box::use(
    glue,
    stringr,
  )

  string_with_spaces <- \"   String with white spaces\t\"
  glue$glue(\"This {stringr$str_trim(string_with_spaces)} should be parsed\")
  "

  lintr::expect_lint(good_box_usage, NULL, linters = linter)
})

test_that("box_unused_attached_pkg_linter skips literal braces in glue string template", {
  linter <- box_unused_attached_pkg_linter()
  lint_message_1 <- rex::rex("Attached package unused.")

  bad_box_usage <- "box::use(
    glue,
    stringr,
  )

  string_with_spaces <- \"   String with white spaces\t\"
  glue$glue(\"This {{stringr$str_trim(string_with_spaces)}} should be parsed\")
  "

  lintr::expect_lint(bad_box_usage, list(message = lint_message_1), linters = linter)
})

test_that("box_unused_attached_pkg_linter blocks unused functions in glue string template", {
  linter <- box_unused_attached_pkg_linter()
  lint_message_1 <- rex::rex("Attached package unused.")

  bad_box_usage <- "box::use(
    glue,
    stringr,
  )

  string_with_spaces <- \"   String with white spaces\t\"
  glue$glue(\"This does not have a pareable object.\")
  "

  lintr::expect_lint(bad_box_usage, list(message = lint_message_1), linters = linter)
})

# Glue compatibility three dots

test_that("box_unused_attached_pkg_linter skips function used in glue string template", {
  linter <- box_unused_attached_pkg_linter()

  good_box_usage <- "box::use(
    glue[...],
    stringr[...],
  )

  string_with_spaces <- \"   String with white spaces\t\"
  glue(\"This {str_trim(string_with_spaces)} should be parsed\")
  "

  lintr::expect_lint(good_box_usage, NULL, linters = linter)
})

test_that("box_unused_attached_pkg_linter skips literal braces in glue string template", {
  linter <- box_unused_attached_pkg_linter()
  lint_message_1 <- rex::rex("Three-dots attached package unused.")

  bad_box_usage <- "box::use(
    glue[...],
    stringr[...],
  )

  string_with_spaces <- \"   String with white spaces\t\"
  glue(\"This {{str_trim(string_with_spaces)}} should be parsed\")
  "

  lintr::expect_lint(bad_box_usage, list(message = lint_message_1), linters = linter)
})

test_that("box_unused_attached_pkg_linter blocks unused functions in glue string template", {
  linter <- box_unused_attached_pkg_linter()
  lint_message_1 <- rex::rex("Three-dots attached package unused.")

  bad_box_usage <- "box::use(
    glue[...],
    stringr[...],
  )

  string_with_spaces <- \"   String with white spaces\t\"
  glue(\"This does not have a pareable object.\")
  "

  lintr::expect_lint(bad_box_usage, list(message = lint_message_1), linters = linter)
})
