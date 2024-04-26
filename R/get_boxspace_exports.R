get_box_module_exports <- function(declaration, alias = "", caller = globalenv()) {
  if (is.call(declaration)) {
    declaration
  } else if (is.character(declaration)) {
    declaration <- rlang::parse_expr(declaration)
  }
  parse_spec <- get0("parse_spec", envir = loadNamespace("box"))
  find_mod <- get0("find_mod.box$mod_spec", envir = loadNamespace("box"))
  load_mod <- get0("load_mod.box$mod_info", envir = loadNamespace("box"))
  namespace_info <- get0("namespace_info", envir = loadNamespace("box"))

  if (any(sapply(list(parse_spec, find_mod, load_mod, namespace_info), is.null))) {
    stop("box.linters couldn't load box functions")
  }

  spec <- parse_spec(declaration, alias)
  info <- find_mod(spec, caller)
  mod_ns <- load_mod(info)
  namespace_info(mod_ns, "exports")
}
