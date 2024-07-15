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

test_that("box_unused_att_mod_obj_linter skips used function in list", {
  linter <- box_unused_att_mod_obj_linter()

  good_box_usage <- "box::use(
    path/to/module_d[function_list]
  )

  function_list$fun_a()
  "

  lintr::expect_lint(good_box_usage, NULL, linter)
})

test_that("box_unused_att_mod_obj_linter blocks used function in list", {
  linter <- box_unused_att_mod_obj_linter()
  lint_message <- rex::rex("Imported function/object unused.")

  bad_box_usage <- "box::use(
    path/to/module_d[function_list]
  )
  "

  lintr::expect_lint(bad_box_usage, list(message = lint_message), linter)
})

test_that("box_unused_att_mod_obj_linter skips objects used in glue string templates", {
  linter <- box_unused_att_mod_obj_linter()

  good_box_usage <- "box::use(
    glue[glue],
  )

  box::use(
    path/to/module_b[b_obj_a],
  )

  glue(\"This {b_obj_a} should be parsed.\")
  "

  lintr::expect_lint(good_box_usage, NULL, linters = linter)
})

test_that("box_unused_att_mod_obj_linter skips functions used in glue string templates", {
  linter <- box_unused_att_mod_obj_linter()

  good_box_usage <- "box::use(
    glue[glue],
  )

  box::use(
    path/to/module_b[b_fun_a],
  )

  glue(\"This {b_fun_a()} should be parsed.\")
  "

  lintr::expect_lint(good_box_usage, NULL, linters = linter)
})

test_that("box_unused_att_mod_obj_linter skips literal braces in glue string templates", {
  linter <- box_unused_att_mod_obj_linter()
  lint_message <- rex::rex("Imported function/object unused.")

  bad_box_usage <- "box::use(
    glue[glue],
  )

  box::use(
    path/to/module_b[b_obj_a],
  )

  glue(\"This {{b_obj_a}} should be parsed.\")
  "

  lintr::expect_lint(bad_box_usage, list(message = lint_message), linters = linter)
})

test_that("box_unused_att_mod_obj_linter blocks unused objects in glue string templates", {
  linter <- box_unused_att_mod_obj_linter()
  lint_message <- rex::rex("Imported function/object unused.")

  bad_box_usage <- "box::use(
    glue[glue],
  )

  box::use(
    path/to/module_b[b_obj_a],
  )

  glue(\"This does not have a parseable object.\")
  "

  lintr::expect_lint(bad_box_usage, list(message = lint_message), linters = linter)
})

test_that("box_unused_att_mod_obj_linter allows relative module paths", {
  linter <- box_unused_att_mod_obj_linter()

  withr::with_options(
    list(
      "box.path" = NULL
    ), {
      withr::with_dir(file.path(getwd(), "mod", "path", "relative"), {
        code <- "box::use(../to/module_a[a_fun_a])
        a_fun_a()
        "
        lintr::expect_lint(code, NULL, linters = linter)

      })
    }
  )
})

test_that("box_unused_att_mod_obj_linter blocks unused functions from relative module paths", {
  linter <- box_unused_att_mod_obj_linter()
  lint_message <- rex::rex("Imported function/object unused.")

  withr::with_options(
    list(
      "box.path" = NULL
    ), {
      withr::with_dir(file.path(getwd(), "mod", "path", "relative"), {
        code <- "box::use(../to/module_a[a_fun_a])
        "
        lintr::expect_lint(code, list(message = lint_message), linters = linter)
      })
    }
  )
})
