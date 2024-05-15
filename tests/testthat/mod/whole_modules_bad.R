box::use(
  path/to/module_a,
  mod_alias = path/to/module_b,
)

module_a$a_fun_a()
module_a$non_existing_fun()

mod_alias$b_fun_a()
mod_aliase$non_existing_obj
