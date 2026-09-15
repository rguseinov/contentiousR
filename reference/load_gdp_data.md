# Load GDP per capita data

Loads GDP per capita data from the Gapminder dataset included with the
package and returns a country-year dataset using either COW or
Gleditsch-Ward country codes.

## Usage

``` r
load_gdp_data(
  start_year = 1945,
  end_year = 2019,
  coding_system = c("cow", "gw")
)
```

## Source

GDP per capita data from Gapminder. Gapminder data are distributed under
CC BY 4.0; please cite Gapminder and the original data providers.

## Arguments

- start_year:

  Integer. First year to include.

- end_year:

  Integer. Last year to include.

- coding_system:

  Character. Country coding system to use. Either `"cow"` for Correlates
  of War codes or `"gw"` for Gleditsch-Ward codes.

## Value

A data frame with country-year GDP indicators. If
`coding_system = "cow"`, the data frame contains a `cow` column. If
`coding_system = "gw"`, it contains a `gw` column. The returned data
also include `year`, `gdp_pcap`, `log_gdp_pcap`, and `gdp_growth`.

## Examples

``` r
gdp_cow <- load_gdp_data(coding_system = "cow")

gdp_gw <- load_gdp_data(coding_system = "gw")
```
