# Add population data to a state panel

Joins country-year population data onto an existing state panel. The
coding system and year range are detected automatically from the panel.

## Usage

``` r
add_population(panel, dataset = c("wpp", "nmc", "fariss"))
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

## References

United Nations, Department of Economic and Social Affairs, Population
Division. (2024). *World Population Prospects 2024*.
<https://population.un.org/wpp/>

Fariss, C. J., Anders, T., Markowitz, J. N., & Barnum, M. (2022). New
estimates of over 500 years of historic GDP and population data.
*Journal of Conflict Resolution*, 66(3), 553-591.
[doi:10.1177/00220027211054432](https://doi.org/10.1177/00220027211054432)

Singer, J. D., Bremer, S., & Stuckey, J. (1972). Capability
distribution, uncertainty, and major power war, 1820-1965. In B. Russett
(Ed.), *Peace, War, and Numbers* (pp. 19-48). Sage.

Singer, J. D. (1988). Reconstructing the Correlates of War dataset on
material capabilities of states, 1816-1985. *International
Interactions*, 14, 115-132.

## Examples

``` r
panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
  add_population(dataset = "wpp")

panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
  add_population(dataset = "nmc")
```
