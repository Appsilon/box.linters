options(box.path = file.path(getwd(), "mod"))

test_that("box_usage_linter skips allowed module[function] attachment.", {
  linter <- box_usage_linter()

  # good_box_usage_1 <- "box::use(
  #   dplyr[`%>%`, select, filter],
  #   stringr[str_pad],
  # )
  #
  # mtcars %>%
  #   select(mpg, cyl) %>%
  #   filter(mpg <= 10)
  # "
  #
  # lintr::expect_lint(good_box_usage_1, NULL, linter)
})

test_that("box_usage_linter skips allowed module[function] alias attachment.", {
  linter <- box_usage_linter()

  # good_box_usage_1 <- "box::use(
  #   dplyr[`%>%`, fun_alias = select, filter],
  #   stringr[gun_alias = str_pad],
  # )
  #
  # mtcars %>%
  #   fun_alias(mpg, cyl) %>%
  #   filter(mpg <= 10)
  #
  # gun_alias()
  # "
  #
  # lintr::expect_lint(good_box_usage_1, NULL, linter)
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

  # good_box_usage_3 <- "box::use(
  #   glue[...]
  # )
  #
  # name <- 'Fred'
  # glue_sql('My name is {name}.')
  # "
  #
  # lintr::expect_lint(good_box_usage_3, NULL, linter)
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
