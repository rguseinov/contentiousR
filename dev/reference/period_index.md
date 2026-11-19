# Sequential period index of a panel row

Consecutive periods differ by exactly one: years for a country-year
panel, quarters (`4 * year + quarter`) for a country-quarter panel,
months (`12 * year + month`) for a country-month panel, and days for a
country-day panel.

## Usage

``` r
period_index(panel, unit = detect_panel_unit(panel))
```

## Arguments

- panel:

  A data frame produced by
  [`build_states_panel()`](https://rguseinov.github.io/contentiousR/dev/reference/build_states_panel.md).

- unit:

  `"year"`, `"quarter"`, `"month"`, or `"day"`.

## Value

A numeric vector, one value per row.
