# Apply the package's COW panel conventions to COW codes

The package's COW panels code the German Federal Republic (COW 260,
1955-1990) as 255 and Czechoslovakia (COW 315, up to 1992) as 316, so
that each state has one code over time. Data joined to these panels must
use the same codes.

## Usage

``` r
standardize_cow(code, year = NULL)
```

## Arguments

- code:

  Integer vector of COW codes.

- year:

  Optional integer vector of years.

## Value

`code` with 260 recoded to 255 and 315 to 316.

## Details

With `year`, Yemen is also coded by period: 678 (Yemen Arab Republic) up
to 1990 and 679 (Yemen) from 1991, as some sources use one code
throughout.
