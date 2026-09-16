# Fetch raw campaign/episode rows from several conflict datasets at once

Fetch raw campaign/episode rows from several conflict datasets at once

## Usage

``` r
fetch_campaign_events(datasets, start_year, end_year, coding_system)
```

## Arguments

- datasets:

  Character vector of
  [`conflict_data()`](https://rguseinov.github.io/contentiousR/reference/conflict_data.md)
  dataset keys.

- start_year, end_year:

  Integer year bounds.

- coding_system:

  `"cow"` or `"gw"`.

## Value

A data frame with `dataset`, `unit` (the coding-system code), `year`,
and `region` (World Bank 7-region classification, via
[`countrycode::countrycode()`](https://rdrr.io/pkg/countrycode/man/countrycode.html)).
