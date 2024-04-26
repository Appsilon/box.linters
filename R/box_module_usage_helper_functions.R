box_module_base_path <- function() {
  "//SYMBOL_PACKAGE[(text() = 'box' and following-sibling::SYMBOL_FUNCTION_CALL[text() = 'use'])]
  /parent::expr
  /parent::expr[
    ./expr/OP-SLASH
  ]
  "
}

get_module_exports <- function(mod_list) {

}

get_attached_modules <- function(xml) {

}

get_attached_mod_three_dots <- function(xml) {

}

get_attached_mod_functions <- function(xml) {

}
