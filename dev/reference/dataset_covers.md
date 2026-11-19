# Country-years a conflict dataset covers

Used by `add_conflict(fill_zero = TRUE)`. See
[`dataset_registry()`](https://rguseinov.github.io/contentiousR/dev/reference/dataset_registry.md)
for the rules.

## Usage

``` r
dataset_covers(dataset, coding_system, panel_keys)
```

## Arguments

- dataset:

  Dataset name.

- coding_system:

  `"cow"` or `"gw"`.

- panel_keys:

  A data frame with the country code and `year` of the panel rows.

## Value

A logical vector, one value per row of `panel_keys`: `TRUE` if the
dataset covers that country-year.
