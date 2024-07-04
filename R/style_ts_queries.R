ts_query_mod <- "
(call
  function: (namespace_operator
    lhs: (identifier) @box_pkg (#eq? @box_pkg \"box\")
    rhs: (identifier) @box_use (#eq? @box_use \"use\"))
  arguments: (arguments
    argument: (argument
      name: (identifier)? @mod_alias
      value: (binary_operator
        lhs: (_) @path
        operator: \"/\"
        rhs: [
          (identifier) @mod_name
          (subset
            function: (identifier) @mod_name
          )
        ]
      ) @full_path
    ) @mod_call
    .
    (comma)?
    .
    (comment)? @comment
  )
)"

ts_query_pkg <- "
(call
  function: (namespace_operator
    lhs: (identifier) @box_pkg (#eq? @box_pkg \"box\")
    rhs: (identifier) @box_use (#eq? @box_use \"use\")
  )
  arguments: (arguments
    argument: ((argument
      name: (identifier)? @pkg_alias
      value: [
        (identifier) @pkg_name
        (subset
          function: (identifier) @pkg_name
        )
      ]
    ) @pkg_call
    .
    (comma)?
    .
    (comment)? @comment
    )
  )
)"

