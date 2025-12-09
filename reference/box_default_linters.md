# Box-compatible default linters

A replacement for
[`lintr::object_usage_linter()`](https://lintr.r-lib.org/reference/object_usage_linter.html)
that works with `box` modules.

## Usage

``` r
box_default_linters
```

## Format

An object of class `list` of length 35.

## Examples

``` r
linters <- lintr::linters_with_defaults(defaults = box.linters::box_default_linters)

names(linters)
#>  [1] "assignment_linter"                  "box_mod_fun_exists_linter"         
#>  [3] "box_pkg_fun_exists_linter"          "box_unused_att_mod_obj_linter"     
#>  [5] "box_unused_att_pkg_linter"          "box_unused_attached_mod_linter"    
#>  [7] "box_unused_attached_pkg_fun_linter" "box_usage_linter"                  
#>  [9] "brace_linter"                       "commas_linter"                     
#> [11] "commented_code_linter"              "equals_na_linter"                  
#> [13] "function_left_parentheses_linter"   "indentation_linter"                
#> [15] "infix_spaces_linter"                "line_length_linter"                
#> [17] "namespaced_function_calls"          "object_length_linter"              
#> [19] "object_name_linter"                 "paren_body_linter"                 
#> [21] "pipe_consistency_linter"            "pipe_continuation_linter"          
#> [23] "quotes_linter"                      "r6_usage_linter"                   
#> [25] "return_linter"                      "semicolon_linter"                  
#> [27] "seq_linter"                         "spaces_inside_linter"              
#> [29] "spaces_left_parentheses_linter"     "T_and_F_symbol_linter"             
#> [31] "trailing_blank_lines_linter"        "trailing_whitespace_linter"        
#> [33] "unused_declared_object_linter"      "vector_logic_linter"               
#> [35] "whitespace_linter"                 
```
