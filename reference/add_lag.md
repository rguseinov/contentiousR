# Add lagged variables to a state panel

Adds a lagged version of each requested column, computed within each
state (`group_by(cow)` or `group_by(gw)`, matching the panel's coding
system) after sorting by year — required for lags to be meaningful in
panel data. Unlike a plain
[`dplyr::lag()`](https://dplyr.tidyverse.org/reference/lead-lag.html),
the lag is `NA` wherever the preceding row is not exactly `n` years
earlier, so gaps in the year sequence (e.g. after filtering with
[`tidyr::drop_na()`](https://tidyr.tidyverse.org/reference/drop_na.html))
do not silently produce a lag from the wrong year.

## Usage

``` r
add_lag(panel, vars, n = 1)
```

## Arguments

- panel:

  A data frame produced by
  [`build_states_panel()`](https://rguseinov.github.io/contentiousR/reference/build_states_panel.md),
  containing a `cow` or `gw` column and a `year` column.

- vars:

  Character vector of column names in `panel` to lag.

- n:

  Integer. Number of years to lag by. Default `1`.

## Value

The input panel with one additional column per entry in `vars`, named
`<var>_l`, holding the value of `<var>` from `n` years earlier for the
same state (or `NA` if that year is not present in `panel`).

## Examples

``` r
panel <- build_states_panel(1990, 2000, coding_system = "cow") |>
  add_gdp() |>
  add_lag(vars = c("gdp_pcap", "gdp_growth"), n = 1)
```
