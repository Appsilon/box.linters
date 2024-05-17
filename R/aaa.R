#' Find `box::use` calls for local modules
#'
#' @details
#' Base XPath to find `box::use` declarations that match the following pattern:
#' \code{
#' box::use(
#'   path/to/module,
#' )
#' }
#'
#' @seealso [box_separate_calls_linter()]
#'
#' @return An XPath
#' @keywords internal
box_module_base_path <- function() {
  "//SYMBOL_PACKAGE[(text() = 'box' and following-sibling::SYMBOL_FUNCTION_CALL[text() = 'use'])]
  /parent::expr
  /parent::expr[
    ./expr/OP-SLASH
  ]
  "
}

#' Find `box::use` calls for R libraries/packages
#'
#' @details
#' Base XPath to find `box::use` declarations that match the following pattern:
#' \code{
#' box::use(
#'   package,
#' )
#' }
#'
#' @seealso [box_separate_calls_linter()]
#'
#' @return An XPath
#' @keywords internal
box_package_base_path <- function() {
  "//SYMBOL_PACKAGE[(text() = 'box' and following-sibling::SYMBOL_FUNCTION_CALL[text() = 'use'])]
  /parent::expr
  /parent::expr[
    not(./expr/OP-SLASH)
  ]
  "
}
