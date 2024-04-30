options(box.path = file.path(getwd(), "mod"))

test_that("box_unused_mod_linter skips used attached modules", {
  linter <- box_unused_attached_mod_linter()

  good_box_usage <- "box::use(
    path/to/module_a[a_fun_a],
    path/to/module_b,
    path/to/module_c,
  )

  module_b$b_fun_a()
  module_c$c_fun_b()
  "

  lintr::expect_lint(good_box_usage, NULL, linter)
})

test_that("box_unused_mod_linter skips used attached aliased module", {
  linter <- box_unused_attached_mod_linter()

  good_box_usage <- "box::use(
    mod_alias = path/to/module_a,
    path/to/module_b,
    nod_alias = path/to/module_c,
  )

  mod_alias$a_fun_b()
  module_b$b_fun_a()
  nod_alias$c_fun_b()
  "

  lintr::expect_lint(good_box_usage, NULL, linter)
})

test_that("box_unused_mod_linter skips allowed three-dots attached packages", {
  linter <- box_unused_attached_mod_linter()

  good_box_usage <- "box::use(
    path/to/module_a,
    path/to/module_b[...],
    path/to/module_c,
  )

  module_a$a_fun_b()
  b_fun_a()
  module_c$c_fun_b()
  "

  lintr::expect_lint(good_box_usage, NULL, linter)

})

test_that("box_unused_mod_linter ignores package imports", {
  linter <- box_unused_attached_mod_linter()

  good_box_usage <- "box::use(
    fs[dir_ls, path_file],
    glue,
    shiny[...]
  )

  box::use(
    path/to/module_a[a_fun_a],
    path/to/module_b,
    path/to/module_c,
  )

  module_b$b_fun_a()
  module_c$c_fun_b()
  "

  lintr::expect_lint(good_box_usage, NULL, linter)
})

test_that("box_unused_mod_linter blocks unused attached packages", {
  linter <- box_unused_attached_mod_linter()
  lint_message <- rex::rex("Attached module unused.")

  bad_box_usage <- "box::use(
    path/to/module_a,
    path/to/module_b,
    path/to/module_c,
  )

  module_a$a_fun_b()
  module_c$c_fun_b()
  "

  lintr::expect_lint(bad_box_usage, list(message = lint_message), linter)
})

test_that("box_unused_mod_linter blocks unused attached aliased packages", {
  linter <- box_unused_attached_mod_linter()
  lint_message <- rex::rex("Attached module unused.")

  bad_box_usage <- "box::use(
    path/to/module_a,
    mod_alias = path/to/module_b,
    path/to/module_c,
  )

  module_a$a_fun_b()
  module_c$c_fun_b()
  "

  lintr::expect_lint(bad_box_usage, list(message = lint_message), linter)
})

test_that("box_unused_mod_linter blocks unused three-dots attached packages", {
  linter <- box_unused_attached_mod_linter()
  lint_message <- rex::rex("Three-dots attached module unused.")

  bad_box_usage <- "box::use(
    path/to/module_a,
    path/to/module_b[...],
    path/to/module_c,
  )

  module_a$a_fun_b()
  module_c$c_fun_b()
  "

  lintr::expect_lint(bad_box_usage, list(message = lint_message), linter)

})
