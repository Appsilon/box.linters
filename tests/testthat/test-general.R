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

test_that("Should allow modules with nothing exported, and assume all exported - namespaced.", {
  linters <- lintr::linters_with_defaults(defaults = box.linters::box_default_linters)

  code <- "box::use(
  path/to/module_all
)

module_all$all_fun_a()
module_all$all_fun_c()
module_all$all_obj_a"

  lintr::expect_lint(code, NULL, linters)
})

test_that("Should allow modules with nothing exported, and assume all exported - function", {
  linters <- lintr::linters_with_defaults(defaults = box.linters::box_default_linters)

  code <- "box::use(
  path/to/module_all[all_fun_a]
)

all_fun_a()"

  lintr::expect_lint(code, NULL, linters)
})

test_that("Should allow modules with nothing exported, and assume all exported - dots.", {
  linters <- lintr::linters_with_defaults(defaults = box.linters::box_default_linters)

  code <- "box::use(
  path/to/module_all[...]
)

all_fun_a()
all_fun_c()"

  lintr::expect_lint(code, NULL, linters)
})
