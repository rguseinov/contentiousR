# Add leader data to a state panel

Joins leader data onto an existing state panel. The coding system, time
unit, and year range are detected automatically from the panel.

Each period is assigned the leader who held power at the end of it (the
leader with the latest start date when several leaders served in the
same period). In a country-quarter, country-month, or country-day panel,
leaders are placed by their exact dates in office, so a transition in
February 2011 shows up in February 2011, not for the whole year.

## Usage

``` r
add_leader_data(panel, dataset = c("archigos", "reign"))
```

## Arguments

- panel:

  A data frame produced by
  [`build_states_panel()`](https://rguseinov.github.io/contentiousR/dev/reference/build_states_panel.md).

- dataset:

  Dataset to use: `"archigos"` (default) or `"reign"`. See
  [`load_leader_data()`](https://rguseinov.github.io/contentiousR/dev/reference/load_leader_data.md)
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

# Leader by month
monthly <- build_states_panel(2011, 2011, coding_system = "cow", unit = "month") |>
  add_leader_data()
```
