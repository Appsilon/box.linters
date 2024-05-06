#' Get a list of functions and data objects exported by a local `box` module
#'
#' An implementation for `box` modules to provide similar functionality as `getNamespaceExports()`
#' for libraries/packages.
#'
#' @param declaration The mod or package call expression. See `box:::parse_spec()` source
#' code for more details.
#' @param alias Mod or package-level alias as a character string. See `box:::parse_spec()` source
#' code for more details. Default is fine for `box.linters` use.
#' @param caller The environment from which \code{box::use} was invoked.
#' Default is fine for `box.linters` use.
#' @return A list of exported functions and data objects.
#' @seealso [getNamespaceExports()]
#' @keywords internal
get_box_module_exports <- function(declaration, alias = "", caller = globalenv()) {
  if (is.call(declaration)) {
    declaration
  } else if (is.character(declaration)) {
    declaration <- rlang::parse_expr(declaration)
  }
  parse_spec <- get0("parse_spec", envir = base::loadNamespace("box"))
  find_mod <- get0("find_mod.box$mod_spec", envir = base::loadNamespace("box"))
  load_mod <- get0("load_mod.box$mod_info", envir = base::loadNamespace("box"))
  namespace_info <- get0("namespace_info", envir = base::loadNamespace("box"))

  if (any(sapply(list(parse_spec, find_mod, load_mod, namespace_info), is.null))) {
    stop("box.linters couldn't load box functions")
  }

  spec <- parse_spec(declaration, alias)
  info <- find_mod(spec, caller)
  mod_ns <- load_mod(info)
  namespace_info(mod_ns, "exports")
}
