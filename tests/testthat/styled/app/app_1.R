# comment A
# comment B
# comment C
box::use(
  dplyr,
  purrr[
    map,
    map_chr # nolint
  ],
  alias = shiny,
  stringr[...], # nolint
  tidyr[zun_alias = long, wide],
)

box::use(
  path/to/module_a,
  path/to/module_b[fun_alias = func_a, func_b],
  path/to/module_c[...], # nolint
  alias = path/to/module_d,
  path/to/module_f,
)

#' @export
some_function <- function() {
  1 + 1
}

another_function <- function() {
  2 + 2
}
