# Load GDP data

Loads GDP data from one of two sources included with the package and
returns a country-year dataset using either COW or Gleditsch-Ward
country codes.

## Usage

``` r
load_gdp_data(
  start_year = 1945,
  end_year = 2019,
  dataset = c("gapminder", "fariss"),
  coding_system = c("cow", "gw")
)
```

## Source

**Gapminder:** GDP per capita data from Gapminder. Gapminder data are
distributed under CC BY 4.0; please cite Gapminder and the original data
providers.

**Fariss:** Fariss, C.J., Anders, T., Markowitz, J.N., & Barnum, M.
(2022). New estimates of over 500 years of historic GDP and population
data. *Journal of Conflict Resolution*, 66(3), 553-591.

## Arguments

- start_year:

  Integer. First year to include.

- end_year:

  Integer. Last year to include.

- dataset:

  Character. Dataset to load:

  `"gapminder"`

  : Gapminder GDP per capita (v32). Coverage: 1945-2019 by default (full
    source coverage is wider).

  `"fariss"`

  : Latent GDP and GDP per capita estimates (Fariss, Anders, Markowitz &
    Barnum 2022), combined from their `fariss_gdp` and `fariss_gdppc`
    replication files. Coverage: 1500-2019.

- coding_system:

  Character. Country coding system to use. Either `"cow"` for Correlates
  of War codes or `"gw"` for Gleditsch-Ward codes.

## Value

A data frame with country-year GDP indicators. If
`coding_system = "cow"`, the data frame contains a `cow` column. If
`coding_system = "gw"`, it contains a `gw` column. Columns differ by
dataset:

**gapminder:** `year`, `gdp_pcap`, `log_gdp_pcap`, `gdp_growth`.

**fariss:** `year`, `fariss_gdp`, `fariss_gdppc`.

## Details

`gdp_growth` (gapminder only) is `NA` unless the preceding row is
genuinely one year earlier for the same country, the same gap-safety
check
[`add_lag()`](https://rguseinov.github.io/contentiousR/reference/add_lag.md)
uses, so a missing year never silently produces a growth rate computed
against the wrong base year.

`fariss_gdp` and `fariss_gdppc` are the model's own latent-scale
estimates, taken directly from the `"latent_gdp"`/`"latent_gdppc"` rows
of the replication files (as opposed to the underlying raw indicator
series also present in those files). Their absolute units are not
independently verified here; consult Fariss et al. (2022) before using
them outside of relative/comparative analysis.

## Examples

``` r
gdp_cow <- load_gdp_data(coding_system = "cow")

gdp_gw <- load_gdp_data(coding_system = "gw")

fariss_gdp <- load_gdp_data(1900, 2015, dataset = "fariss", coding_system = "cow")
```
