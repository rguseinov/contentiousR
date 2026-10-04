# Add GDP data to a state panel

Joins GDP data onto an existing state panel. The coding system (`"cow"`
or `"gw"`) and year range are detected automatically from the panel.

## Usage

``` r
add_gdp(panel, dataset = c("gapminder", "fariss"))
```

## Arguments

- panel:

  A data frame produced by
  [`build_states_panel()`](https://rguseinov.github.io/contentiousR/reference/build_states_panel.md),
  containing a `cow` or `gw` column and a `year` column.

- dataset:

  Dataset to use: `"gapminder"` (default) or `"fariss"`. See
  [`load_gdp_data()`](https://rguseinov.github.io/contentiousR/reference/load_gdp_data.md)
  for details and added columns.

## Value

The input panel with GDP columns added via left join.

## References

Gapminder. (2024). *GDP per capita in constant PPP dollars*.
<https://www.gapminder.org/gdp-per-capita/>

Fariss, C. J., Anders, T., Markowitz, J. N., & Barnum, M. (2022). New
estimates of over 500 years of historic GDP and population data.
*Journal of Conflict Resolution*, 66(3), 553-591.
[doi:10.1177/00220027211054432](https://doi.org/10.1177/00220027211054432)

## Examples

``` r
panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
  add_gdp()

panel <- build_states_panel(1900, 2010, coding_system = "cow") |>
  add_gdp(dataset = "fariss")
```
