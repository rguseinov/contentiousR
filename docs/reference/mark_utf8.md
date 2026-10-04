# Mark every character column of a data frame as UTF-8

Mark every character column of a data frame as UTF-8

## Usage

``` r
mark_utf8(data)
```

## Arguments

- data:

  A data frame.

## Value

`data`, with [`Encoding()`](https://rdrr.io/r/base/Encoding.html) set to
`"UTF-8"` on every element of every character column.

## Details

Several bundled sources (NAVCO 1.3/2.1, Beissinger, CSRA) contain
genuinely UTF-8-encoded text (e.g. curly apostrophes in campaign names
like "Student's Anti-Chun Protest") that R leaves tagged as
`Encoding() == "unknown"` after loading, whether from an `.RData` file
or
[`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html)
without an explicit `locale`. An "unknown" encoding is treated as the
platform's native encoding wherever it's next converted – harmless on
macOS/Linux, where native is already UTF-8, but on Windows this silently
corrupts the string (observed as an embedded `nul` byte, which makes
`R CMD check`'s vignette rebuild fail outright). Explicitly tagging the
bytes as UTF-8, which they already are, avoids that native-encoding
guess entirely.
