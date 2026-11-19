# Registry of bundled datasets

One row per dataset. `coverage_rule` says how
[`add_conflict()`](https://rguseinov.github.io/contentiousR/dev/reference/add_conflict.md)
decides which country-years a conflict dataset covers when
`fill_zero = TRUE`: `"global"` (every state in the panel), `"countries"`
(countries with at least one record), `"country_span"` (each country
from its first to its last year with a record), or `"country_years"`
(the country-years listed in the source).

## Usage

``` r
dataset_registry()
```

## Value

A data frame.
