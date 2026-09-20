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

## References

Singer, J. D., Bremer, S., & Stuckey, J. (1972). Capability
distribution, uncertainty, and major power war, 1820-1965. In B. Russett
(Ed.), *Peace, War, and Numbers* (pp. 19-48). Sage.

Singer, J. D. (1988). Reconstructing the Correlates of War dataset on
material capabilities of states, 1816-1985. *International
Interactions*, 14, 115-132.

Stockholm International Peace Research Institute. (2025). *SIPRI
Military Expenditure Database*.
[doi:10.55163/CQGC9685](https://doi.org/10.55163/CQGC9685)

Barnum, M., Fariss, C. J., Markowitz, J. N., & Morales, G. (2025).
Measuring arms: Introducing the Global Military Spending Dataset.
*Journal of Conflict Resolution*, 69(2-3), 540-567.
[doi:10.1177/00220027241232964](https://doi.org/10.1177/00220027241232964)

## Examples

``` r
panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
  add_military_expenditure()

panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
  add_military_expenditure(dataset = "nmc")
```
