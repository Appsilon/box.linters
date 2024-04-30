test_that("box_unused_att_mod_obj_linter skips used box-attached functions/objects.", {
  linter <- box_unused_att_mod_obj_linter()

  good_box_usage <- "box::use(
    path/to/module_a[a_fun_a, a_fun_b],
    path/to/module_b[b_fun_b, b_obj_a],
  )

  a_fun_a()
  a_fun_b(b_obj_a)
  b_fun_b()
  "

  lintr::expect_lint(good_box_usage, NULL, linter)
})

test_that("box_unused_att_mod_obj_linter skips used box-attached aliased functions.", {
  linter <- box_unused_att_mod_obj_linter()

  good_box_usage <- "box::use(
    path/to/module_a[a_fun_a, fun_alias = a_fun_b],
    path/to/module_b[gun_alias = b_fun_b],
  )

  a_fun_a()
  fun_alias()
  gun_alias()
  "

  lintr::expect_lint(good_box_usage, NULL, linter)
})

test_that("box_unused_att_mod_obj_linter skips used box-attached aliased objects", {
  linter <- box_unused_att_mod_obj_linter()

  good_box_usage <- "box::use(
    path/to/module_a[a_fun_a, a_fun_b],
    path/to/module_b[b_fun_b, obj_alias = b_obj_a],
  )

  a_fun_a()
  a_fun_b(obj_alias)
  b_fun_b()
  "

  lintr::expect_lint(good_box_usage, NULL, linter)
})

test_that("box_unused_att_mod_obj_linter blocks box-attached functions unused.", {
  linter <- box_unused_att_mod_obj_linter()
  lint_message_1 <- rex::rex("Imported function/object unused.")

  bad_box_usage_1 <- "box::use(
    path/to/module_a[a_fun_a, a_fun_b],
    path/to/module_b[b_fun_b, b_obj_a],
  )

  a_fun_a(b_obj_a)
  b_fun_b()
  "

  lintr::expect_lint(bad_box_usage_1, list(message = lint_message_1), linter)
})

test_that("box_unused_att_mod_obj_linter blocks box-attached aliased functions unused.", {
  linter <- box_unused_att_mod_obj_linter()
  lint_message_1 <- rex::rex("Imported function/object unused.")

  # filter is unused
  bad_box_usage_1 <- "box::use(
    path/to/module_a[a_fun_a, fun_alias = a_fun_b],
    path/to/module_b[b_fun_b],
  )

  a_fun_a()
  b_fun_b()
  "

  lintr::expect_lint(bad_box_usage_1, list(message = lint_message_1), linter)
})

test_that("box_unused_att_mod_obj_linter blocks box-attached objects unused.", {
  linter <- box_unused_att_mod_obj_linter()
  lint_message_1 <- rex::rex("Imported function/object unused.")

  # filter is unused
  bad_box_usage_1 <- "box::use(
    path/to/module_a[a_fun_a, a_fun_b],
    path/to/module_b[b_fun_b, b_obj_a],
  )

  a_fun_a()
  a_fun_b()
  b_fun_b()
  "

  lintr::expect_lint(bad_box_usage_1, list(message = lint_message_1), linter)
})

test_that("box_unused_att_mod_obj_linter blocks box-attached aliased objects unused.", {
  linter <- box_unused_att_mod_obj_linter()
  lint_message_1 <- rex::rex("Imported function/object unused.")

  # filter is unused
  bad_box_usage_1 <- "box::use(
    path/to/module_a[a_fun_a, a_fun_b],
    path/to/module_b[b_fun_b, obj_alias = b_obj_a],
  )

  a_fun_a()
  a_fun_b()
  b_fun_b()
  "

  lintr::expect_lint(bad_box_usage_1, list(message = lint_message_1), linter)
})
