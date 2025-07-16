box_unique_names_linter <- function() {
  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "file")) {
      return(list())
    }

    xml <- source_expression$full_xml_parsed_content

    attached_packages <- get_attached_packages(xml)
    attached_pkg_functions <- get_attached_pkg_functions(xml)
    attached_pkg_three_dots <- get_attached_pkg_three_dots(xml)

    attached_modules <- get_attached_modules(xml)
    attached_mod_functions <- get_attached_mod_functions(xml)
    attached_mod_three_dots <- get_attached_mod_three_dots(xml)

    combined_packages_and_functions <- list()
    combined_packages_and_functions$xml <- c(
      attached_packages$xml,
      attached_pkg_functions$xml,
      attached_modules$xml
    )
    class(combined_packages_and_functions$xml) <- "xml_nodeset"
    combined_packages_and_functions$aliases <- c(
      attached_packages$aliases,
      attached_pkg_functions$text,
      attached_modules$aliases,
      attached_mod_functions$text
    )
    duplicated_combined_packages_functions <- duplicated(combined_packages_and_functions$aliases)

    combined_functions_and_three_dots <- list()
    combined_functions_and_three_dots$xml <- c(
      attached_pkg_functions$xml,
      attached_pkg_three_dots$xml,
      attached_mod_functions$xml,
      attached_mod_three_dots$xml
    )
    class(combined_functions_and_three_dots$xml) <- "xml_nodeset"
    combined_functions_and_three_dots$text <- c(
      attached_pkg_functions$text,
      attached_pkg_three_dots$nested,
      attached_mod_functions$text,
      attached_mod_three_dots$nested
    )
    duplicated_combined_functions_and_three_dots <- cross_duplicated_values(combined_functions_and_three_dots$text)

    yyy <- Map(
      function(a, b) list("xml" = a, "text" = b),
      combined_packages_and_functions$xml,
      combined_packages_and_functions$aliases
    )[duplicated_combined_packages_functions]

    xxx <- Map(
      function(a, b) list("xml" = a, "text" = b),
      combined_functions_and_three_dots$xml,
      duplicated_combined_functions_and_three_dots$values
    )[duplicated_combined_functions_and_three_dots$flags]

    duplicated_import_combined_nodes <- unique(c(yyy, xxx))

    cross_lint <- lapply(duplicated_import_combined_nodes, function(duplicate_node) {
      lint_name <- paste(duplicate_node$text, collapse = ", ")
      lintr::xml_nodes_to_lints(
        duplicate_node$xml,
        source_expression = source_expression,
        lint_message = glue::glue("Duplicated box-attached object: {lint_name}."),
        type = "warning"
      )
    })

    cross_lint
  })
}

cross_duplicated_values <- function(vecs) {
  result <- purrr::map(seq_along(vecs), function(i) {
    if (i == 1) {
      list(flag = FALSE, duplicates = character(0))
    } else {
      previous <- unlist(vecs[1:(i - 1)], use.names = FALSE)
      current <- vecs[[i]]
      duplicated_vals <- unique(current[current %in% previous])
      list(flag = length(duplicated_vals) > 0, duplicates = duplicated_vals)
    }
  })

  list(
    flags = purrr::map_lgl(result, "flag"),
    values = purrr::map(result, "duplicates")
  )
}
