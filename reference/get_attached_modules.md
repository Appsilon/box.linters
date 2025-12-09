# Get all modules imported whole

Get all modules imported whole

## Usage

``` r
get_attached_modules(xml)
```

## Arguments

- xml:

  An XML node list

## Value

`xml` list of `xml_nodes`, `nested` list of `module: functions`,
`aliases` a named list of `module` = `alias`, `text` list of all
`module$function` names.
