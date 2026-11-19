# Drop records whose date is less precise than the requested unit

Drop records whose date is less precise than the requested unit

## Usage

``` r
drop_imprecise_dates(data, keys, dataset, quiet = FALSE)
```

## Arguments

- data:

  A data frame with `year` and, for sub-annual units, `month` and `day`
  columns (`NA` where the source does not report them). For a quarterly
  unit, `quarter` is derived from `month`.

- keys:

  Time key columns, from
  [`time_keys()`](https://rguseinov.github.io/contentiousR/dev/reference/time_keys.md).

- dataset:

  Dataset name, used in the message.

- quiet:

  Logical. Suppress the message.

## Value

`data` without rows that have a missing time key.
