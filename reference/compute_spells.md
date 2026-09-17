# Compute a BTSCS spell/duration counter

Compute a BTSCS spell/duration counter

## Usage

``` r
compute_spells(unit, year, event, ongoing)
```

## Arguments

- unit:

  Cross-sectional unit identifier, one value per row.

- year:

  Integer year, one value per row.

- event:

  Binary (0/1) event indicator, one value per row.

- ongoing:

  Logical. See
  [`add_spell_duration()`](https://rguseinov.github.io/contentiousR/reference/add_spell_duration.md).

## Value

An integer vector of spell values, one per input row (in the original
row order).
