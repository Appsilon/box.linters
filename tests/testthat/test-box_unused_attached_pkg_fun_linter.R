test_that("box_unused_attached_fun_linter skips used box-attached functions.", {
  linter <- box_unused_att_pkg_fun_linter()

  good_box_usage <- "box::use(
    fs[dir_ls, path_file],
    shiny[...],
    stringr
  )

  box::use(
    path/to/module1,
    path/to/module2[a, b, c],
    path/to/module3[...]
  )

  dir_ls('path')
  path_file('path/to/file')
  stringr$str_sub('text', 1, 2)
  is.reactive(x)
  "

  lintr::expect_lint(good_box_usage, NULL, linter)
})

test_that("box_unused_attached_fun_linter skips used box-attached aliased functions.", {
  linter <- box_unused_att_pkg_fun_linter()

  good_box_usage <- "box::use(
    fs[fun_alias = dir_ls, path_file],
    shiny[...],
    stringr
  )

  box::use(
    path/to/module1,
    path/to/module2[a, b, c],
    path/to/module3[...]
  )

  fun_alias('path')
  path_file('path/to/file')
  stringr$str_sub('text', 1, 2)
  is.reactive(x)
  "

  lintr::expect_lint(good_box_usage, NULL, linter)
})

test_that("box_unused_attached_fun_linter blocks box-attached functions unused.", {
  linter <- box_unused_att_pkg_fun_linter()
  lint_message_1 <- rex::rex("Imported function unused.")

  bad_box_usage_1 <- "box::use(
    fs[dir_ls, path_file],
    shiny[...],
    stringr
  )

  box::use(
    path/to/module1,
    path/to/module2[a, b, c],
    path/to/module3[...]
  )

  path_file('path/to/file')
  stringr$str_sub('text', 1, 2)
  is.reactive(x)
  "

  lintr::expect_lint(bad_box_usage_1, list(message = lint_message_1), linter)
})

test_that("box_unused_attached_fun_linter blocks box-attached aliased functions unused.", {
  linter <- box_unused_att_pkg_fun_linter()
  lint_message_1 <- rex::rex("Imported function unused.")

  # filter is unused
  bad_box_usage_1 <- "box::use(
    fs[fun_alias = dir_ls, path_file],
    shiny[...],
    stringr
  )

  box::use(
    path/to/module1,
    path/to/module2[a, b, c],
    path/to/module3[...]
  )

  path_file('path/to/file')
  stringr$str_sub('text', 1, 2)
  is.reactive(x)
  "

  lintr::expect_lint(bad_box_usage_1, list(message = lint_message_1), linter)
})

test_that("box_unused_att_pkg_fun_linter skips used function in list", {
  linter <- box_unused_att_pkg_fun_linter()

  good_box_usage <- "box::use(
    shiny[tags],
  )

  tags$h1('Header')
  "

  lintr::expect_lint(good_box_usage, NULL, linter)
})

test_that("box_unused_att_pkg_fun_linter blocks unused function in list", {
  linter <- box_unused_att_pkg_fun_linter()
  lint_message <- rex::rex("Imported function unused.")

  bad_box_usage <- "box::use(
    shiny[tags],
  )
  "

  lintr::expect_lint(bad_box_usage, list(message = lint_message), linter)
})

test_that("box_unused_att_pkg_fun_linter skips function used in glue string template", {
  linter <- box_unused_att_pkg_fun_linter()

  good_box_usage <- "box::use(
    glue[glue],
    stringr[str_trim],
  )

  string_with_spaces <- \"   String with white spaces\t\"
  glue(\"This {str_trim(string_with_spaces)} should be parsed\")
  "

  lintr::expect_lint(good_box_usage, NULL, linters = linter)
})

test_that("box_unused_att_pkg_fun_linter skips literal braces in glue string template", {
  linter <- box_unused_att_pkg_fun_linter()
  lint_message_1 <- rex::rex("Imported function unused.")

  bad_box_usage <- "box::use(
    glue[glue],
    stringr[str_trim],
  )

  string_with_spaces <- \"   String with white spaces\t\"
  glue(\"This {{str_trim(string_with_spaces)}} should be parsed\")
  "

  lintr::expect_lint(bad_box_usage, list(message = lint_message_1), linters = linter)
})

test_that("box_unused_att_pkg_fun_linter blocks unused functions in glue string template", {
  linter <- box_unused_att_pkg_fun_linter()
  lint_message_1 <- rex::rex("Imported function unused.")

  bad_box_usage <- "box::use(
    glue[glue],
    stringr[str_trim],
  )

  string_with_spaces <- \"   String with white spaces\t\"
  glue(\"This does not have a pareable object.\")
  "

  lintr::expect_lint(bad_box_usage, list(message = lint_message_1), linters = linter)
})
