# Add region names to a state panel

Joins region names onto an existing state panel via
[`countrycode::countrycode()`](https://rdrr.io/pkg/countrycode/man/countrycode.html),
mapping the panel's `cow`/`gw` codes to one or more of `countrycode`'s
regional classifications. The coding system is detected automatically
from the panel.

## Usage

``` r
add_regions(panel, region = "region")
```

## Arguments

- panel:

  A data frame produced by
  [`build_states_panel()`](https://rguseinov.github.io/contentiousR/reference/build_states_panel.md),
  containing a `cow` or `gw` column.

- region:

  Character vector selecting one or more `countrycode` destination
  classifications to add, from:

  - `"region"` (default): World Bank 7-region classification.

  - `"region23"`: World Bank's finer, 23-region classification.

  - `"un.region.name"`: UN macro-region (continent-level).

  - `"un.regionsub.name"`: UN sub-region.

  See
  [`countrycode::countrycode()`](https://rdrr.io/pkg/countrycode/man/countrycode.html)
  for details on these classifications.

## Value

The input panel with one additional column per entry in `region`, named
after the classification (e.g. `region`, `region23`), holding the
corresponding region name for each row (`NA` where `countrycode()` finds
no match).

## Examples

``` r
panel <- build_states_panel(1990, 2000, coding_system = "cow") |>
  add_regions()

panel <- build_states_panel(1990, 2000, coding_system = "cow") |>
  add_regions(region = c("region", "un.regionsub.name"))
```
