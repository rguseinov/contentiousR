# Whether a state is in the state system in a year

Uses the `states` package's COW or GW list; a state counts in every year
it existed for any part of, as in
[`build_states_panel()`](https://rguseinov.github.io/contentiousR/dev/reference/build_states_panel.md).
For COW, the panels' codes 255 and 316 also cover the years of 260 and
315.

## Usage

``` r
state_exists(code, year, coding_system)
```

## Arguments

- code:

  Integer vector of codes.

- year:

  Integer vector of years.

- coding_system:

  `"cow"` or `"gw"`.

## Value

A logical vector.
