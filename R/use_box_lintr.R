# nolint start: line_length_linter
#' Use lintr with box.linters in your project
#'
#' Create a minimal lintr config file with `box` modules support as a starting point
#' for customization
#'
#' @param path Path to project root where a `.lintr` file should be created.
#' If the `.lintr` file already exists, an error will be thrown.
#' @param type The kind of configuration to create
#'
#' * `basic_box` creates a minimal lintr config based on the `tidyverse` configuration of `lintr`.
#'   This starts with `lintr::linters_with_defaults()` and is customized for `box` module
#'   compatibility
#' * `rhino` creates a lintr config based on the [Rhino style guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
#'
#' @return Path to the generated configuration, invisibly.
#'
#' @examples
#' \dontrun{
#'   # use default box-compatible set of linters
#'   box.linters::use_box_lintr()
#'
#'   # use `rhino` set of linters
#'   box.linters::use_box_lintr(type = "rhino")
#' }
#' @export
# nolint end
use_box_lintr <- function(path = ".", type = c("basic_box", "rhino")) {
  lintr_option <- getOption("lintr.linter_file", default = ".lintr")
  config_file <- normalizePath(
    file.path(
      path,
      lintr_option
    ),
    mustWork = FALSE
  )
  overwrite <- FALSE
  if (file.exists(config_file)) {
    cli::cli_alert_warning(
      glue::glue("Found an existing configuration file at '{config_file}'.")
    )
    response <- readline("Would you like to overwrite the existing '.lintr` file? (yes/No) ")
    response <- substr(response, 1, 1)
    if (response == "Y" || response == "y") {
      overwrite <- TRUE
    } else {
      cli::cli_abort(".lintr file creation cancelled!")
    }
  }
  type <- match.arg(type)
  if (type == "rhino") {
    if (!requireNamespace("rhino", quietly = TRUE)) {
      cli::cli_abort(
        "The `rhino` package cannot be found. Please install with: install.packages(\"rhino\")."
      )
    }
  }
  lintr_file <- switch(
    type,
    basic_box = fs::path_package("box.linters", "", "dot.lintr"),
    rhino = fs::path_package("rhino", "templates", "app_structure", "dot.lintr")
  )
  tryCatch({
    fs::file_copy(lintr_file, config_file, overwrite = overwrite)
    cli::cli_alert_success("box.linters .lintr file successfully written!")
  }, error = function(e) {
    stop(e)
  })
  invisible(config_file)
}
