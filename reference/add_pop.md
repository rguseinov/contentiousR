# Add population data to a state panel

Joins country-year population data onto an existing state panel. The
coding system and year range are detected automatically from the panel.

## Usage

``` r
add_pop(panel, dataset = c("wpp", "nmc", "fariss"))
```

## Arguments

- panel:

  A data frame produced by
  [`build_states_panel()`](https://rguseinov.github.io/contentiousR/reference/build_states_panel.md).

- dataset:

  Dataset to use: `"wpp"` (default), `"nmc"`, or `"fariss"`. See
  [`load_population_data()`](https://rguseinov.github.io/contentiousR/reference/load_population_data.md)
  for details and added columns.

## Value

The input panel with population columns added via left join.

## Examples

``` r
panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
  add_pop(dataset = "wpp")

panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
  add_pop(dataset = "nmc")
```
