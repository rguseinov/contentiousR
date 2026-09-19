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
footing as the source article, `"navco2.1"` is filtered here to
`nvc2.1_ONSET == 1`,
[`conflict_data()`](https://rguseinov.github.io/contentiousR/reference/conflict_data.md)'s
own per-campaign onset flag (keyed on the numeric campaign `id`, not the
free-text campaign name, which is not unique – e.g. three distinct
"Myanmar Regime Change Campaign" entries share that name). That flag is
computed over the dataset's full native coverage before
`start_year`/`end_year` filtering, so campaigns already under way at
`start_year` are not mistaken for new onsets.

[`countrycode::countrycode()`](https://rdrr.io/pkg/countrycode/man/countrycode.html)'s
`"region"` destination is not a clean 7-category classification: a
handful of pre-1990 historical entities (Yemen Arab Republic, Yemen
People's Republic, the United Arab Republic) still carry the World
Bank's older "Middle East & North Africa" label, while every other
country in that region carries the newer "Middle East, North Africa,
Afghanistan & Pakistan" label – these historical COW/GW codes do appear
in campaign data covering the 1950s-80s, so left as-is they'd split one
region into two bars. The older label is recoded to the newer one here
so the region breakdown stays at exactly 7 categories.
