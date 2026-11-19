# Average a vector while preserving all-missing groups

Average a vector while preserving all-missing groups

## Usage

``` r
safe_mean(x)
```

## Arguments

- x:

  A numeric vector.

## Value

A length-one numeric: the mean of the non-missing values, or `NA_real_`
if there are none.
