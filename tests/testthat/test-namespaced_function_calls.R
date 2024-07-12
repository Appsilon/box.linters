test_that("namespaced_function_calls() skips allowed box::*() calls", {
  linter <- namespaced_function_calls()

  code <- "box::use(package)
box::export()
box::file()
box::name()"

  lintr::expect_lint(code, NULL, linter)
})

test_that("namespaced_function_calls() blocks non-box namespace calls", {
  linter <- namespaced_function_calls()
  lint_message <- rex::rex(
    "Explicit `package::function()` calls are not advisible when using `box` modules."
  )

  code <- "box::use(package)
  tidyr::pivot_longer()
  "

  lintr::expect_lint(code, list(message = lint_message), linter)
})

test_that("namespaced_function_calls() skips excluded namespace calls", {
  linter <- namespaced_function_calls(allow = c("tidyr"))

  code <- "box::use(package)
  tidyr::pivot_longer()
  "

  lintr::expect_lint(code, NULL, linter)
})

test_that("namespaced_function_calls() skips excluded namespace::function calls", {
  linter <- namespaced_function_calls(allow = c("tidyr::pivot_longer"))

  code <- "box::use(package)
  tidyr::pivot_longer()
  "

  lintr::expect_lint(code, NULL, linter)
})
