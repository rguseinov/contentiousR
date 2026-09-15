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
state-year data. It does not alter country codes: `ccode` is simply
`peacesciencer`'s name for the COW code stored as `cow` by contentiousR.

Use
[`as_peacesciencer_panel()`](https://rguseinov.github.io/contentiousR/reference/as_peacesciencer_panel.md)
instead when several `peacesciencer` functions will be applied in one
uninterrupted pipeline and retaining the compatibility metadata until
the end is preferable.

## Examples

``` r
if (FALSE) { # \dontrun{
library(peacesciencer)

panel <- build_states_panel(1990, 1995, coding_system = "cow") |>
  add_from_peacesciencer(add_archigos)
} # }
```
