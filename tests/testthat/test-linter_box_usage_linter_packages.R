test_that("box_usage_linter skips allowed package[function] attachment.", {
  linter <- box_usage_linter()

  good_box_usage_1 <- "box::use(
    dplyr[`%>%`, select, filter],
    stringr[str_pad],
  )

  mtcars %>%
    select(mpg, cyl) %>%
    filter(mpg <= 10)
  "

  lintr::expect_lint(good_box_usage_1, NULL, linter)
})

test_that("box_usage_linter skips allowed package[function] alias attachment.", {
  linter <- box_usage_linter()

  good_box_usage_1 <- "box::use(
    dplyr[`%>%`, fun_alias = select, filter],
    stringr[gun_alias = str_pad],
  )

  mtcars %>%
    fun_alias(mpg, cyl) %>%
    filter(mpg <= 10)

  gun_alias()
  "

  lintr::expect_lint(good_box_usage_1, NULL, linter)
})

test_that("box_usage_linter skips allowed package attachment", {
  linter <- box_usage_linter()

  good_box_usage_2 <- "box::use(
    shiny[NS],
    glue,
    fs[path_file],
  )

  name <- 'Fred'
  glue$glue('My name is {name}.')

  path_file('dir/file.zip')

  ns <- NS()
  "

  lintr::expect_lint(good_box_usage_2, NULL, linter)
})

test_that("box_usage_linter skips allowed package alias attachment", {
  linter <- box_usage_linter()

  good_box_usage_2 <- "box::use(
    shiny[NS],
    pkg_alias = glue,
    fs[path_file],
  )

  name <- 'Fred'
  pkg_alias$glue('My name is {name}.')

  path_file('dir/file.zip')

  ns <- NS()
  "

  lintr::expect_lint(good_box_usage_2, NULL, linter)
})

test_that("box_usage_linter skips allowed package[...] attachment", {
  linter <- box_usage_linter()

  good_box_usage_3 <- "box::use(
    glue[...]
  )

  name <- 'Fred'
  glue_sql('My name is {name}.')
  "

  lintr::expect_lint(good_box_usage_3, NULL, linter)
})

test_that("box_usage_linter blocks package functions exported by package", {
  linter <- box_usage_linter()
  lint_message_2 <- rex::rex("<package/module>$function does not exist.")

  # xyz is not exported by glue
  bad_box_usage_2 <- "box::use(
    glue,
    fs[path_file],
  )

  name <- 'Fred'
  glue$xyz('My name is {name}.')

  path_file('dir/file.zip')
  "

  lintr::expect_lint(bad_box_usage_2, list(message = lint_message_2), linter)
})
