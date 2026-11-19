# Replace a data frame's COW code with the GW code

Replace a data frame's COW code with the GW code

## Usage

``` r
cow_to_gw_column(data)
```

## Arguments

- data:

  A data frame with `cow` and `year` (and optionally `month`).

## Value

`data` with `gw` in place of `cow`, rows without a GW equivalent
dropped, and `gw` as the first column.
