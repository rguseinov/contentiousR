# Country names for state codes

Uses `countrycode`, and the `states` package's names where `countrycode`
has none (for example GW 816, Vietnam, and several microstates).

## Usage

``` r
state_names(code, coding_system)
```

## Arguments

- code:

  Integer vector of codes.

- coding_system:

  `"cow"` or `"gw"`.

## Value

A character vector.
