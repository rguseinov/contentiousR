# contentiousR

`contentiousR` is an R package that provides tools and datasets for
contentious politics and civil conflicts research. It provides a
flexible workflow for creating state panels and enriching them with
socioeconomic, political, and conflict indicators — using either
Correlates of War (COW) or Gleditsch-Ward (GW) country coding schemes.

## Installation

``` r

# install.packages("remotes")
remotes::install_github("rguseinov/contentiousR")
```

> **Note:**
> [`load_vdem_data()`](https://rguseinov.github.io/contentiousR/reference/load_vdem_data.md)
> and
> [`add_vdem()`](https://rguseinov.github.io/contentiousR/reference/add_vdem.md)
> require the `vdemdata` package, which is not on CRAN:
>
> ``` r
>
> remotes::install_github("vdeminstitute/vdemdata")
> ```

## Two workflows, your choice

`contentiousR` supports two ways of working - use them separately or
together.

### Pipeline workflow

Build a complete panel in one chain. Functions automatically detect the
coding system and year range from the panel:

``` r

library(contentiousR)
library(dplyr)

panel <- build_states_panel(
    start_year = 1990,
    end_year   = 2015,
    coding_system = "cow"
  ) |>
  add_gdp() |>
  add_vdem(vars = c("v2x_polyarchy", "v2x_libdem", "v2x_rule")) |>
  add_conflict(dataset = "navco2.1") |>
  add_leader_data(dataset = "archigos")
```

### Standalone workflow

Load each dataset independently for inspection or custom merging:

``` r

panel     <- build_states_panel(1990, 2015, coding_system = "cow")
gdp_data  <- load_gdp_data(1990, 2015, coding_system = "cow")
vdem_data <- load_vdem_data(
  vars          = c("v2x_polyarchy", "v2x_libdem"),
  start_year    = 1990,
  end_year      = 2015,
  coding_system = "cow"
)
conflicts <- conflict_data(1990, 2015, dataset = "navco2.1", coding_system = "cow")

# Join on your own terms
panel <- panel |>
  left_join(gdp_data,  by = c("cow", "year")) |>
  left_join(vdem_data, by = c("cow", "year")) |>
  left_join(
    conflicts |>
      group_by(cow, year) |>
      summarise(onset = max(nvc2.1_ONSET), .groups = "drop"),
    by = c("cow", "year")
  )
```

See the [Get
started](https://rguseinov.github.io/contentiousR/articles/contentiousR.html)
and [Data sources and
interpretation](https://rguseinov.github.io/contentiousR/articles/data-sources.html)
articles for the full function walkthrough, dataset coverage tables, and
interoperability with `peacesciencer`.

## Citation

If you use `contentiousR` in your research, please cite:

> Guseinov, R. (2026). *contentiousR: Tools and Data for Contentious
> Politics and Civil Conflict Research*. R package version 0.1.0.
> <https://github.com/rguseinov/contentiousR>

Please also cite every third-party data source used in an analysis —
`contentiousR` only assembles and reshapes this data, it does not
replace citing the original creators.
[`cn_cite()`](https://rguseinov.github.io/contentiousR/reference/cn_cite.md)
looks up the bundled citation for a function or `dataset =` value and
prints it as ready-to-paste BibTeX:

``` r

cn_cite("navco2.1")
cn_cite("add_gdp()")
```

See the [data-source
guide](https://rguseinov.github.io/contentiousR/articles/data-sources.html)
for versions, transformations, source links, and licensing notes, and
[`?cn_cite`](https://rguseinov.github.io/contentiousR/reference/cn_cite.md)
for the full lookup interface.

## Acknowledgments

The package logo was generated with ChatGPT.
