# Columns that `fill_zero` sets to 0

Event indicators and counts: `*_onset`, `*_incidence`, `*_episode`,
counts (`*_n_*`, `n_campaigns`), UCDP conflict-type indicators, and
summed totals (`*_total`; NAVCO 3.0 fatalities and injuries). Maxima,
means, and descriptive columns stay `NA` in periods without records.

## Usage

``` r
zero_fill_columns(cols)
```

## Arguments

- cols:

  Column names.

## Value

The subset of `cols` to fill.
