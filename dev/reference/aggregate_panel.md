# Aggregate a panel to a coarser time unit

Collapses a country-day, country-month, or country-quarter panel to a
coarser unit (`"month"`, `"quarter"`, or `"year"`), for example to check
monthly results against annual ones or to combine sources at different
units.

Columns are combined by these default rules:

- Conflict counts and totals (columns from
  [`add_conflict()`](https://rguseinov.github.io/contentiousR/dev/reference/add_conflict.md)
  such as `*_n_events`, `*_total`, `n_campaigns`, and NAVCO 3.0
  fatalities and injuries): summed.

- Other numeric conflict columns, including onset and incidence
  indicators and maxima: maximum. Counts of distinct units
  (`*_n_active`, `arc_n_orgs`) also take the maximum, a lower bound: the
  same episode or organization can appear in several periods, so their
  sum would double-count.

- Conflict means and shares (`*_mean_*`, `*_share_*`): mean of the
  period values. This is not the mean over the underlying events.

- Character conflict columns: the distinct values, joined by "; ".

- All other columns (country names, annual data such as GDP, leaders):
  the value in the last period, i.e. at the end of the new period.

Sums and maxima of all-`NA` values are `NA`. Lags (`*_l`) and spell
counters (`*_spell`) are dropped: recompute them on the aggregated panel
with
[`add_lag()`](https://rguseinov.github.io/contentiousR/dev/reference/add_lag.md)
and
[`add_spell_duration()`](https://rguseinov.github.io/contentiousR/dev/reference/add_spell_duration.md).

## Usage

``` r
aggregate_panel(
  panel,
  to = c("year", "quarter", "month"),
  sum = NULL,
  max = NULL,
  mean = NULL,
  last = NULL
)
```

## Arguments

- panel:

  A panel from
  [`build_states_panel()`](https://rguseinov.github.io/contentiousR/dev/reference/build_states_panel.md)
  with `unit = "day"`, `"month"`, or `"quarter"`, with any added data.

- to:

  Target unit: `"year"` (default), `"quarter"`, or `"month"`. Must be
  coarser than the panel's unit.

- sum, max, mean, last:

  Optional character vectors of column names that override the default
  rule for those columns.

## Value

A panel at the unit `to`, with one row per country and period and the
same columns as `panel` except the finer time keys, `date`, lags, and
spell counters.

## Examples

``` r
monthly <- build_states_panel(2010, 2012, coding_system = "cow", unit = "month") |>
  add_gdp() |>
  add_conflict("mmad", fill_zero = TRUE)

yearly <- aggregate_panel(monthly, to = "year")
#> Aggregated country-month to country-year. Summed: mmad_n_events, mmad_n_anti_gov, mmad_numreports_total. Mean of period values: mmad_mean_participants. Maximum: 4 other conflict column(s). Other columns take the value of the last month.
yearly[yearly$cow == 651, c("year", "gdp_pcap", "mmad_onset", "mmad_n_events")]
#>     year gdp_pcap mmad_onset mmad_n_events
#> 378 2010 13128.99          1            37
#> 379 2011 13082.43          1           233
#> 380 2012 13076.81          1            69
```
