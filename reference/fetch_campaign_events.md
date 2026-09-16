# Fetch one row per campaign/episode onset from several conflict datasets

Fetch one row per campaign/episode onset from several conflict datasets

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

## Details

`"navco1.3"`, `"beissinger"`, `"csra"`, and `"mec"` are already one row
per campaign/episode. `"navco2.1"` is not:
[`conflict_data()`](https://rguseinov.github.io/contentiousR/reference/conflict_data.md)
returns one row per campaign-*year*, so a single long-running campaign
contributes many rows. Comparing that directly against onset-coded
datasets would overstate NAVCO 2.1's event counts by roughly the average
campaign duration. To keep the comparison on the same onset-level
footing as the source article, `"navco2.1"` is collapsed here to one row
per campaign (`nvc2.1_camp_name`), keeping its earliest year. Because
that earliest year can fall before `start_year`, the collapse is done
over the dataset's full native coverage (1945-2013) before the requested
year range is applied, so campaigns already underway at `start_year` are
not mistaken for new onsets.
