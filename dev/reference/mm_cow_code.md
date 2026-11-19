# COW codes of the Mass Mobilization data

The Mass Mobilization data use several codes that differ from COW: 341
for Kosovo (COW 347; COW 341 is Montenegro), 347 for Yugoslavia and
Serbia and Montenegro in 1992-2006 (COW 345), 342 for Serbia from 2006
(COW 345), 348 for Montenegro (COW 341), 364 for the USSR (COW 365), 525
for South Sudan (COW 626), 529 for Ethiopia from 2016 (COW 530), and 678
for Yemen from 2016 (COW 679). This maps them to COW and applies
[`standardize_cow()`](https://rguseinov.github.io/contentiousR/dev/reference/standardize_cow.md).

## Usage

``` r
mm_cow_code(code, year)
```

## Arguments

- code:

  Integer vector of Mass Mobilization `ccode` values.

- year:

  Integer vector of years.

## Value

An integer vector of COW codes.
