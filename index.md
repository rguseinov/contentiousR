# contentiousR

`contentiousR` is an R package that provides tools and datasets for
contentious politics and civil conflicts research. It provides a
flexible workflow for creating state panels and enriching them with
socioeconomic, political, and conflict indicators.

## Installation

Install the released version from CRAN:

``` r

install.packages("contentiousR")
```

Or the development version from GitHub:

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

## Package supports two workflows

`contentiousR` supports two ways of working, which can be used
separately or together.

### Pipeline workflow

This workflow allows building a complete panel in one chain. This
workflow is similar to the one used in `peacesciencer` R package.
Functions automatically detect the coding system and year range from the
panel:

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

One can also load each dataset independently. Then, one can inspect the
dataset, or use custom merging tools:

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
articles for the full tutorial, including information on what datasets
are included, and how the package supports interoperability with
`peacesciencer`.

## Citation

If you use `contentiousR` in your research, please cite the accompanying
paper:

> Guseinov, R. (2026). *contentiousR: An R package for contentious
> politics and civil conflict research* \[Preprint\]. SSRN.
> <https://doi.org/10.2139/ssrn.7506799>

For LaTeX users, the BibTeX entry is below; citation(“contentiousR”)
returns the same.

``` bibtex
@misc{guseinov2026contentiousr,
  author       = {Guseinov, Ruslan},
  title        = {{contentiousR}: An {R} Package for Contentious Politics and Civil Conflict Research},
  year         = {2026},
  howpublished = {SSRN preprint},
  doi          = {10.2139/ssrn.7506799},
  url          = {https://ssrn.com/abstract=7506799}
}
```

To cite the software itself:

> Guseinov, R. (2026). *contentiousR: Contentious Politics and Civil
> Conflict Research*. R package version 0.1.0.
> <https://CRAN.R-project.org/package=contentiousR>

Please also cite every third-party data source used in an analysis —
`contentiousR` only assembles and reshapes this data. For this, you can
use
[`cn_cite()`](https://rguseinov.github.io/contentiousR/reference/cn_cite.md),
which prints the citation as ready-to-paste BibTeX:

``` r

cn_cite("navco2.1")
cn_cite("add_gdp()")
```

See the [data-source
guide](https://rguseinov.github.io/contentiousR/articles/data-sources.html)
for dataset versions, source links, and licensing notes.

## Acknowledgments

The package logo was generated with ChatGPT. Claude (Anthropic) was used
to proofread the documentation and vignettes for grammatical and
typographical errors and to refine the wording of several passages, and
to review the package’s R code.
