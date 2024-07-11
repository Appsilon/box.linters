options(box.path = file.path(getwd(), "mod"))

code_to_xml_expr <- function(text_code) {
  xml2::read_xml(
    xmlparsedata::xml_parse_data(
      parse(text = text_code, keep.source = TRUE)
    )
  )
}

test_that("get_attached_modules returns correct list of imported whole modules", {
  whole_imported_modules <- "
  box::use(
    path/to/module_a,
    path/to/module_b
  )
  "

  xml_whole_imported_modules <- code_to_xml_expr(whole_imported_modules)
  results <- get_attached_modules(xml_whole_imported_modules)
  expected_results <- c("module_a", "module_b")

  expect_equal(names(results$nested), expected_results)

  module_a_objects <- c("a_fun_a", "a_fun_b")
  expect_setequal(results$nested$module_a, module_a_objects)

  module_b_objects <- c("b_fun_a", "b_fun_b", "b_obj_a")
  expect_setequal(results$nested$module_b, module_b_objects)
})

test_that("get_attached_modules returns correct list of imported whole modules in separate calls", {
  whole_imported_modules <- "
  box::use(path/to/module_a)
  box::use(alias = path/to/module_b, path/to/module_c)
  "

  xml_whole_imported_modules <- code_to_xml_expr(whole_imported_modules)
  results <- get_attached_modules(xml_whole_imported_modules)
  expected_results <- c("module_a", "alias", "module_c")

  expect_equal(names(results$nested), expected_results)

  module_a_objects <- c("a_fun_a", "a_fun_b")
  expect_setequal(results$nested$module_a, module_a_objects)

  module_b_objects <- c("b_fun_a", "b_fun_b", "b_obj_a")
  expect_setequal(results$nested$alias, module_b_objects)

  module_c_objects <- c("c_fun_a", "c_fun_b", "c_obj_a")
  expect_setequal(results$nested$module_c, module_c_objects)
})

test_that("get_attached_modules does not return modules imported with '...'", {
  whole_imported_modules <- "
  box::use(
    path/to/module_a[...],
    path/to/module_b
  )
  "

  xml_whole_imported_modules <- code_to_xml_expr(whole_imported_modules)
  results <- get_attached_modules(xml_whole_imported_modules)
  expected_results <- c("module_b")

  expect_equal(names(results$nested), expected_results)

  module_b_objects <- c("b_fun_a", "b_fun_b", "b_obj_a")
  expect_setequal(results$nested$module_b, module_b_objects)
})

test_that("get_attached_modules does not return modules imported with functions", {
  whole_imported_modules <- "
  box::use(
    path/to/module_a[a_fun_a, a_fun_b],
    path/to/module_b
  )
  "

  xml_whole_imported_modules <- code_to_xml_expr(whole_imported_modules)
  results <- get_attached_modules(xml_whole_imported_modules)
  expected_results <- c("module_b")

  expect_equal(names(results$nested), expected_results)

  module_b_objects <- c("b_fun_a", "b_fun_b", "b_obj_a")
  expect_setequal(results$nested$module_b, module_b_objects)
})

test_that("get_attached_modules returns correct list of aliased imported whole modules", {
  whole_imported_modules <- "
  box::use(
    mod_alias = path/to/module_a,
    path/to/module_b
  )
  "

  xml_whole_imported_modules <- code_to_xml_expr(whole_imported_modules)
  results <- get_attached_modules(xml_whole_imported_modules)

  expected_results <- c("mod_alias", "module_b")
  expect_equal(names(results$nested), expected_results)

  names(expected_results) <- c("module_a", "module_b")
  expect_equal(results$aliases, expected_results)
})

test_that("get_attached_modules does not return aliased functions", {
  whole_imported_modules <- "
  box::use(
    path/to/module_a[fun_alias = a_fun_a, a_fun_b],
    path/to/module_b
  )
  "

  xml_whole_imported_modules <- code_to_xml_expr(whole_imported_modules)
  results <- get_attached_modules(xml_whole_imported_modules)
  expected_results <- c("module_b")

  expect_equal(names(results$nested), expected_results)

  module_b_objects <- c("b_fun_a", "b_fun_b", "b_obj_a")
  expect_setequal(results$nested$module_b, module_b_objects)
})

withr::with_options(
  list(
    box.path = file.path(getwd(), "mod", "path")
  ),
  {
    test_that("get_attached_modules returns correct list of imported whole modules", {
      whole_imported_modules <- "
      box::use(
        to/module_a,
        to/module_b
      )
      "

      xml_whole_imported_modules <- code_to_xml_expr(whole_imported_modules)
      results <- get_attached_modules(xml_whole_imported_modules)
      expected_results <- c("module_a", "module_b")

      expect_equal(names(results$nested), expected_results)

      module_a_objects <- c("a_fun_a", "a_fun_b")
      expect_setequal(results$nested$module_a, module_a_objects)

      module_b_objects <- c("b_fun_a", "b_fun_b", "b_obj_a")
      expect_setequal(results$nested$module_b, module_b_objects)
    })

    test_that("get_attached_modules does not return modules imported with '...'", {
      whole_imported_modules <- "
      box::use(
        to/module_a[...],
        to/module_b
      )
      "

      xml_whole_imported_modules <- code_to_xml_expr(whole_imported_modules)
      results <- get_attached_modules(xml_whole_imported_modules)
      expected_results <- c("module_b")

      expect_equal(names(results$nested), expected_results)

      module_b_objects <- c("b_fun_a", "b_fun_b", "b_obj_a")
      expect_setequal(results$nested$module_b, module_b_objects)
    })

    test_that("get_attached_modules does not return modules imported with functions", {
      whole_imported_modules <- "
      box::use(
        to/module_a[a_fun_a, a_fun_b],
        to/module_b
      )
      "

      xml_whole_imported_modules <- code_to_xml_expr(whole_imported_modules)
      results <- get_attached_modules(xml_whole_imported_modules)
      expected_results <- c("module_b")

      expect_equal(names(results$nested), expected_results)

      module_b_objects <- c("b_fun_a", "b_fun_b", "b_obj_a")
      expect_setequal(results$nested$module_b, module_b_objects)
    })

    test_that("get_attached_modules returns correct list of aliased imported whole modules", {
      whole_imported_modules <- "
      box::use(
        mod_alias = to/module_a,
        to/module_b
      )
      "

      xml_whole_imported_modules <- code_to_xml_expr(whole_imported_modules)
      results <- get_attached_modules(xml_whole_imported_modules)

      expected_results <- c("mod_alias", "module_b")
      expect_equal(names(results$nested), expected_results)

      names(expected_results) <- c("module_a", "module_b")
      expect_equal(results$aliases, expected_results)
    })

    test_that("get_attached_modules does not return aliased functions", {
      whole_imported_modules <- "
      box::use(
        to/module_a[fun_alias = a_fun_a, a_fun_b],
        to/module_b
      )
      "

      xml_whole_imported_modules <- code_to_xml_expr(whole_imported_modules)
      results <- get_attached_modules(xml_whole_imported_modules)
      expected_results <- c("module_b")

      expect_equal(names(results$nested), expected_results)

      module_b_objects <- c("b_fun_a", "b_fun_b", "b_obj_a")
      expect_setequal(results$nested$module_b, module_b_objects)
    })
  }
)

test_that("get_attached_modules does not return imported packages", {
  whole_imported_modules <- "
  box::use(
    dplyr,
    shiny,
  )

  box::use(
    path/to/module_a,
    path/to/module_b
  )
  "

  xml_whole_imported_modules <- code_to_xml_expr(whole_imported_modules)
  results <- get_attached_modules(xml_whole_imported_modules)
  expected_results <- c("module_a", "module_b")

  expect_equal(names(results$nested), expected_results)

  module_a_objects <- c("a_fun_a", "a_fun_b")
  expect_setequal(results$nested$module_a, module_a_objects)

  module_b_objects <- c("b_fun_a", "b_fun_b", "b_obj_a")
  expect_setequal(results$nested$module_b, module_b_objects)
})

test_that("get_attached_mod_three_dots returns correct list of imported functions", {
  three_dots_import <- "
  box::use(
    path/to/module_a[...],
    path/to/module_b[...],
  )
  "

  xml_three_dots_modules <- code_to_xml_expr(three_dots_import)
  results <- get_attached_mod_three_dots(xml_three_dots_modules)

  module_a_objects <- c("a_fun_a", "a_fun_b")
  module_b_objects <- c("b_fun_a", "b_fun_b", "b_obj_a")

  expect_setequal(results$nested$module_a, module_a_objects)
  expect_setequal(results$nested$module_b, module_b_objects)

  expect_setequal(results$text, c(module_a_objects, module_b_objects))
})

test_that(
  "get_attached_mod_three_dots returns correct list of imported functions in separate calls", {
    three_dots_import <- "
  box::use(path/to/module_a[...])
  box::use(path/to/module_b[...])
  "

    xml_three_dots_modules <- code_to_xml_expr(three_dots_import)
    results <- get_attached_mod_three_dots(xml_three_dots_modules)

    module_a_objects <- c("a_fun_a", "a_fun_b")
    module_b_objects <- c("b_fun_a", "b_fun_b", "b_obj_a")

    expect_setequal(results$nested$module_a, module_a_objects)
    expect_setequal(results$nested$module_b, module_b_objects)

    expect_setequal(results$text, c(module_a_objects, module_b_objects))
  }
)

test_that("get_attached_mod_three_dots does not return whole imported modules", {
  three_dots_import <- "
  box::use(
    path/to/module_a,
    path/to/module_b[...],
  )
  "

  xml_three_dots_modules <- code_to_xml_expr(three_dots_import)
  results <- get_attached_mod_three_dots(xml_three_dots_modules)
  expected_results <- c("module_b")

  expect_equal(names(results$nested), expected_results)

  module_b_objects <- c("b_fun_a", "b_fun_b", "b_obj_a")
  expect_setequal(results$nested$module_b, module_b_objects)
})

test_that("get_attached_mod_three_dots does not return modules with imported functions", {
  three_dots_import <- "
  box::use(
    path/to/module_a[a_fun_a],
    path/to/module_b[...],
  )
  "

  xml_three_dots_modules <- code_to_xml_expr(three_dots_import)
  results <- get_attached_mod_three_dots(xml_three_dots_modules)
  expected_results <- c("module_b")

  expect_equal(names(results$nested), expected_results)

  module_b_objects <- c("b_fun_a", "b_fun_b", "b_obj_a")
  expect_setequal(results$nested$module_b, module_b_objects)
})

test_that("get_attached_mod_three_dots does not return imported packages with three dots", {
  three_dots_import <- "
  box::use(
    dplyr[...],
    stringr[...],
  )

  box::use(
    path/to/module_a[...],
    path/to/module_b[...],
  )
  "

  xml_three_dots_modules <- code_to_xml_expr(three_dots_import)
  results <- get_attached_mod_three_dots(xml_three_dots_modules)

  module_a_objects <- c("a_fun_a", "a_fun_b")
  module_b_objects <- c("b_fun_a", "b_fun_b", "b_obj_a")

  expect_setequal(results$nested$module_a, module_a_objects)
  expect_setequal(results$nested$module_b, module_b_objects)

  expect_setequal(results$text, c(module_a_objects, module_b_objects))
})

test_that("get_attached_mod_functions returns correct list of imported functions", {
  mod_fun_imports <- "
  box::use(
    path/to/module_a[a_fun_a, a_fun_b],
    path/to/module_b[b_fun_a, b_fun_b],
  )
  "

  xml_mod_fun_imports <- code_to_xml_expr(mod_fun_imports)
  results <- get_attached_mod_functions(xml_mod_fun_imports)
  expected_results <- c("a_fun_a", "a_fun_b", "b_fun_a", "b_fun_b")
  names(expected_results) <- c("a_fun_a", "a_fun_b", "b_fun_a", "b_fun_b")

  expect_equal(results$text, expected_results)
})

test_that("get_attached_mod_functions returns correct list of aliased imported functions", {
  mod_fun_imports <- "
  box::use(
    path/to/module_a[fun_alias = a_fun_a, a_fun_b],
    path/to/module_b[b_fun_a, gun_alias = b_fun_b],
  )
  "

  xml_mod_fun_imports <- code_to_xml_expr(mod_fun_imports)
  results <- get_attached_mod_functions(xml_mod_fun_imports)
  expected_results <- c("fun_alias", "a_fun_b", "b_fun_a", "gun_alias")
  names(expected_results) <- c("a_fun_a", "a_fun_b", "b_fun_a", "b_fun_b")

  expect_equal(results$text, expected_results)
})

test_that("get_attached_mod_functions does not return whole imported modules", {
  mod_fun_imports <- "
  box::use(
    path/to/module_a[a_fun_a, a_fun_b],
    path/to/module_b[b_fun_a, b_fun_b],
    path/to/module_c,
  )
  "

  xml_mod_fun_imports <- code_to_xml_expr(mod_fun_imports)
  results <- get_attached_mod_functions(xml_mod_fun_imports)
  expected_results <- c("a_fun_a", "a_fun_b", "b_fun_a", "b_fun_b")
  names(expected_results) <- c("a_fun_a", "a_fun_b", "b_fun_a", "b_fun_b")

  expect_equal(results$text, expected_results)
})


test_that("get_attached_modg_functions does not return aliased whole imported modules", {
  mod_fun_imports <- "
  box::use(
    path/to/module_a[a_fun_a, a_fun_b],
    path/to/module_b[b_fun_a, b_fun_b],
    mod_alias = path/to/module_c,
  )
  "

  xml_mod_fun_imports <- code_to_xml_expr(mod_fun_imports)
  results <- get_attached_mod_functions(xml_mod_fun_imports)
  expected_results <- c("a_fun_a", "a_fun_b", "b_fun_a", "b_fun_b")
  names(expected_results) <- c("a_fun_a", "a_fun_b", "b_fun_a", "b_fun_b")

  expect_equal(results$text, expected_results)
})

test_that("get_attached_mod_functions does not return whole imported modules with three dots", {
  mod_fun_imports <- "
  box::use(
    path/to/module_a[a_fun_a, a_fun_b],
    path/to/module_b[b_fun_a, b_fun_b],
    path/to/module_c[...],
  )
  "

  xml_mod_fun_imports <- code_to_xml_expr(mod_fun_imports)
  results <- get_attached_mod_functions(xml_mod_fun_imports)
  expected_results <- c("a_fun_a", "a_fun_b", "b_fun_a", "b_fun_b")
  names(expected_results) <- c("a_fun_a", "a_fun_b", "b_fun_a", "b_fun_b")

  expect_equal(results$text, expected_results)
})

test_that("get_attached_mod_functions does not return functions from packages", {
  mod_fun_imports <- "
  box::use(
    dplyr[`%>%`, filter, select],
    stringr[str_count, str_pad],
  )

  box::use(
    path/to/module_a[a_fun_a, a_fun_b],
    path/to/module_b[b_fun_a, b_fun_b],
    mod_aliasa = path/to/module_c,
  )
  "

  xml_mod_fun_imports <- code_to_xml_expr(mod_fun_imports)
  results <- get_attached_mod_functions(xml_mod_fun_imports)
  expected_results <- c("a_fun_a", "a_fun_b", "b_fun_a", "b_fun_b")
  names(expected_results) <- c("a_fun_a", "a_fun_b", "b_fun_a", "b_fun_b")

  expect_equal(results$text, expected_results)
})
