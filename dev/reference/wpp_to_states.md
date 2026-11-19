# Assign WPP countries to COW or GW states by year

See the WPP section of
[`load_population_data()`](https://rguseinov.github.io/contentiousR/dev/reference/load_population_data.md)
for the rules. Each WPP country counts as its own state in the years
that state is in the target system's state list; otherwise it is added
to the state it belonged to, if any.

## Usage

``` r
wpp_to_states(wpp, coding_system)
```

## Arguments

- wpp:

  A data frame with `country_code` (UN M49), `year`, and `pop`.

- coding_system:

  `"cow"` or `"gw"`.

## Value

A data frame with the country code, `year`, and `wpp_pop`.
