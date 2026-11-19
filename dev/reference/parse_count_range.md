# Parse NAVCO 3.0 count strings into lower and upper bounds

NAVCO 3.0 records fatalities, injuries, and participants either as a
number ("11") or as a range ("500 - 3000", "100-300"); "." marks a
missing value.

## Usage

``` r
parse_count_range(x)
```

## Arguments

- x:

  Character vector.

## Value

A list with numeric vectors `low` and `high`.
