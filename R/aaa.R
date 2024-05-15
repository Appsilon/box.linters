box_module_base_path <- function() {
  "//SYMBOL_PACKAGE[(text() = 'box' and following-sibling::SYMBOL_FUNCTION_CALL[text() = 'use'])]
  /parent::expr
  /parent::expr[
    ./expr/OP-SLASH
  ]
  "
}

box_package_base_path <- function() {
  "//SYMBOL_PACKAGE[(text() = 'box' and following-sibling::SYMBOL_FUNCTION_CALL[text() = 'use'])]
  /parent::expr
  /parent::expr[
    not(./expr/OP-SLASH)
  ]
  "
}
