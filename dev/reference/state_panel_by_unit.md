# State-system membership panel at a given time unit

State-system membership panel at a given time unit

## Usage

``` r
state_panel_by_unit(start_year, end_year, unit, useGW)
```

## Arguments

- start_year, end_year:

  First and last year.

- unit:

  `"year"`, `"quarter"`, `"month"`, or `"day"`.

- useGW:

  Logical, passed to
  [`states::state_panel()`](https://www.andybeger.com/states/reference/state_panel.html).

## Value

A data frame with `cowcode` or `gwcode`, `year`, and, for sub-annual
units, `quarter` or `month` (and `day` and `date` for `"day"`).
