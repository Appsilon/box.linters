# comment A
box::use(
  stringr[...], # nolint
  purrr[
    map_chr, # nolint
    map,
  ],
  dplyr, alias = shiny,
  tidyr[zun_alias = long, wide, ],
  path/to/module_f
)
# comment B
box::use(
  path/to/module_a,
  alias = path/to/module_d
)
# comment C
box::use(
  path/to/module_b[fun_alias = func_a, func_b, ],
  path/to/module_c[...] # nolint
)

#' @export
some_function <- function() {
  1 + 1
}

another_function <- function() {
  2 + 2
}
