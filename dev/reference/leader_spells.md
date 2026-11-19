# Leader spells with start and end dates

One row per leader spell, with `ccode` (COW), `start` and `end`
(`Date`), `start_yr`, a sort key `start_order`, and the leader
attributes.

## Usage

``` r
leader_spells(dataset)
```

## Arguments

- dataset:

  `"archigos"` or `"reign"`.

## Value

A data frame.

## Details

Archigos gives exact dates. REIGN gives the year and month of entry and
exit (and the day of entry): a REIGN spell runs from the first day of
its entry month to the last day of its exit month. Leaders still in
office at the end of the REIGN data have no exit date; they are kept in
office through the last month the source covers.
