# Add data from peacesciencer and restore the contentiousR schema

Temporarily adapts a contentiousR state-year panel to the column names
and metadata expected by a `peacesciencer` `add_*()` function. After
that function returns, the temporary `ccode` or `gwcode` alias and
dispatch attributes are removed. The original `cow` or `gw` key is
retained.

## Usage

``` r
add_from_peacesciencer(panel, .fun, ...)
```

## Arguments

- panel:

  A contentiousR state-year data frame containing exactly one of `cow`
  or `gw` and a `year` column.

- .fun:

  A `peacesciencer` function whose first argument is a state-year data
  frame, such as
  [`peacesciencer::add_archigos`](https://rdrr.io/pkg/peacesciencer/man/add_archigos.html).

- ...:

  Additional arguments passed to `.fun`.

## Value

The data frame returned by `.fun`, restored to the input contentiousR
key schema. A pre-existing `ccode` or `gwcode` column and pre-existing
`ps_system` or `ps_data_type` attributes are preserved.

## Details

This helper is intended for `peacesciencer` functions that support
state-year data. `ccode` is the standard COW code (see
[`as_peacesciencer_panel()`](https://rguseinov.github.io/contentiousR/dev/reference/as_peacesciencer_panel.md)):
West Germany and Czechoslovakia get their own COW codes, 260 and 315,
while `peacesciencer` adds its data, and the panel keeps contentiousR's
`cow` codes afterwards.

Use
[`as_peacesciencer_panel()`](https://rguseinov.github.io/contentiousR/dev/reference/as_peacesciencer_panel.md)
instead when several `peacesciencer` functions will be applied in one
uninterrupted pipeline and retaining the compatibility metadata until
the end is preferable.

## Examples

``` r
if (requireNamespace("peacesciencer", quietly = TRUE)) {
  library(peacesciencer)

  panel <- build_states_panel(1990, 1995, coding_system = "cow") |>
    add_from_peacesciencer(add_archigos)
}
#> {peacesciencer} includes additional remote data for separate download. Please type ?download_extdata() for more information.
#> This message disappears on load when these data are downloaded and in the package's `extdata` directory.
```
