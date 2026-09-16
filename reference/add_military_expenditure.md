# Add military expenditure data to a state panel

Joins country-year military expenditure data onto an existing state
panel. The coding system and year range are detected automatically from
the panel.

## Usage

``` r
add_military_expenditure(panel, dataset = c("sipri", "nmc", "barnum"))
```

## Arguments

- panel:

  A data frame produced by
  [`build_states_panel()`](https://rguseinov.github.io/contentiousR/reference/build_states_panel.md).

- dataset:

  Dataset to use: `"sipri"` (default), `"nmc"`, or `"barnum"`. See
  [`load_military_expenditure_data()`](https://rguseinov.github.io/contentiousR/reference/load_military_expenditure_data.md)
  for details and added columns.

## Value

The input panel with military expenditure columns added via left join.

## Examples

``` r
panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
  add_military_expenditure()

panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
  add_military_expenditure(dataset = "nmc")
```
