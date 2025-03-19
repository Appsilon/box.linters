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
