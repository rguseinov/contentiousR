# Get started with peacebuilder

`peacebuilder` creates reproducible country-year panels for peace
science and cross-national political research. Every public loader
supports Correlates of War (`"cow"`) and Gleditsch-Ward (`"gw"`) country
codes.

## Build and enrich a panel

Start with the universe of states, then add data with left joins. The
add functions infer the coding system and requested years from the
panel.

``` r

library(peacebuilder)

panel <- build_states_panel(
  start_year = 2000,
  end_year = 2002,
  coding_system = "cow"
)

analysis_data <- panel |>
  add_gdp() |>
  add_conflict("ucdp_prio") |>
  add_leader_data("archigos")

analysis_data[1:4, c(
  "country", "year", "gdp_pcap", "ucdp_prio_incidence", "leader"
)]
#>         country year gdp_pcap ucdp_prio_incidence    leader
#> 1 United States 2000 55889.52                  NA   Clinton
#> 2 United States 2001 55783.75                   1 G.W. Bush
#> 3 United States 2002 56127.44                   1 G.W. Bush
#> 4        Canada 2000 48531.95                  NA  Chretien
```

An unmatched row remains `NA`. This is deliberate: a source may not
cover a country-year, and lack of a match should not automatically be
interpreted as zero events.

## Load data separately

Standalone loaders are useful when you want to inspect or aggregate data
before joining them.

``` r

conflicts <- conflict_data(
  start_year = 2000,
  end_year = 2002,
  dataset = "ucdp_prio",
  coding_system = "gw"
)

head(conflicts)
#> # A tibble: 6 × 13
#>      gw  year ucdp_prio_incidence ucdp_prio_onset ucdp_prio_n_conflicts
#>   <int> <dbl>               <int>           <int>                 <int>
#> 1     2  2001                   1               1                     2
#> 2     2  2002                   1               0                     1
#> 3   100  2000                   1               0                     1
#> 4   100  2001                   1               0                     1
#> 5   100  2002                   1               0                     1
#> 6   200  2001                   1               1                     1
#> # ℹ 8 more variables: ucdp_prio_intensity_max <int>, ucdp_prio_war <int>,
#> #   ucdp_prio_cumulative_intensity <int>, ucdp_prio_type_max <int>,
#> #   ucdp_prio_intrastate <int>, ucdp_prio_interstate <int>,
#> #   ucdp_prio_incompatibility_max <int>, ucdp_prio_ep_end <int>
```

UCDP/PRIO distinguishes active conflict-years (`ucdp_prio_incidence`)
from the first year of an episode (`ucdp_prio_onset`). See
[`vignette("data-sources", package = "peacebuilder")`](https://rguseinov.github.io/peacebuilder/articles/data-sources.md)
before interpreting any source-specific variable.

## Optional V-Dem data

V-Dem is not bundled and its R data package is not on CRAN. Install it
from its official repository, then request only the indicators you need:

``` r

remotes::install_github("vdeminstitute/vdemdata")

panel |>
  add_vdem(c("v2x_polyarchy", "v2x_libdem"))
```

## Interoperate with peacesciencer

Functions such as
[`peacesciencer::add_archigos()`](https://rdrr.io/pkg/peacesciencer/man/add_archigos.html)
expect `ccode`/`gwcode` keys plus attributes that describe the state
system and unit of analysis. Add
[`as_peacesciencer_panel()`](https://rguseinov.github.io/peacebuilder/reference/as_peacesciencer_panel.md)
immediately before using those functions:

``` r

library(peacesciencer)

analysis_data |>
  as_peacesciencer_panel() |>
  peacesciencer::add_archigos()
```

The adapter keeps `cow` or `gw`, adds only the corresponding alias, and
marks the data as state-year. It does not change rows or substantive
variables.
