# Expand date spells to the panel periods they overlap

Expand date spells to the panel periods they overlap

## Usage

``` r
expand_spells(spells, unit)
```

## Arguments

- spells:

  A data frame with `code`, `id`, `start`, and `end` (`Date`).

- unit:

  `"year"`, `"quarter"`, `"month"`, or `"day"`.

## Value

A data frame with `code`, `id`, and the time keys of `unit`.
