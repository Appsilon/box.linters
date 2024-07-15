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


# Glue compatibility

test_that("box_unused_attached_mod_linter skips objects used in glue string templates", {
  linter <- box_unused_attached_mod_linter()

  good_box_usage <- "box::use(
    glue,
  )

  box::use(
    path/to/module_b,
  )

  glue$glue(\"This {module_b$b_obj_a} should be parsed.\")
  "

  lintr::expect_lint(good_box_usage, NULL, linters = linter)
})

test_that("box_unused_attached_mod_linter skips functions used in glue string templates", {
  linter <- box_unused_attached_mod_linter()

  good_box_usage <- "box::use(
    glue[glue],
  )

  box::use(
    path/to/module_b,
  )

  glue(\"This {module_b$b_fun_a()} should be parsed.\")
  "

  lintr::expect_lint(good_box_usage, NULL, linters = linter)
})

test_that("box_unused_attached_mod_linter skips literal braces in glue string templates", {
  linter <- box_unused_attached_mod_linter()
  lint_message <- rex::rex("Attached module unused.")

  bad_box_usage <- "box::use(
    glue[glue],
  )

  box::use(
    path/to/module_b,
  )

  glue(\"This {{module_b$b_obj_a}} should be parsed.\")
  "

  lintr::expect_lint(bad_box_usage, list(message = lint_message), linters = linter)
})

test_that("box_unused_attached_mod_linter blocks unused objects in glue string templates", {
  linter <- box_unused_attached_mod_linter()
  lint_message <- rex::rex("Attached module unused.")

  bad_box_usage <- "box::use(
    glue[glue],
  )

  box::use(
    path/to/module_b,
  )

  glue(\"This does not have a parseable object.\")
  "

  lintr::expect_lint(bad_box_usage, list(message = lint_message), linters = linter)
})

# Glue compatibility three dots

test_that("box_unused_attached_mod_linter skips objects used in glue string templates", {
  linter <- box_unused_attached_mod_linter()

  good_box_usage <- "box::use(
    glue[glue],
  )

  box::use(
    path/to/module_b[...],
  )

  glue(\"This {b_obj_a} should be parsed.\")
  "

  lintr::expect_lint(good_box_usage, NULL, linters = linter)
})

test_that("box_unused_attached_mod_linter skips functions used in glue string templates", {
  linter <- box_unused_attached_mod_linter()

  good_box_usage <- "box::use(
    glue[glue],
  )

  box::use(
    path/to/module_b[...],
  )

  glue(\"This {b_fun_a()} should be parsed.\")
  "

  lintr::expect_lint(good_box_usage, NULL, linters = linter)
})

test_that("box_unused_attached_mod_linter skips literal braces in glue string templates", {
  linter <- box_unused_attached_mod_linter()
  lint_message <- rex::rex("Three-dots attached module unused.")

  bad_box_usage <- "box::use(
    glue[glue],
  )

  box::use(
    path/to/module_b[...],
  )

  glue(\"This {{b_obj_a}} should be parsed.\")
  "

  lintr::expect_lint(bad_box_usage, list(message = lint_message), linters = linter)
})

test_that("box_unused_attached_mod_linter blocks unused objects in glue string templates", {
  linter <- box_unused_attached_mod_linter()
  lint_message <- rex::rex("Three-dots attached module unused.")

  bad_box_usage <- "box::use(
    glue[glue],
  )

  box::use(
    path/to/module_b[...],
  )

  glue(\"This does not have a parseable object.\")
  "

  lintr::expect_lint(bad_box_usage, list(message = lint_message), linters = linter)
})

test_that("box_unused_attached_mod_linter works with relative paths", {
  linter <- box_unused_attached_mod_linter()

  withr::with_options(
    list(
      "box.path" = NULL
    ),
    withr::with_dir(file.path(getwd(), "mod", "path", "relative"), {
      expect_no_message(lintr::lint("module_d.R", linters = linter))
    })
  )
})

test_that("box_unused_attached_mod_linter detects unused modules with relative paths", {
  linter <- box_unused_attached_mod_linter()
  lint_message <- "Attached module unused."

  withr::with_options(
    list(
      "box.path" = NULL
    ),
    withr::with_dir(file.path(getwd(), "mod", "path", "relative"), {
      result <- lintr::lint("module_g.R", linters = linter)
    })
  )

  expect_s3_class(result, "lints")
  expect_equal(result[[1]]$message, lint_message)
})

# Box test interfaces, not implementations

test_that("box_unused_attached_mod_linter skips module call as implementation test", {
  linter <- box_unused_attached_mod_linter()

  code <- "box::use(
    path/to/module_a,
  )

  impl = attr(module_a, \"namespace\")

  test_that(\"implementation detail X works\", {
    expect_true(impl$a_fun_c())
  })
  "

  lintr::expect_lint(code, NULL, linter = linter)
})

test_that("box_unused_attached_mod_linter blocks unused module call as implementation test", {
  linter <- box_unused_attached_mod_linter()
  lint_message <- rex::rex("Attached module unused.")

  code <- "box::use(
    path/to/module_a,
  )

  impl = attr(module_b, \"namespace\")

  test_that(\"implementation detail X works\", {
    expect_true(impl$a_fun_c())
  })
  "

  lintr::expect_lint(code, list(message = lint_message), linter = linter)
})
