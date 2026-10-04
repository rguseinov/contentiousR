# Parse one wide SIPRI military expenditure sheet into long format

Parse one wide SIPRI military expenditure sheet into long format

## Usage

``` r
read_sipri_sheet(path, sheet)
```

## Arguments

- path:

  Path to the SIPRI xlsx file.

- sheet:

  Sheet name.

## Value

A data frame with `country`, `year`, `value`.
