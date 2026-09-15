# Make a state panel compatible with peacesciencer

Adds the key alias and metadata expected by state-year functions from
the `peacesciencer` package. The original `cow` or `gw` column is
retained, so the result remains compatible with all `peacebuilder`
functions.

## Usage

``` r
as_peacesciencer_panel(panel)
```

## Arguments

- panel:

  A state-year data frame containing exactly one of `cow` or `gw` and a
  `year` column.

## Value

The input data frame with an additional `ccode` (COW) or `gwcode`
(Gleditsch-Ward) alias and the attributes `ps_system` and
`ps_data_type = "state_year"`. Rows and analytical variables are not
changed.

## Details

`peacesciencer` dispatches its `add_*()` functions using attributes
created by
[`peacesciencer::create_stateyears()`](https://rdrr.io/pkg/peacesciencer/man/create_stateyears.html).
It also expects its own key names: `ccode` for COW panels and `gwcode`
for Gleditsch-Ward panels. This adapter supplies that interface without
replacing peacebuilder's `cow` or `gw` key.

Place the adapter immediately before the first `peacesciencer` function,
or earlier in the pipeline. Dplyr joins used by peacebuilder preserve
these attributes.

## Examples

``` r
panel <- build_states_panel(1990, 1995, coding_system = "cow") |>
  add_gdp() |>
  as_peacesciencer_panel()

names(panel)
#> [1] "cow"          "year"         "country"      "gdp_pcap"     "log_gdp_pcap"
#> [6] "gdp_growth"   "ccode"       
attr(panel, "ps_system")
#> [1] "cow"
attr(panel, "ps_data_type")
#> [1] "state_year"
```
