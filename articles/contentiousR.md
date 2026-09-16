# Get started with contentiousR

`contentiousR` creates reproducible country-year panels for contentious
politics and civil conflicts research. Every public loader supports
Correlates of War (`"cow"`) and Gleditsch-Ward (`"gw"`) country codes.

## Build and enrich a panel

Start with the universe of states, then add data with left joins. The
add functions infer the coding system and requested years from the
panel.

``` r

library(contentiousR)

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
[`vignette("data-sources", package = "contentiousR")`](https://rguseinov.github.io/contentiousR/articles/data-sources.md)
before interpreting any source-specific variable.

## Optional V-Dem data

V-Dem is not bundled and its R data package is not on CRAN. Install it
from its official repository, then request only the indicators you need:

``` r

remotes::install_github("vdeminstitute/vdemdata")

panel |>
  add_vdem(c("v2x_polyarchy", "v2x_libdem"))
```

## `build_states_panel()`

Creates a state-year panel with optional filters:

``` r

panel <- build_states_panel(
  start_year        = 1946,
  end_year          = 2019,
  coding_system     = "cow",   # or "gw"
  exclude_microstates = TRUE,
  exclude_non_un    = TRUE,
  exclude_islands   = FALSE
)
```

## `load_gdp_data()` / `add_gdp()`

Two GDP sources are available via `dataset`. `"gapminder"` (default)
returns `gdp_pcap`, `log_gdp_pcap`, and `gdp_growth`. `"fariss"` returns
the latent GDP and GDP per capita estimates from Fariss, Anders,
Markowitz, and Barnum (2022) as `fariss_gdp` and `fariss_gdppc`, with
much wider coverage (1500–2019) but units that are not independently
verified in this package — see
[`vignette("data-sources", package = "contentiousR")`](https://rguseinov.github.io/contentiousR/articles/data-sources.md).

``` r

# Standalone
gdp <- load_gdp_data(start_year = 1990, end_year = 2015, coding_system = "cow")
fariss_gdp <- load_gdp_data(1700, 2015, dataset = "fariss", coding_system = "cow")

# Pipeline
panel |> add_gdp()
panel |> add_gdp(dataset = "fariss")
```

## `load_population_data()` / `add_pop()`

Three population sources are available via `dataset`.

| Dataset | Source | Coverage | Returned columns |
|----|----|----|----|
| `"wpp"` (default) | [UN World Population Prospects 2024](https://population.un.org/wpp/) | 1949–2023 | `un_pop` |
| `"nmc"` | [Correlates of War NMC v7.0](https://correlatesofwar.org/data-sets/national-material-capabilities/) | 1816–2022 | `tpop`, `upop` |
| `"fariss"` | Fariss et al. (2022) latent estimate | 1500–2019 | `fariss_pop` |

``` r

# Standalone
pop_wpp <- load_population_data(1990, 2015, dataset = "wpp", coding_system = "cow")
pop_nmc <- load_population_data(1900, 2015, dataset = "nmc", coding_system = "cow")

# Pipeline
panel |> add_pop()
panel |> add_pop(dataset = "nmc")
```

## `load_vdem_data()` / `add_vdem()`

V-Dem indicators. A default set of democracy, civil society, civil
liberties, and rule-of-law variables is loaded when `vars = NULL`.

``` r

# Standalone
vdem <- load_vdem_data(
  vars          = c("v2x_polyarchy", "v2x_libdem"),
  start_year    = 1990,
  end_year      = 2015,
  coding_system = "cow"
)

# Pipeline
panel |> add_vdem(vars = c("v2x_polyarchy", "v2x_libdem"))
```

## `load_leader_data()` / `add_leader_data()`

Country-year leader data from two sources. Each row contains the leader
who held power at the end of the year; in transition years the
latest-starting leader is kept.

| Dataset | Source | Coverage | Key variables |
|----|----|----|----|
| `"archigos"` | [Archigos 4.1](http://ksgleditsch.com/archigos.md) | 1875–2015 | `entry`, `exit`, `irregular_entry`, `irregular_exit`, `female_leader`, `yrborn`, `posttenurefate`, `leader_tenure` |
| `"reign"` | [REIGN Leader List](https://oefdatascience.github.io/REIGN.github.io/menu/reign_current.html) | 1921–2021 | `female_leader`, `military_bg`, `birthyear`, `leader_tenure` |

``` r

# Standalone
arch  <- load_leader_data(1990, 2015, dataset = "archigos", coding_system = "cow")
reign <- load_leader_data(1990, 2015, dataset = "reign",    coding_system = "gw")

# Pipeline
panel |> add_leader_data(dataset = "archigos")
panel |> add_leader_data(dataset = "reign")
```

## Interoperate with peacesciencer

Functions such as
[`peacesciencer::add_archigos()`](https://rdrr.io/pkg/peacesciencer/man/add_archigos.html)
expect `ccode`/`gwcode` keys plus attributes that describe the state
system and unit of analysis. Use
[`add_from_peacesciencer()`](https://rguseinov.github.io/contentiousR/reference/add_from_peacesciencer.md)
to supply these temporarily and return a panel with only contentiousR’s
original country-code key:

``` r

library(peacesciencer)

analysis_data |>
  add_from_peacesciencer(peacesciencer::add_archigos)
```

For multiple consecutive additions, call
[`as_peacesciencer_panel()`](https://rguseinov.github.io/contentiousR/reference/as_peacesciencer_panel.md)
once and then apply the `peacesciencer` functions directly. Neither
helper changes country codes, rows, or substantive variables.
