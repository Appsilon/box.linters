# Rhino default linters

See the [Explanation: Rhino style
guide](https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html)
to learn about the details.

## Usage

``` r
rhino_default_linters
```

## Format

An object of class `list` of length 40.

## Examples

``` r
linters <- lintr::linters_with_defaults(defaults = box.linters::rhino_default_linters)

names(linters)
#>  [1] "assignment_linter"                  "box_alphabetical_calls_linter"     
#>  [3] "box_func_import_count_linter"       "box_mod_fun_exists_linter"         
#>  [5] "box_pkg_fun_exists_linter"          "box_separate_calls_linter"         
#>  [7] "box_trailing_commas_linter"         "box_universal_import_linter"       
#>  [9] "box_unused_att_mod_obj_linter"      "box_unused_att_pkg_linter"         
#> [11] "box_unused_attached_mod_linter"     "box_unused_attached_pkg_fun_linter"
#> [13] "box_usage_linter"                   "brace_linter"                      
#> [15] "commas_linter"                      "commented_code_linter"             
#> [17] "equals_na_linter"                   "function_left_parentheses_linter"  
#> [19] "indentation_linter"                 "infix_spaces_linter"               
#> [21] "line_length_linter"                 "namespaced_function_calls"         
#> [23] "object_length_linter"               "object_name_linter"                
#> [25] "paren_body_linter"                  "pipe_consistency_linter"           
#> [27] "pipe_continuation_linter"           "quotes_linter"                     
#> [29] "r6_usage_linter"                    "return_linter"                     
#> [31] "semicolon_linter"                   "seq_linter"                        
#> [33] "spaces_inside_linter"               "spaces_left_parentheses_linter"    
#> [35] "T_and_F_symbol_linter"              "trailing_blank_lines_linter"       
#> [37] "trailing_whitespace_linter"         "unused_declared_object_linter"     
#> [39] "vector_logic_linter"                "whitespace_linter"                 
```
