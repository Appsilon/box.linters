code_to_xml_expr <- function(text_code) {
  xml2::read_xml(
    xmlparsedata::xml_parse_data(
      parse(text = text_code, keep.source = TRUE)
    )
  )
}

test_that("get_attached_packages returns correct list of imported whole packages", {
  whole_imported_packages <- "
  box::use(
    dplyr,
    stringr,
  )
  "

  xml_whole_imported_packages <- code_to_xml_expr(whole_imported_packages)
  results <- get_attached_packages(xml_whole_imported_packages)
  expected_results <- c("dplyr", "stringr")

  expect_equal(names(results$nested), expected_results)

  dplyr_functions <- getNamespaceExports("dplyr")
  expect_setequal(results$nested$dplyr, dplyr_functions)

  stringr_functions <- getNamespaceExports("stringr")
  expect_setequal(results$nested$stringr, stringr_functions)
})

test_that(
  "get_attached_packages returns correct list of imported whole packages in
separate box::use calls", {
    whole_imported_packages <- "
  box::use(
    dplyr,
    stringr,
  )
  box::use(
    fs
  )
  "

    xml_whole_imported_packages <- code_to_xml_expr(whole_imported_packages)
    results <- get_attached_packages(xml_whole_imported_packages)
    expected_results <- c("dplyr", "stringr", "fs")

    expect_equal(names(results$nested), expected_results)

    dplyr_functions <- getNamespaceExports("dplyr")
    expect_setequal(results$nested$dplyr, dplyr_functions)

    stringr_functions <- getNamespaceExports("stringr")
    expect_setequal(results$nested$stringr, stringr_functions)

    fs_functions <- getNamespaceExports("fs")
    expect_setequal(results$nested$fs, fs_functions)
  }
)

test_that("get_attached_packages does not return packages imported with '...'", {
  whole_imported_packages <- "
  box::use(
    dplyr[...],
    stringr,
  )
  "

  xml_whole_imported_packages <- code_to_xml_expr(whole_imported_packages)
  results <- get_attached_packages(xml_whole_imported_packages)
  expected_results <- c("stringr")

  expect_equal(names(results$nested), expected_results)
})

test_that("get_attached_packages does not return packages imported with functions", {
  whole_imported_packages <- "
  box::use(
    dplyr[`%>%`, select, filter],
    stringr,
  )
  "

  xml_whole_imported_packages <- code_to_xml_expr(whole_imported_packages)
  results <- get_attached_packages(xml_whole_imported_packages)
  expected_results <- c("stringr")

  expect_equal(names(results$nested), expected_results)
})

test_that("get_attached_packages returns correct list of aliased imported whole packages", {
  whole_imported_packages <- "
  box::use(
    pkg_alias = dplyr,
    stringr,
  )
  "

  xml_whole_imported_packages <- code_to_xml_expr(whole_imported_packages)
  results <- get_attached_packages(xml_whole_imported_packages)

  expected_results <- c("pkg_alias", "stringr")
  expect_equal(names(results$nested), expected_results)

  names(expected_results) <- c("dplyr", "stringr")
  expect_equal(results$aliases, expected_results)
})

test_that("get_attached_packages does not return aliased functions", {
  whole_imported_packages <- "
  box::use(
    dplyr[fun_alias = select],
    stringr,
  )
  "

  xml_whole_imported_packages <- code_to_xml_expr(whole_imported_packages)
  results <- get_attached_packages(xml_whole_imported_packages)

  expected_results <- c("stringr")
  expect_equal(names(results$nested), expected_results)

  names(expected_results) <- c("stringr")
  expect_equal(results$aliases, expected_results)
})

test_that("get_attached_packages does not return imported modules", {
  whole_imported_packages <- "
  box::use(
    dplyr,
    stringr,
  )

  box::use(
    path/to/module_a,
    path/to/module_b,
  )
  "

  xml_whole_imported_packages <- code_to_xml_expr(whole_imported_packages)
  results <- get_attached_packages(xml_whole_imported_packages)
  expected_results <- c("dplyr", "stringr")

  expect_equal(names(results$nested), expected_results)
})

test_that("get_attached_pkg_three_dots returns correct list of imported functions", {
  three_dots_import <- "
  box::use(
    dplyr[...],
    stringr[...],
  )
  "

  xml_three_dots_packages <- code_to_xml_expr(three_dots_import)
  results <- get_attached_pkg_three_dots(xml_three_dots_packages)

  dplyr_results <- getNamespaceExports("dplyr")
  stringr_results <- getNamespaceExports("stringr")

  expect_setequal(results$nested$dplyr, dplyr_results)
  expect_setequal(results$nested$stringr, stringr_results)

  expect_setequal(results$text, c(dplyr_results, stringr_results))
})

test_that(
  "get_attached_pkg_three_dots separate box::use returns correct list of imported functions", {
    three_dots_import <- "
  box::use(dplyr[...])
  box::use(stringr[...])
  "

    xml_three_dots_packages <- code_to_xml_expr(three_dots_import)
    results <- get_attached_pkg_three_dots(xml_three_dots_packages)

    dplyr_results <- getNamespaceExports("dplyr")
    stringr_results <- getNamespaceExports("stringr")

    expect_setequal(results$nested$dplyr, dplyr_results)
    expect_setequal(results$nested$stringr, stringr_results)

    expect_setequal(results$text, c(dplyr_results, stringr_results))
  }
)

test_that("get_attached_pkg_three_dots does not return whole imported packages", {
  three_dots_import <- "
  box::use(
    dplyr,
    stringr[...],
  )
  "

  xml_three_dots_packages <- code_to_xml_expr(three_dots_import)
  results <- get_attached_pkg_three_dots(xml_three_dots_packages)

  stringr_results <- getNamespaceExports("stringr")

  expect_setequal(results$nested$stringr, stringr_results)

  expect_setequal(results$text, c(stringr_results))
})

test_that("get_attached_pkg_three_dots does not return packages with imported functions", {
  three_dots_import <- "
  box::use(
    dplyr[select],
    stringr[...],
  )
  "

  xml_three_dots_packages <- code_to_xml_expr(three_dots_import)
  results <- get_attached_pkg_three_dots(xml_three_dots_packages)

  stringr_results <- getNamespaceExports("stringr")

  expect_setequal(results$nested$stringr, stringr_results)

  expect_setequal(results$text, c(stringr_results))
})

test_that("get_attached_pkg_three_dots does not return imported modules with three dots", {
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

  xml_three_dots_packages <- code_to_xml_expr(three_dots_import)
  results <- get_attached_pkg_three_dots(xml_three_dots_packages)

  dplyr_results <- getNamespaceExports("dplyr")
  stringr_results <- getNamespaceExports("stringr")

  expect_setequal(results$nested$dplyr, dplyr_results)
  expect_setequal(results$nested$stringr, stringr_results)

  expect_setequal(results$text, c(dplyr_results, stringr_results))
})

test_that("get_attached_pkg_functions returns correct list of imported functions", {
  pkg_fun_imports <- "
  box::use(
    dplyr[`%>%`, filter, select],
    stringr[str_count, str_pad],
  )
  "

  xml_pkg_fun_imports <- code_to_xml_expr(pkg_fun_imports)
  results <- get_attached_pkg_functions(xml_pkg_fun_imports)
  expected_results <- c("%>%", "filter", "select", "str_count", "str_pad")
  names(expected_results) <- c("%>%", "filter", "select", "str_count", "str_pad")

  expect_equal(results$text, expected_results)
})

test_that("get_attached_pkg_functions returns correct list of aliased imported functions", {
  pkg_fun_imports <- "
  box::use(
    dplyr[`%>%`, fun_alias = filter, select],
    stringr[str_count, gun_alias = str_pad],
  )
  "

  xml_pkg_fun_imports <- code_to_xml_expr(pkg_fun_imports)
  results <- get_attached_pkg_functions(xml_pkg_fun_imports)
  expected_results <- c("%>%", "fun_alias", "select", "str_count", "gun_alias")
  names(expected_results) <- c("%>%", "filter", "select", "str_count", "str_pad")

  expect_equal(results$text, expected_results)
  expect_equal(names(results$text), names(expected_results))
})

test_that("get_attached_pkg_functions does not return whole imported packages", {
  pkg_fun_imports <- "
  box::use(
    dplyr[`%>%`, filter, select],
    shiny,
    stringr[str_count, str_pad],
  )
  "

  xml_pkg_fun_imports <- code_to_xml_expr(pkg_fun_imports)
  results <- get_attached_pkg_functions(xml_pkg_fun_imports)
  expected_results <- c("%>%", "filter", "select", "str_count", "str_pad")

  expect_setequal(results$text, expected_results)
})


test_that("get_attached_pkg_functions does not return aliased whole imported packages", {
  pkg_fun_imports <- "
  box::use(
    dplyr[`%>%`, filter, select],
    pkg_alias = shiny,
    stringr[str_count, str_pad],
  )
  "

  xml_pkg_fun_imports <- code_to_xml_expr(pkg_fun_imports)
  results <- get_attached_pkg_functions(xml_pkg_fun_imports)
  expected_results <- c("%>%", "filter", "select", "str_count", "str_pad")

  expect_setequal(results$text, expected_results)
})

test_that("get_attached_pkg_functions does not return whole imported packages with three dots", {
  pkg_fun_imports <- "
  box::use(
    dplyr[`%>%`, filter, select],
    shiny[...],
    stringr[str_count, str_pad],
  )
  "

  xml_pkg_fun_imports <- code_to_xml_expr(pkg_fun_imports)
  results <- get_attached_pkg_functions(xml_pkg_fun_imports)
  expected_results <- c("%>%", "filter", "select", "str_count", "str_pad")

  expect_setequal(results$text, expected_results)
})

test_that("get_attached_pkg_functions does not return functions from modules", {
  pkg_fun_imports <- "
  box::use(
    dplyr[`%>%`, filter, select],
    stringr[str_count, str_pad],
  )

  box::use(
    path/to/module[fun_a, fun_b],
  )
  "

  xml_pkg_fun_imports <- code_to_xml_expr(pkg_fun_imports)
  results <- get_attached_pkg_functions(xml_pkg_fun_imports)
  expected_results <- c("%>%", "filter", "select", "str_count", "str_pad")

  expect_setequal(results$text, expected_results)
})
