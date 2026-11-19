# Build a state panel

Build a state panel

## Usage

``` r
build_states_panel(
  start_year = 1946,
  end_year = 2013,
  coding_system = c("cow", "gw"),
  exclude_microstates = TRUE,
  exclude_non_un = TRUE,
  exclude_islands = FALSE,
  unit = c("year", "quarter", "month", "day")
)
```

## Arguments

- start_year:

  First year. Must be `1816` or later.

- end_year:

  Last year. Must be `2025` or earlier.

- coding_system:

  Country coding system. Either `"cow"` or `"gw"`.

- exclude_microstates:

  Logical. Exclude entities identified as microstates by
  [`states::state_panel()`](https://www.andybeger.com/states/reference/state_panel.html).

- exclude_non_un:

  Logical. Exclude the package's fixed set of non-UN entities (Kosovo,
  Taiwan, Hong Kong, the European Union, and South Vietnam for COW;
  Kosovo, Abkhazia, South Ossetia, Taiwan, and South Vietnam for GW).

- exclude_islands:

  Logical. Exclude six small Caribbean island states: Dominica, Grenada,
  Saint Lucia, Saint Vincent and the Grenadines, Antigua and Barbuda,
  and Saint Kitts and Nevis.

- unit:

  Time unit of the panel: `"year"` (default), `"quarter"`, `"month"`, or
  `"day"`. A state is included in a period if it was a member of the
  state system for any part of that period.

## Value

A data frame with one row per state and period. A country-year panel has
the country code, `year`, and `country`; a country-quarter panel adds
`quarter` (1-4); a country-month panel adds `month` (1-12); a
country-day panel adds `month`, `day`, and `date`.

## Details

Annual data
([`add_gdp()`](https://rguseinov.github.io/contentiousR/dev/reference/add_gdp.md),
[`add_population()`](https://rguseinov.github.io/contentiousR/dev/reference/add_population.md),
[`add_military_expenditure()`](https://rguseinov.github.io/contentiousR/dev/reference/add_military_expenditure.md),
[`add_vdem()`](https://rguseinov.github.io/contentiousR/dev/reference/add_vdem.md))
are joined to a country-quarter, country-month, or country-day panel by
country and year, so every period of a year takes that year's value.
[`add_leader_data()`](https://rguseinov.github.io/contentiousR/dev/reference/add_leader_data.md)
uses the leaders' exact dates in office, and
[`add_conflict()`](https://rguseinov.github.io/contentiousR/dev/reference/add_conflict.md)
aggregates event data to the panel's own unit, for the datasets that
record exact event dates.
[`add_lag()`](https://rguseinov.github.io/contentiousR/dev/reference/add_lag.md)
and
[`add_spell_duration()`](https://rguseinov.github.io/contentiousR/dev/reference/add_spell_duration.md)
count periods in the panel's unit. Use
[`aggregate_panel()`](https://rguseinov.github.io/contentiousR/dev/reference/aggregate_panel.md)
to collapse a finer panel to a coarser unit.

A country-day panel is large (about 70,000 rows per year of data), so
restrict it to the years you need.

## Examples

``` r
yearly  <- build_states_panel(1990, 2000, coding_system = "cow")
quarterly <- build_states_panel(2010, 2012, coding_system = "cow", unit = "quarter")
monthly <- build_states_panel(2010, 2012, coding_system = "gw", unit = "month")
daily   <- build_states_panel(2011, 2011, coding_system = "cow", unit = "day")
```
