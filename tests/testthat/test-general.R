test_that("Should skip columns in dplyr commands", {
  linters <- lintr::linters_with_defaults(defaults = box.linters::rhino_default_linters)

  code <- "
box::use(
  dplyr[`%>%`, filter, select],
)

mtcars %>%
  select(mpg, cyl) %>%
  filter(mpg <= 10)"

  lintr::expect_lint(code, NULL, linters)
})

test_that("Should skip native pipe `|>` operator", {
  linters <- lintr::linters_with_defaults(defaults = box.linters::rhino_default_linters)

  code <- "
box::use(
  dplyr[filter, select],
)

mtcars |>
  select(mpg, cyl) |>
  filter(mpg <= 10)"

  lintr::expect_lint(code, NULL, linters)
})

options(box.path = file.path(getwd(), "mod"))

test_that("Should skip allowed non-syntactic names: package special", {
  linters <- lintr::linters_with_defaults(defaults = box.linters::box_default_linters)

  code <- "
box::use(
  magrittr[`%>%`],
)

c(1, 2, 3) %>% sum()"

  lintr::expect_lint(code, NULL, linters)
})

test_that("Should skip allowed non-syntactic names: module special", {
  linters <- lintr::linters_with_defaults(defaults = box.linters::box_default_linters)

  code <- "
box::use(
  path/to/module_nonsyntactic[`%--%`],
)

2 %--% 4"

  lintr::expect_lint(code, NULL, linters)
})

test_that("Should skip allowed non-syntactic names: module function", {
  linters <- lintr::linters_with_defaults(defaults = box.linters::box_default_linters)

  code <- "
box::use(
  path/to/module_nonsyntactic[`01_function`],
)

`01_function`()"

  lintr::expect_lint(code, NULL, linters)
})

test_that("Should skip allowed non-syntactic names: module function three dots", {
  linters <- lintr::linters_with_defaults(defaults = box.linters::box_default_linters)

  code <- "
box::use(
  path/to/module_nonsyntactic[...],
)

`01_function`()"

  lintr::expect_lint(code, NULL, linters)
})

test_that("Should skip allowed non-syntactic names: declared function", {
  linters <- lintr::linters_with_defaults(defaults = box.linters::box_default_linters)

  code <- "
`01_function` <- function() {

}

`01_function`()"

  lintr::expect_lint(code, NULL, linters)
})


test_that("Should skip allowed non-syntactic names: declared special", {
  linters <- lintr::linters_with_defaults(defaults = box.linters::box_default_linters)

  code <- "
`%--%` <- function() {

}

2 %--% 4"

  lintr::expect_lint(code, NULL, linters)
})

test_that("Should skip allowed non-syntactic names: declared object", {
  linters <- lintr::linters_with_defaults(defaults = box.linters::box_default_linters)

  code <- "
x <- 4
x

`01_object` <- 4

`01_object`"

  lintr::expect_lint(code, NULL, linters)
})

test_that("Should skip allowed non-syntactic names: modules three-dots", {
  linters <- lintr::linters_with_defaults(defaults = box.linters::box_default_linters)

  code <- "
box::use(
  path/to/`01_module`[...],
  path/to/`__module__`[...],
)

a_fun_a()
`01_fun`()
b_fun_a()
`02_fun`()"

  lintr::expect_lint(code, NULL, linters)
})
