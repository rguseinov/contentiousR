# Build a COW-coded state panel

Build a COW-coded state panel

## Usage

``` r
build_states_cow_panel(
  start_year = 1946,
  end_year = 2013,
  exclude_microstates = TRUE,
  exclude_non_un = TRUE,
  exclude_islands = FALSE,
  unit = "year"
)
```

## Arguments

- start_year:

  First year. Must be `1816` or later.

- end_year:

  Last year. Must be `2025` or earlier.

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

A data frame with COW-coded state-year observations.
