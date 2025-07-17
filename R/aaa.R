#' Find `box::use` calls for libraries/packages and local modules
#'
#' @details
#' Base XPath to find `box::use` declarations that match the following patterns:
#' \code{
#' box::use(
#'   path/to/module,
#' )
#' }
#'
#' and
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
box_base_path <- function() {
  "//SYMBOL_PACKAGE[(text() = 'box' and following-sibling::SYMBOL_FUNCTION_CALL[text() = 'use'])]
  /parent::expr
  /parent::expr
  "
}
