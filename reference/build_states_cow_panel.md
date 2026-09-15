# Build a COW-coded state panel

`build_states_cow_panel()` is retained for compatibility with
contentiousR 0.0.1. New code should use
`build_states_panel(coding_system = "cow")`.

## Usage

``` r
build_states_cow_panel(
  start_year = 1946,
  end_year = 2013,
  exclude_microstates = TRUE,
  exclude_non_un = TRUE,
  exclude_islands = FALSE
)
```

## Arguments

- start_year:

  First year.

- end_year:

  Last year.

- exclude_microstates:

  Logical. Exclude entities identified as microstates by
  [`states::state_panel()`](https://www.andybeger.com/states/reference/state_panel.html).

- exclude_non_un:

  Logical. Exclude the package's fixed set of non-UN entities (Kosovo,
  Taiwan, Hong Kong, the European Union, and South Vietnam for COW;
  Kosovo, Taiwan, and South Vietnam for GW).

- exclude_islands:

  Logical. Exclude six small Caribbean island states: Dominica, Grenada,
  Saint Lucia, Saint Vincent and the Grenadines, Antigua and Barbuda,
  and Saint Kitts and Nevis.

## Value

A data frame with COW-coded state-year observations.

## Examples

``` r
panel <- build_states_cow_panel(1990, 1995)
```
