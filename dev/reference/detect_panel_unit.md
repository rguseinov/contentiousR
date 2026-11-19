# Detect the time unit of a panel

A panel from `build_states_panel(unit = "day")` has `year`, `month`,
`day`, and `date` columns; one from `unit = "month"` has `year` and
`month`; one from `unit = "quarter"` has `year` and `quarter`; a
country-year panel has `year` only.

## Usage

``` r
detect_panel_unit(panel)
```

## Arguments

- panel:

  A data frame produced by
  [`build_states_panel()`](https://rguseinov.github.io/contentiousR/dev/reference/build_states_panel.md).

## Value

`"year"`, `"quarter"`, `"month"`, or `"day"`.
