options(box.path = file.path(getwd(), "mod"))

test_that("box_mod_fun_exists_linter skips valid moduke-function attachements", {
  linter <- box_mod_fun_exists_linter()

  good_box_usage <- "box::use(
    fs,
    glue,
  )

  box::use(
    path/to/module_a[a_fun_a, a_fun_b],
    path/to/module_b[b_fun_b, b_obj_a],
  )
  "

  lintr::expect_lint(good_box_usage, NULL, linter)
})

test_that("box_mod_fun_exists_linter is not affected by aliases", {
  linter <- box_mod_fun_exists_linter()

  good_box_usage <- "box::use(
    fs,
    glue,
  )

  box::use(
    path/to/module_a[fun_alias = a_fun_a, a_fun_b],
    path/to/module_b[b_fun_b, b_obj_a],
  )
  "

  lintr::expect_lint(good_box_usage, NULL, linter)
})

test_that("box_mod_fun_exists_linter blocks functions that do not exist in module", {
  linter <- box_mod_fun_exists_linter()
  lint_message <- rex::rex("Function not exported by module.")

  bad_box_usage <- "box::use(
    fs,
    glue,
  )

  box::use(
    path/to/module_a[a_fun_a, not_exist],
    path/to/module_b[b_fun_b, b_obj_a],
  )
  "

  lintr::expect_lint(bad_box_usage, list(message = lint_message), linter)
})

test_that("box_mod_fun_exists_linter blocks aliased functions that do not exist in module", {
  linter <- box_mod_fun_exists_linter()
  lint_message <- rex::rex("Function not exported by module.")

  bad_box_usage <- "box::use(
    fs,
    glue,
  )

  box::use(
    path/to/module_a[fun_alias = a_fun_a, not_exist],
    path/to/module_b[b_fun_b, b_obj_a],
  )
  "

  lintr::expect_lint(bad_box_usage, list(message = lint_message), linter)
})

test_that("box_mod_fun_exists_linter allows relative module paths", {
  linter <- box_mod_fun_exists_linter()

  withr::with_options(
    list(
      "box.path" = NULL
    ), {
      withr::with_dir(file.path(getwd(), "mod", "path", "relative"), {
        expect_no_message(lintr::lint("module_d.R", linters = linter))
      })
    }
  )
})

test_that("box_mod_fun_exists_linter blocks non-existing functions in relative module paths", {
  linter <- box_mod_fun_exists_linter()
  lint_message <- "Function not exported by module."
  withr::with_options(
    list(
      "box.path" = NULL
    ), {
      withr::with_dir(file.path(getwd(), "mod", "path", "relative"), {
        result <- lintr::lint("module_f.R", linters = linter)
      })
    }
  )

  expect_s3_class(result, "lints")
  expect_equal(result[[1]]$message, lint_message)
})
