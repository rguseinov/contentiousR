# Load V-Dem data

Loads selected country-year variables from the V-Dem dataset provided by
the `vdemdata` package. The returned data can use either COW or
Gleditsch-Ward country codes.

## Usage

``` r
load_vdem_data(
  vars = NULL,
  start_year = 1945,
  end_year = 2019,
  coding_system = c("cow", "gw")
)
```

## Source

Varieties of Democracy (V-Dem) Project. Please cite V-Dem when using
these data.

## Arguments

- vars:

  Character vector of V-Dem variable names to include. If `NULL`, a
  default set of civil society, repression, civil liberties, democracy,
  corruption, and rule-of-law indicators is returned.

- start_year:

  Integer. First year to include.

- end_year:

  Integer. Last year to include.

- coding_system:

  Character. Country coding system to use. Either `"cow"` for Correlates
  of War codes or `"gw"` for Gleditsch-Ward codes.

## Value

A data frame with country-year V-Dem indicators. If
`coding_system = "cow"`, the data frame contains a `cow` column. If
`coding_system = "gw"`, it contains a `gw` column.

## Details

This function requires the `vdemdata` package. If it is not installed,
install it with:

`remotes::install_github("vdeminstitute/vdemdata")`. Because `vdemdata`
is not distributed through CRAN, it is always checked conditionally.

For `coding_system = "gw"`, V-Dem COW codes are converted to
Gleditsch-Ward codes using
[`countrycode::countrycode()`](https://rdrr.io/pkg/countrycode/man/countrycode.html).

## Examples

``` r
if (requireNamespace("vdemdata", quietly = TRUE)) {
vdem_cow <- load_vdem_data(coding_system = "cow")

vdem_selected <- load_vdem_data(
  vars = c("v2x_polyarchy", "v2x_libdem", "v2x_rule"),
  coding_system = "cow"
)

vdem_gw <- load_vdem_data(
  vars = c("v2x_polyarchy", "v2x_libdem"),
  coding_system = "gw"
)
}
```
