# Return a typed missing value for an all-missing maximum

Return a typed missing value for an all-missing maximum

## Usage

``` r
safe_max(x)
```

## Arguments

- x:

  A vector.

## Value

A length-one vector of the same type as `x`: the maximum of the
non-missing values, or `NA` if there are none.
