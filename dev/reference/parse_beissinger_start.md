# Parse the start dates of the Beissinger Revolutionary Episodes Dataset

The source's `startdatetxt` gives a full date ("June 2, 1899"), a month
("August 1899"), or a year ("1964").

## Usage

``` r
parse_beissinger_start(x)
```

## Arguments

- x:

  Character vector of `startdatetxt` values.

## Value

A list with `date` (a `Date`, with placeholder day or month where the
source gives none) and `precision` (`"day"`, `"month"`, or `"year"`).
