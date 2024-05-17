# nolint start: line_length_linter
#' Use lintr with box.linters in your project
#'
#' Create a minimal lintr config file with `box` modules support as a starting point
#' for customization
#'
#' @param path Path to project root whwre a `.lintr` file should be created.
#' If the `.lintr` file already exists, an error will be thrown.
#' @param type The kind of configurationto create
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
  lintr_option <- get0("lintr_option", envir = base::loadNamespace("lintr"))
  config_file <- normalizePath(
    file.path(
      path,
      lintr_option("linter_file")
    ),
    mustWork = FALSE
  )
  if (file.exists(config_file)) {
    stop("Found an existing configuration file at '", config_file, "'.", call. = FALSE)
  }
  type <- match.arg(type)
  the_config <- switch(
    type,
    basic_box = list(
      linters = "linters_with_defaults(
                  defaults = box.linters::box_default_linters
                )",
      encoding = "\"UTF-8\""
    ),
    rhino = list(
      linters = "linters_with_defaults(
                  defaults = box.linters::rhino_default_linters,
                  line_length_linter = lintr::line_length_linter(100)
                )",
      encoding = "\"UTF-8\""
    )
  )
  write.dcf(the_config, config_file, width = Inf)
  invisible(config_file)
}
