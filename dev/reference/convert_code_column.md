# Convert the country-code column of a country-period data frame

Applies
[`convert_state_code()`](https://rguseinov.github.io/contentiousR/dev/reference/convert_state_code.md)
to `data[[code_col]]` and stores the result in a column named `to`. Rows
without an equivalent are dropped. Where two source codes map to the
same code and period (for example COW 255 and 260 in 1990, which the
package's COW panels both code 255), the row whose source code equals
the new code is kept.

## Usage

``` r
convert_code_column(data, code_col, from, to)
```

## Arguments

- data:

  A data frame with `year` and a code column.

- code_col:

  Name of the code column.

- from, to:

  `"cow"` or `"gw"`.

## Value

`data` with the code column `to` first.
