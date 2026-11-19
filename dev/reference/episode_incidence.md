# Active episodes per country-period

For campaign and episode datasets, counts the episodes in progress in
each country-period, from each episode's start to its end date. Used by
[`add_conflict()`](https://rguseinov.github.io/contentiousR/dev/reference/add_conflict.md).

## Usage

``` r
episode_incidence(dataset, coding_system, start_year, end_year, unit)
```

## Arguments

- dataset:

  One of `spell_datasets`.

- coding_system:

  `"cow"` or `"gw"`.

- start_year, end_year:

  Years of the panel.

- unit:

  `"year"`, `"quarter"`, `"month"`, or `"day"`.

## Value

A data frame with the country code, the time keys of `unit`,
`<prefix>incidence` (1 if at least one episode was active), and
`<prefix>n_active` (the number of active episodes).

## Details

Start dates less precise than `unit` drop the episode, as for onsets. An
end date less precise than `unit` is taken to be the last day of the
period the source gives (for example, an episode that ended "in 2005" is
active through December 2005). Episodes the source codes as ongoing run
to the end of its coverage.
