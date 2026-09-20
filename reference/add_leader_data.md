# Add leader data to a state panel

Joins country-year leader data onto an existing state panel. The coding
system and year range are detected automatically from the panel.

Each country-year is assigned the leader who held power at the end of
that year (i.e., the leader with the latest start date when multiple
leaders served in the same year).

## Usage

``` r
add_leader_data(panel, dataset = c("archigos", "reign"))
```

## Arguments

- panel:

  A data frame produced by
  [`build_states_panel()`](https://rguseinov.github.io/contentiousR/reference/build_states_panel.md).

- dataset:

  Dataset to use: `"archigos"` (default) or `"reign"`. See
  [`load_leader_data()`](https://rguseinov.github.io/contentiousR/reference/load_leader_data.md)
  for details.

## Value

The input panel with leader columns added via left join.

## References

Goemans, H. E., Gleditsch, K. S., & Chiozza, G. (2009). Introducing
Archigos: A dataset of political leaders. *Journal of Peace Research*,
46(2), 269-283.

Bell, C., Besaw, C., & Frank, M. (2021). *The Rulers, Elections, and
Irregular Governance (REIGN) Dataset*.

## Examples

``` r
panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
  add_leader_data(dataset = "archigos")

panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
  add_leader_data(dataset = "reign")
```
