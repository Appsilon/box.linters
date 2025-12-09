
options(box.path = file.path(getwd(), "mod"))

test_that("Should skip allowed non-syntactic names: locally declared objects and functions", {
  linters <- lintr::linters_with_defaults(defaults = box.linters::box_default_linters)

  code <- "
`%--%` <- function(x, y) {
  x * y
}

`1_func` <- function() {
  \"A\"
}

`1_obj` <- \"B\"

2 %--% 4
`1_func`()
`1_obj`"

  lintr::expect_lint(code, NULL, linters)
})

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

test_that("Should skip allowed non-syntactic names: modules functions", {
  linters <- lintr::linters_with_defaults(defaults = box.linters::box_default_linters)

  code <- "
box::use(
  path/to/`01_module`[a_fun_a, `01_fun`],
  path/to/`__module__`[b_fun_a, `02_fun`],
)

a_fun_a()
`01_fun`()
b_fun_a()
`02_fun`()"

  lintr::expect_lint(code, NULL, linters)
})

test_that("Should skip allowed non-syntactic names: modules", {
  linters <- lintr::linters_with_defaults(defaults = box.linters::box_default_linters)

  code <- "
box::use(
  path/to/`01_module`,
  path/to/`__module__`,
)

`01_module`$a_fun_a()
`01_module`$`01_fun`()
`__module__`$b_fun_a()
`__module__`$`02_fun`()"

  lintr::expect_lint(code, NULL, linters)
})
