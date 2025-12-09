# Get all packages imported whole

Get all packages imported whole

## Usage

``` r
get_attached_packages(xml)
```

## Arguments

- xml:

  An XML node list

## Value

`xml` list of `xml_nodes`, `nested` list of `package: functions`,
`aliases` a named list of `package` = `alias`, `text` list of all
`package$function` names.
