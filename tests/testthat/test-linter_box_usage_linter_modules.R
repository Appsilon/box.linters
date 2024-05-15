options(box.path = file.path(getwd(), "mod"))

test_that("box_usage_linter skips allowed module[function] attachment.", {
  linter <- box_usage_linter()

  good_box_usage <- "box::use(
    path/to/module_a[a_fun_a, a_fun_b],
    path/to/module_b[...],
    path/to/module_c[c_fun_b, c_obj_a]
  )
"

  lintr::expect_lint(good_box_usage, NULL, linter)
})

test_that("box_usage_linter skips allowed module[function] alias attachment.", {
  linter <- box_usage_linter()

  good_box_usage <- "box::use(
    path/to/module_a[a_fun_a, fun_alias = a_fun_b],
    path/to/module_b[...],
    path/to/module_c[gun_alias = c_fun_b, c_obj_a]
  )
"

  lintr::expect_lint(good_box_usage, NULL, linter)
})

test_that("box_usage_linter skips allowed module attachment", {
  linter <- box_usage_linter()

  good_box_usage_2 <- "box::use(
    path/to/module_a,
    path/to/module_b
  )

  module_a$a_fun_a()
  module_b$b_fun_a()
  "

  lintr::expect_lint(good_box_usage_2, NULL, linter)
})

test_that("box_usage_linter skips allowed module alias attachment", {
  linter <- box_usage_linter()

  good_box_usage_2 <- "box::use(
    path/to/module_a,
    mod_alias = path/to/module_b
  )

  module_a$a_fun_a()
  mod_alias$b_fun_a()
  "

  lintr::expect_lint(good_box_usage_2, NULL, linter)
})

test_that("box_usage_linter skips allowed module[...] attachment", {
  linter <- box_usage_linter()

  good_box_usage_3 <- "box::use(
    path/to/module_a[...],
    path/to/module_b,
    path/to/module_c[...],
  )

  a_fun_a()
  c_fun_a()
  "
  lintr::expect_lint(good_box_usage_3, NULL, linter)
})

test_that("box_usage_linter blocks package functions exported by module", {
  linter <- box_usage_linter()
  lint_message_2 <- rex::rex("<package/module>$function does not exist.")

  # xyz is not exported by glue
  bad_box_usage_2 <- "box::use(
    path/to/module_a,
    path/to/module_b,
  )

  module_a$a_fun_a()
  module_b$not_exist()
  "

  lintr::expect_lint(bad_box_usage_2, list(message = lint_message_2), linter)
})
