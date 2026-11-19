# Convert country codes between COW and Gleditsch-Ward, by year

`countrycode` maps codes one to one, without regard to the year, and has
no equivalent for several states. This function handles the cases where
the two systems differ:

- Germany: COW 255 is GW 255 up to 1945 and GW 260 from 1946; COW 260
  (German Federal Republic) is GW 260.

- Serbia and Yugoslavia: COW 345 throughout; GW 340 (Serbia) up to 1915
  and from June 2006, 345 (Yugoslavia) in between.

- Czechoslovakia and the Czech Republic: GW 315 up to 1992, 316 from
  1993.

- Yemen: COW 678 (Yemen Arab Republic) up to 1990 and 679 (Yemen) from
  1991; GW 678 throughout.

- Vietnam: 816 in both systems (`countrycode` gives GW 815, a
  19th-century state).

- Microstates numbered differently: Kiribati (COW 946, GW 970), Nauru
  (970, 971), Tonga (955, 972), Tuvalu (947, 973).

Other codes that exist in both systems' state lists keep their number;
the rest go through `countrycode`.

## Usage

``` r
convert_state_code(code, year, from, to, month = NULL)
```

## Arguments

- code:

  Integer vector of codes.

- year:

  Integer vector of years, recycled to `code`.

- from, to:

  `"cow"` or `"gw"`.

- month:

  Optional integer vector of months, used for the 2006 split of Serbia
  and Montenegro (GW 340 from June 2006). Without it, all of 2006 is GW
  340.

## Value

An integer vector of codes in `to`; `NA` where there is no equivalent.

## Details

The COW codes returned follow the package's COW panels, which code West
Germany as 255 and Czechoslovakia as 316 (see
[`standardize_cow()`](https://rguseinov.github.io/contentiousR/dev/reference/standardize_cow.md)).
