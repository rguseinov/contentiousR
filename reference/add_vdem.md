# Add V-Dem indicators to a state panel

Joins V-Dem country-year data onto an existing state panel. The coding
system and year range are detected automatically from the panel.

Requires the `vdemdata` package:
`remotes::install_github("vdeminstitute/vdemdata")`

## Usage

``` r
add_vdem(panel, vars = NULL)
```

## Arguments

- panel:

  A data frame produced by
  [`build_states_panel()`](https://rguseinov.github.io/peacebuilder/reference/build_states_panel.md).

- vars:

  Character vector of V-Dem variable names. If `NULL`, a default set of
  democracy, civil liberties, civil society, and rule-of-law indicators
  is used. See
  [`load_vdem_data()`](https://rguseinov.github.io/peacebuilder/reference/load_vdem_data.md)
  for the full default list.

## Value

The input panel with V-Dem columns added via left join.

## Examples

``` r
if (requireNamespace("vdemdata", quietly = TRUE)) {
panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
  add_vdem(vars = c("v2x_polyarchy", "v2x_libdem", "v2x_rule"))
}
```
