# Add GDP per capita data to a state panel

Joins Gapminder GDP data onto an existing state panel. The coding system
(`"cow"` or `"gw"`) and year range are detected automatically from the
panel. Added columns: `gdp_pcap`, `log_gdp_pcap`, `gdp_growth`.

## Usage

``` r
add_gdp(panel)
```

## Arguments

- panel:

  A data frame produced by
  [`build_states_panel()`](https://rguseinov.github.io/contentiousR/reference/build_states_panel.md),
  containing a `cow` or `gw` column and a `year` column.

## Value

The input panel with GDP columns added via left join.

## Examples

``` r
panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
  add_gdp()
```
