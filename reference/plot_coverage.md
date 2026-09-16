# Plot country-year coverage of a variable

Draws a country-by-year heatmap showing which country-years have a
non-missing value for `var`, and which are `NA`. Useful for auditing a
source's actual coverage (or the coverage of a panel assembled with
several `add_*()` calls) before running an analysis.

## Usage

``` r
plot_coverage(panel, var, drop_empty = TRUE)
```

## Arguments

- panel:

  A data frame produced by
  [`build_states_panel()`](https://rguseinov.github.io/contentiousR/reference/build_states_panel.md),
  containing a `cow` or `gw` column, a `year` column, and `var`.

- var:

  Character. Name of the column in `panel` to check coverage for.

- drop_empty:

  Logical. If `TRUE` (default), drop states with zero observed years for
  `var` before plotting. A state that never matches a source (e.g. it
  never appears in a conflict dataset) contributes a fully-grey row that
  adds clutter without showing where coverage actually varies; set to
  `FALSE` to include these states anyway.

## Value

A `ggplot` object (one tile per country-year, filled by whether `var` is
observed). States are ordered top-to-bottom by their share of observed
years, most-covered first. Requires the `ggplot2` package.

## Examples

``` r
if (requireNamespace("ggplot2", quietly = TRUE)) {
  build_states_panel(1990, 2015, coding_system = "cow") |>
    add_conflict("ucdp_prio") |>
    plot_coverage("ucdp_prio_incidence")
}

```
