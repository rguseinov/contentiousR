# Lag a vector within a panel, respecting gaps in the year sequence

Lag a vector within a panel, respecting gaps in the year sequence

## Usage

``` r
lag_with_year_gap_check(x, year, n)
```

## Arguments

- x:

  Vector to lag.

- year:

  Integer year vector, same length as `x`, for the same cross-sectional
  unit and already sorted ascending.

- n:

  Integer. Number of years to lag by.

## Value

`x` shifted back by `n` positions, with `NA` wherever the corresponding
row is not exactly `n` years earlier (e.g. because that year is missing
from the data).
