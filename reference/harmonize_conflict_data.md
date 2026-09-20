# Harmonize externally supplied conflict/event data onto a state panel

Joins a conflict or event dataset that the caller supplies directly –
downloaded via GDELT, ICEWS, ACLED, or any other source not bundled with
`contentiousR` – onto an existing state panel. Unlike
[`add_conflict()`](https://rguseinov.github.io/contentiousR/reference/add_conflict.md),
this function never downloads or bundles any data itself: `data` is
whatever data frame the caller already has in R, in whatever raw column
names and country/date encodings that source happens to use.

## Usage

``` r
harmonize_conflict_data(
  panel,
  data,
  country_col,
  origin_code,
  prefix,
  year_col = NULL,
  date_col = NULL,
  date_format = NULL,
  aggregate = TRUE
)
```

## Arguments

- panel:

  A data frame produced by
  [`build_states_panel()`](https://rguseinov.github.io/contentiousR/reference/build_states_panel.md),
  containing a `cow` or `gw` column and a `year` column.

- data:

  A data frame of external conflict/event data, one row per event (the
  default; see `aggregate`).

- country_col:

  Character. Name of the column in `data` holding country identifiers.

- origin_code:

  Character. The
  [`countrycode::countrycode()`](https://rdrr.io/pkg/countrycode/man/countrycode.html)
  origin code matching `country_col`'s format, e.g. `"country.name"`,
  `"iso3c"`, `"fips"` (GDELT's two-letter country codes), `"cown"`, or
  `"gwc"`. See
  [`countrycode::codelist`](https://rdrr.io/pkg/countrycode/man/codelist.html)
  for the full list of supported origins.

- prefix:

  Character. Prefix for the new column(s), e.g. `"gdelt"` produces
  `gdelt_onset`/`gdelt_n_events` (see `aggregate`).

- year_col:

  Character. Name of a column in `data` already holding an integer year.
  Exactly one of `year_col` or `date_col` must be supplied.

- date_col:

  Character. Name of a column in `data` holding a date to extract the
  year from. Exactly one of `year_col` or `date_col` must be supplied.

- date_format:

  Character. A `format` string for
  [`as.Date()`](https://rdrr.io/r/base/as.Date.html), e.g. `"%Y%m%d"`
  for GDELT's `SQLDATE` field, or `"%d %B %Y"` for ACLED's `event_date`.
  If `NULL` (the default), `date_col` is parsed with
  [`as.Date()`](https://rdrr.io/r/base/as.Date.html) directly, which
  expects ISO 8601 (`"%Y-%m-%d"`) or an already-`Date`-typed column.
  Ignored if `year_col` is supplied.

- aggregate:

  Logical. If `TRUE` (default), `data` is treated as one row per event
  and is collapsed to one row per country-year, adding `<prefix>_onset`
  (always `1`, since a row only exists where an event occurred) and
  `<prefix>_n_events` (event count that country-year). If `FALSE`,
  `data` is assumed to already be one row per country-year; every other
  column in `data` (besides `country_col`/`year_col`/ `date_col`) is
  renamed with `<prefix>_` and joined as-is.

## Value

`panel` with the new column(s) joined in via
[`left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html).
Country-years absent from `data` remain `NA` – as with
[`add_conflict()`](https://rguseinov.github.io/contentiousR/reference/add_conflict.md),
that is not evidence of zero events, only that `data` doesn't cover that
country-year.

## Details

Country matching uses
[`countrycode::countrycode()`](https://rdrr.io/pkg/countrycode/man/countrycode.html),
so any row whose `country_col` value it cannot map to the panel's coding
system (an unrecognized name, a sub-national/organizational entry, etc.)
is dropped, with a message reporting how many rows were dropped.

`contentiousR` deliberately does not depend on `gdeltr2`, `icews`, or
`acled.api` – this function is a generic bridge instead, so the package
is not exposed to any of those clients' own dependencies, rate limits,
or licensing terms. Cite the original data source directly (this
function does not know anything about the specific provenance of
`data`).

## Examples

``` r
panel <- build_states_panel(2015, 2018, coding_system = "cow")

# An ACLED-style extract: one row per event, country as free text.
acled_like <- data.frame(
  country    = c("Nigeria", "Nigeria", "Mali", "Mali", "Mali"),
  event_date = c("2016-03-01", "2017-11-20", "2015-06-14",
                  "2015-09-02", "2018-01-30"),
  stringsAsFactors = FALSE
)

panel |>
  harmonize_conflict_data(
    data        = acled_like,
    country_col = "country",
    origin_code = "country.name",
    date_col    = "event_date",
    prefix      = "acled"
  )
#>     cow year                  country acled_n_events acled_onset
#> 1     2 2015            United States             NA          NA
#> 2     2 2016            United States             NA          NA
#> 3     2 2017            United States             NA          NA
#> 4     2 2018            United States             NA          NA
#> 5    20 2015                   Canada             NA          NA
#> 6    20 2016                   Canada             NA          NA
#> 7    20 2017                   Canada             NA          NA
#> 8    20 2018                   Canada             NA          NA
#> 9    31 2015                  Bahamas             NA          NA
#> 10   31 2016                  Bahamas             NA          NA
#> 11   31 2017                  Bahamas             NA          NA
#> 12   31 2018                  Bahamas             NA          NA
#> 13   40 2015                     Cuba             NA          NA
#> 14   40 2016                     Cuba             NA          NA
#> 15   40 2017                     Cuba             NA          NA
#> 16   40 2018                     Cuba             NA          NA
#> 17   41 2015                    Haiti             NA          NA
#> 18   41 2016                    Haiti             NA          NA
#> 19   41 2017                    Haiti             NA          NA
#> 20   41 2018                    Haiti             NA          NA
#> 21   42 2015       Dominican Republic             NA          NA
#> 22   42 2016       Dominican Republic             NA          NA
#> 23   42 2017       Dominican Republic             NA          NA
#> 24   42 2018       Dominican Republic             NA          NA
#> 25   51 2015                  Jamaica             NA          NA
#> 26   51 2016                  Jamaica             NA          NA
#> 27   51 2017                  Jamaica             NA          NA
#> 28   51 2018                  Jamaica             NA          NA
#> 29   52 2015        Trinidad & Tobago             NA          NA
#> 30   52 2016        Trinidad & Tobago             NA          NA
#> 31   52 2017        Trinidad & Tobago             NA          NA
#> 32   52 2018        Trinidad & Tobago             NA          NA
#> 33   53 2015                 Barbados             NA          NA
#> 34   53 2016                 Barbados             NA          NA
#> 35   53 2017                 Barbados             NA          NA
#> 36   53 2018                 Barbados             NA          NA
#> 37   70 2015                   Mexico             NA          NA
#> 38   70 2016                   Mexico             NA          NA
#> 39   70 2017                   Mexico             NA          NA
#> 40   70 2018                   Mexico             NA          NA
#> 41   80 2015                   Belize             NA          NA
#> 42   80 2016                   Belize             NA          NA
#> 43   80 2017                   Belize             NA          NA
#> 44   80 2018                   Belize             NA          NA
#> 45   90 2015                Guatemala             NA          NA
#> 46   90 2016                Guatemala             NA          NA
#> 47   90 2017                Guatemala             NA          NA
#> 48   90 2018                Guatemala             NA          NA
#> 49   91 2015                 Honduras             NA          NA
#> 50   91 2016                 Honduras             NA          NA
#> 51   91 2017                 Honduras             NA          NA
#> 52   91 2018                 Honduras             NA          NA
#> 53   92 2015              El Salvador             NA          NA
#> 54   92 2016              El Salvador             NA          NA
#> 55   92 2017              El Salvador             NA          NA
#> 56   92 2018              El Salvador             NA          NA
#> 57   93 2015                Nicaragua             NA          NA
#> 58   93 2016                Nicaragua             NA          NA
#> 59   93 2017                Nicaragua             NA          NA
#> 60   93 2018                Nicaragua             NA          NA
#> 61   94 2015               Costa Rica             NA          NA
#> 62   94 2016               Costa Rica             NA          NA
#> 63   94 2017               Costa Rica             NA          NA
#> 64   94 2018               Costa Rica             NA          NA
#> 65   95 2015                   Panama             NA          NA
#> 66   95 2016                   Panama             NA          NA
#> 67   95 2017                   Panama             NA          NA
#> 68   95 2018                   Panama             NA          NA
#> 69  100 2015                 Colombia             NA          NA
#> 70  100 2016                 Colombia             NA          NA
#> 71  100 2017                 Colombia             NA          NA
#> 72  100 2018                 Colombia             NA          NA
#> 73  101 2015                Venezuela             NA          NA
#> 74  101 2016                Venezuela             NA          NA
#> 75  101 2017                Venezuela             NA          NA
#> 76  101 2018                Venezuela             NA          NA
#> 77  110 2015                   Guyana             NA          NA
#> 78  110 2016                   Guyana             NA          NA
#> 79  110 2017                   Guyana             NA          NA
#> 80  110 2018                   Guyana             NA          NA
#> 81  115 2015                 Suriname             NA          NA
#> 82  115 2016                 Suriname             NA          NA
#> 83  115 2017                 Suriname             NA          NA
#> 84  115 2018                 Suriname             NA          NA
#> 85  130 2015                  Ecuador             NA          NA
#> 86  130 2016                  Ecuador             NA          NA
#> 87  130 2017                  Ecuador             NA          NA
#> 88  130 2018                  Ecuador             NA          NA
#> 89  135 2015                     Peru             NA          NA
#> 90  135 2016                     Peru             NA          NA
#> 91  135 2017                     Peru             NA          NA
#> 92  135 2018                     Peru             NA          NA
#> 93  140 2015                   Brazil             NA          NA
#> 94  140 2016                   Brazil             NA          NA
#> 95  140 2017                   Brazil             NA          NA
#> 96  140 2018                   Brazil             NA          NA
#> 97  145 2015                  Bolivia             NA          NA
#> 98  145 2016                  Bolivia             NA          NA
#> 99  145 2017                  Bolivia             NA          NA
#> 100 145 2018                  Bolivia             NA          NA
#> 101 150 2015                 Paraguay             NA          NA
#> 102 150 2016                 Paraguay             NA          NA
#> 103 150 2017                 Paraguay             NA          NA
#> 104 150 2018                 Paraguay             NA          NA
#> 105 155 2015                    Chile             NA          NA
#> 106 155 2016                    Chile             NA          NA
#> 107 155 2017                    Chile             NA          NA
#> 108 155 2018                    Chile             NA          NA
#> 109 160 2015                Argentina             NA          NA
#> 110 160 2016                Argentina             NA          NA
#> 111 160 2017                Argentina             NA          NA
#> 112 160 2018                Argentina             NA          NA
#> 113 165 2015                  Uruguay             NA          NA
#> 114 165 2016                  Uruguay             NA          NA
#> 115 165 2017                  Uruguay             NA          NA
#> 116 165 2018                  Uruguay             NA          NA
#> 117 200 2015           United Kingdom             NA          NA
#> 118 200 2016           United Kingdom             NA          NA
#> 119 200 2017           United Kingdom             NA          NA
#> 120 200 2018           United Kingdom             NA          NA
#> 121 205 2015                  Ireland             NA          NA
#> 122 205 2016                  Ireland             NA          NA
#> 123 205 2017                  Ireland             NA          NA
#> 124 205 2018                  Ireland             NA          NA
#> 125 210 2015              Netherlands             NA          NA
#> 126 210 2016              Netherlands             NA          NA
#> 127 210 2017              Netherlands             NA          NA
#> 128 210 2018              Netherlands             NA          NA
#> 129 211 2015                  Belgium             NA          NA
#> 130 211 2016                  Belgium             NA          NA
#> 131 211 2017                  Belgium             NA          NA
#> 132 211 2018                  Belgium             NA          NA
#> 133 212 2015               Luxembourg             NA          NA
#> 134 212 2016               Luxembourg             NA          NA
#> 135 212 2017               Luxembourg             NA          NA
#> 136 212 2018               Luxembourg             NA          NA
#> 137 220 2015                   France             NA          NA
#> 138 220 2016                   France             NA          NA
#> 139 220 2017                   France             NA          NA
#> 140 220 2018                   France             NA          NA
#> 141 225 2015              Switzerland             NA          NA
#> 142 225 2016              Switzerland             NA          NA
#> 143 225 2017              Switzerland             NA          NA
#> 144 225 2018              Switzerland             NA          NA
#> 145 230 2015                    Spain             NA          NA
#> 146 230 2016                    Spain             NA          NA
#> 147 230 2017                    Spain             NA          NA
#> 148 230 2018                    Spain             NA          NA
#> 149 235 2015                 Portugal             NA          NA
#> 150 235 2016                 Portugal             NA          NA
#> 151 235 2017                 Portugal             NA          NA
#> 152 235 2018                 Portugal             NA          NA
#> 153 255 2015                  Germany             NA          NA
#> 154 255 2016                  Germany             NA          NA
#> 155 255 2017                  Germany             NA          NA
#> 156 255 2018                  Germany             NA          NA
#> 157 290 2015                   Poland             NA          NA
#> 158 290 2016                   Poland             NA          NA
#> 159 290 2017                   Poland             NA          NA
#> 160 290 2018                   Poland             NA          NA
#> 161 305 2015                  Austria             NA          NA
#> 162 305 2016                  Austria             NA          NA
#> 163 305 2017                  Austria             NA          NA
#> 164 305 2018                  Austria             NA          NA
#> 165 310 2015                  Hungary             NA          NA
#> 166 310 2016                  Hungary             NA          NA
#> 167 310 2017                  Hungary             NA          NA
#> 168 310 2018                  Hungary             NA          NA
#> 169 316 2015                  Czechia             NA          NA
#> 170 316 2016                  Czechia             NA          NA
#> 171 316 2017                  Czechia             NA          NA
#> 172 316 2018                  Czechia             NA          NA
#> 173 317 2015                 Slovakia             NA          NA
#> 174 317 2016                 Slovakia             NA          NA
#> 175 317 2017                 Slovakia             NA          NA
#> 176 317 2018                 Slovakia             NA          NA
#> 177 325 2015                    Italy             NA          NA
#> 178 325 2016                    Italy             NA          NA
#> 179 325 2017                    Italy             NA          NA
#> 180 325 2018                    Italy             NA          NA
#> 181 338 2015                    Malta             NA          NA
#> 182 338 2016                    Malta             NA          NA
#> 183 338 2017                    Malta             NA          NA
#> 184 338 2018                    Malta             NA          NA
#> 185 339 2015                  Albania             NA          NA
#> 186 339 2016                  Albania             NA          NA
#> 187 339 2017                  Albania             NA          NA
#> 188 339 2018                  Albania             NA          NA
#> 189 341 2015               Montenegro             NA          NA
#> 190 341 2016               Montenegro             NA          NA
#> 191 341 2017               Montenegro             NA          NA
#> 192 341 2018               Montenegro             NA          NA
#> 193 343 2015          North Macedonia             NA          NA
#> 194 343 2016          North Macedonia             NA          NA
#> 195 343 2017          North Macedonia             NA          NA
#> 196 343 2018          North Macedonia             NA          NA
#> 197 344 2015                  Croatia             NA          NA
#> 198 344 2016                  Croatia             NA          NA
#> 199 344 2017                  Croatia             NA          NA
#> 200 344 2018                  Croatia             NA          NA
#> 201 345 2015                   Serbia             NA          NA
#> 202 345 2016                   Serbia             NA          NA
#> 203 345 2017                   Serbia             NA          NA
#> 204 345 2018                   Serbia             NA          NA
#> 205 346 2015     Bosnia & Herzegovina             NA          NA
#> 206 346 2016     Bosnia & Herzegovina             NA          NA
#> 207 346 2017     Bosnia & Herzegovina             NA          NA
#> 208 346 2018     Bosnia & Herzegovina             NA          NA
#> 209 349 2015                 Slovenia             NA          NA
#> 210 349 2016                 Slovenia             NA          NA
#> 211 349 2017                 Slovenia             NA          NA
#> 212 349 2018                 Slovenia             NA          NA
#> 213 350 2015                   Greece             NA          NA
#> 214 350 2016                   Greece             NA          NA
#> 215 350 2017                   Greece             NA          NA
#> 216 350 2018                   Greece             NA          NA
#> 217 352 2015                   Cyprus             NA          NA
#> 218 352 2016                   Cyprus             NA          NA
#> 219 352 2017                   Cyprus             NA          NA
#> 220 352 2018                   Cyprus             NA          NA
#> 221 355 2015                 Bulgaria             NA          NA
#> 222 355 2016                 Bulgaria             NA          NA
#> 223 355 2017                 Bulgaria             NA          NA
#> 224 355 2018                 Bulgaria             NA          NA
#> 225 359 2015                  Moldova             NA          NA
#> 226 359 2016                  Moldova             NA          NA
#> 227 359 2017                  Moldova             NA          NA
#> 228 359 2018                  Moldova             NA          NA
#> 229 360 2015                  Romania             NA          NA
#> 230 360 2016                  Romania             NA          NA
#> 231 360 2017                  Romania             NA          NA
#> 232 360 2018                  Romania             NA          NA
#> 233 365 2015                   Russia             NA          NA
#> 234 365 2016                   Russia             NA          NA
#> 235 365 2017                   Russia             NA          NA
#> 236 365 2018                   Russia             NA          NA
#> 237 366 2015                  Estonia             NA          NA
#> 238 366 2016                  Estonia             NA          NA
#> 239 366 2017                  Estonia             NA          NA
#> 240 366 2018                  Estonia             NA          NA
#> 241 367 2015                   Latvia             NA          NA
#> 242 367 2016                   Latvia             NA          NA
#> 243 367 2017                   Latvia             NA          NA
#> 244 367 2018                   Latvia             NA          NA
#> 245 368 2015                Lithuania             NA          NA
#> 246 368 2016                Lithuania             NA          NA
#> 247 368 2017                Lithuania             NA          NA
#> 248 368 2018                Lithuania             NA          NA
#> 249 369 2015                  Ukraine             NA          NA
#> 250 369 2016                  Ukraine             NA          NA
#> 251 369 2017                  Ukraine             NA          NA
#> 252 369 2018                  Ukraine             NA          NA
#> 253 370 2015                  Belarus             NA          NA
#> 254 370 2016                  Belarus             NA          NA
#> 255 370 2017                  Belarus             NA          NA
#> 256 370 2018                  Belarus             NA          NA
#> 257 371 2015                  Armenia             NA          NA
#> 258 371 2016                  Armenia             NA          NA
#> 259 371 2017                  Armenia             NA          NA
#> 260 371 2018                  Armenia             NA          NA
#> 261 372 2015                  Georgia             NA          NA
#> 262 372 2016                  Georgia             NA          NA
#> 263 372 2017                  Georgia             NA          NA
#> 264 372 2018                  Georgia             NA          NA
#> 265 373 2015               Azerbaijan             NA          NA
#> 266 373 2016               Azerbaijan             NA          NA
#> 267 373 2017               Azerbaijan             NA          NA
#> 268 373 2018               Azerbaijan             NA          NA
#> 269 375 2015                  Finland             NA          NA
#> 270 375 2016                  Finland             NA          NA
#> 271 375 2017                  Finland             NA          NA
#> 272 375 2018                  Finland             NA          NA
#> 273 380 2015                   Sweden             NA          NA
#> 274 380 2016                   Sweden             NA          NA
#> 275 380 2017                   Sweden             NA          NA
#> 276 380 2018                   Sweden             NA          NA
#> 277 385 2015                   Norway             NA          NA
#> 278 385 2016                   Norway             NA          NA
#> 279 385 2017                   Norway             NA          NA
#> 280 385 2018                   Norway             NA          NA
#> 281 390 2015                  Denmark             NA          NA
#> 282 390 2016                  Denmark             NA          NA
#> 283 390 2017                  Denmark             NA          NA
#> 284 390 2018                  Denmark             NA          NA
#> 285 395 2015                  Iceland             NA          NA
#> 286 395 2016                  Iceland             NA          NA
#> 287 395 2017                  Iceland             NA          NA
#> 288 395 2018                  Iceland             NA          NA
#> 289 402 2015               Cape Verde             NA          NA
#> 290 402 2016               Cape Verde             NA          NA
#> 291 402 2017               Cape Verde             NA          NA
#> 292 402 2018               Cape Verde             NA          NA
#> 293 404 2015            Guinea-Bissau             NA          NA
#> 294 404 2016            Guinea-Bissau             NA          NA
#> 295 404 2017            Guinea-Bissau             NA          NA
#> 296 404 2018            Guinea-Bissau             NA          NA
#> 297 411 2015        Equatorial Guinea             NA          NA
#> 298 411 2016        Equatorial Guinea             NA          NA
#> 299 411 2017        Equatorial Guinea             NA          NA
#> 300 411 2018        Equatorial Guinea             NA          NA
#> 301 420 2015                   Gambia             NA          NA
#> 302 420 2016                   Gambia             NA          NA
#> 303 420 2017                   Gambia             NA          NA
#> 304 420 2018                   Gambia             NA          NA
#> 305 432 2015                     Mali              2           1
#> 306 432 2016                     Mali             NA          NA
#> 307 432 2017                     Mali             NA          NA
#> 308 432 2018                     Mali              1           1
#> 309 433 2015                  Senegal             NA          NA
#> 310 433 2016                  Senegal             NA          NA
#> 311 433 2017                  Senegal             NA          NA
#> 312 433 2018                  Senegal             NA          NA
#> 313 434 2015                    Benin             NA          NA
#> 314 434 2016                    Benin             NA          NA
#> 315 434 2017                    Benin             NA          NA
#> 316 434 2018                    Benin             NA          NA
#> 317 435 2015               Mauritania             NA          NA
#> 318 435 2016               Mauritania             NA          NA
#> 319 435 2017               Mauritania             NA          NA
#> 320 435 2018               Mauritania             NA          NA
#> 321 436 2015                    Niger             NA          NA
#> 322 436 2016                    Niger             NA          NA
#> 323 436 2017                    Niger             NA          NA
#> 324 436 2018                    Niger             NA          NA
#> 325 437 2015            Côte d’Ivoire             NA          NA
#> 326 437 2016            Côte d’Ivoire             NA          NA
#> 327 437 2017            Côte d’Ivoire             NA          NA
#> 328 437 2018            Côte d’Ivoire             NA          NA
#> 329 438 2015                   Guinea             NA          NA
#> 330 438 2016                   Guinea             NA          NA
#> 331 438 2017                   Guinea             NA          NA
#> 332 438 2018                   Guinea             NA          NA
#> 333 439 2015             Burkina Faso             NA          NA
#> 334 439 2016             Burkina Faso             NA          NA
#> 335 439 2017             Burkina Faso             NA          NA
#> 336 439 2018             Burkina Faso             NA          NA
#> 337 450 2015                  Liberia             NA          NA
#> 338 450 2016                  Liberia             NA          NA
#> 339 450 2017                  Liberia             NA          NA
#> 340 450 2018                  Liberia             NA          NA
#> 341 451 2015             Sierra Leone             NA          NA
#> 342 451 2016             Sierra Leone             NA          NA
#> 343 451 2017             Sierra Leone             NA          NA
#> 344 451 2018             Sierra Leone             NA          NA
#> 345 452 2015                    Ghana             NA          NA
#> 346 452 2016                    Ghana             NA          NA
#> 347 452 2017                    Ghana             NA          NA
#> 348 452 2018                    Ghana             NA          NA
#> 349 461 2015                     Togo             NA          NA
#> 350 461 2016                     Togo             NA          NA
#> 351 461 2017                     Togo             NA          NA
#> 352 461 2018                     Togo             NA          NA
#> 353 471 2015                 Cameroon             NA          NA
#> 354 471 2016                 Cameroon             NA          NA
#> 355 471 2017                 Cameroon             NA          NA
#> 356 471 2018                 Cameroon             NA          NA
#> 357 475 2015                  Nigeria             NA          NA
#> 358 475 2016                  Nigeria              1           1
#> 359 475 2017                  Nigeria              1           1
#> 360 475 2018                  Nigeria             NA          NA
#> 361 481 2015                    Gabon             NA          NA
#> 362 481 2016                    Gabon             NA          NA
#> 363 481 2017                    Gabon             NA          NA
#> 364 481 2018                    Gabon             NA          NA
#> 365 482 2015 Central African Republic             NA          NA
#> 366 482 2016 Central African Republic             NA          NA
#> 367 482 2017 Central African Republic             NA          NA
#> 368 482 2018 Central African Republic             NA          NA
#> 369 483 2015                     Chad             NA          NA
#> 370 483 2016                     Chad             NA          NA
#> 371 483 2017                     Chad             NA          NA
#> 372 483 2018                     Chad             NA          NA
#> 373 484 2015      Congo - Brazzaville             NA          NA
#> 374 484 2016      Congo - Brazzaville             NA          NA
#> 375 484 2017      Congo - Brazzaville             NA          NA
#> 376 484 2018      Congo - Brazzaville             NA          NA
#> 377 490 2015         Congo - Kinshasa             NA          NA
#> 378 490 2016         Congo - Kinshasa             NA          NA
#> 379 490 2017         Congo - Kinshasa             NA          NA
#> 380 490 2018         Congo - Kinshasa             NA          NA
#> 381 500 2015                   Uganda             NA          NA
#> 382 500 2016                   Uganda             NA          NA
#> 383 500 2017                   Uganda             NA          NA
#> 384 500 2018                   Uganda             NA          NA
#> 385 501 2015                    Kenya             NA          NA
#> 386 501 2016                    Kenya             NA          NA
#> 387 501 2017                    Kenya             NA          NA
#> 388 501 2018                    Kenya             NA          NA
#> 389 510 2015                 Tanzania             NA          NA
#> 390 510 2016                 Tanzania             NA          NA
#> 391 510 2017                 Tanzania             NA          NA
#> 392 510 2018                 Tanzania             NA          NA
#> 393 516 2015                  Burundi             NA          NA
#> 394 516 2016                  Burundi             NA          NA
#> 395 516 2017                  Burundi             NA          NA
#> 396 516 2018                  Burundi             NA          NA
#> 397 517 2015                   Rwanda             NA          NA
#> 398 517 2016                   Rwanda             NA          NA
#> 399 517 2017                   Rwanda             NA          NA
#> 400 517 2018                   Rwanda             NA          NA
#> 401 520 2015                  Somalia             NA          NA
#> 402 520 2016                  Somalia             NA          NA
#> 403 520 2017                  Somalia             NA          NA
#> 404 520 2018                  Somalia             NA          NA
#> 405 522 2015                 Djibouti             NA          NA
#> 406 522 2016                 Djibouti             NA          NA
#> 407 522 2017                 Djibouti             NA          NA
#> 408 522 2018                 Djibouti             NA          NA
#> 409 530 2015                 Ethiopia             NA          NA
#> 410 530 2016                 Ethiopia             NA          NA
#> 411 530 2017                 Ethiopia             NA          NA
#> 412 530 2018                 Ethiopia             NA          NA
#> 413 531 2015                  Eritrea             NA          NA
#> 414 531 2016                  Eritrea             NA          NA
#> 415 531 2017                  Eritrea             NA          NA
#> 416 531 2018                  Eritrea             NA          NA
#> 417 540 2015                   Angola             NA          NA
#> 418 540 2016                   Angola             NA          NA
#> 419 540 2017                   Angola             NA          NA
#> 420 540 2018                   Angola             NA          NA
#> 421 541 2015               Mozambique             NA          NA
#> 422 541 2016               Mozambique             NA          NA
#> 423 541 2017               Mozambique             NA          NA
#> 424 541 2018               Mozambique             NA          NA
#> 425 551 2015                   Zambia             NA          NA
#> 426 551 2016                   Zambia             NA          NA
#> 427 551 2017                   Zambia             NA          NA
#> 428 551 2018                   Zambia             NA          NA
#> 429 552 2015                 Zimbabwe             NA          NA
#> 430 552 2016                 Zimbabwe             NA          NA
#> 431 552 2017                 Zimbabwe             NA          NA
#> 432 552 2018                 Zimbabwe             NA          NA
#> 433 553 2015                   Malawi             NA          NA
#> 434 553 2016                   Malawi             NA          NA
#> 435 553 2017                   Malawi             NA          NA
#> 436 553 2018                   Malawi             NA          NA
#> 437 560 2015             South Africa             NA          NA
#> 438 560 2016             South Africa             NA          NA
#> 439 560 2017             South Africa             NA          NA
#> 440 560 2018             South Africa             NA          NA
#> 441 565 2015                  Namibia             NA          NA
#> 442 565 2016                  Namibia             NA          NA
#> 443 565 2017                  Namibia             NA          NA
#> 444 565 2018                  Namibia             NA          NA
#> 445 570 2015                  Lesotho             NA          NA
#> 446 570 2016                  Lesotho             NA          NA
#> 447 570 2017                  Lesotho             NA          NA
#> 448 570 2018                  Lesotho             NA          NA
#> 449 571 2015                 Botswana             NA          NA
#> 450 571 2016                 Botswana             NA          NA
#> 451 571 2017                 Botswana             NA          NA
#> 452 571 2018                 Botswana             NA          NA
#> 453 572 2015                 Eswatini             NA          NA
#> 454 572 2016                 Eswatini             NA          NA
#> 455 572 2017                 Eswatini             NA          NA
#> 456 572 2018                 Eswatini             NA          NA
#> 457 580 2015               Madagascar             NA          NA
#> 458 580 2016               Madagascar             NA          NA
#> 459 580 2017               Madagascar             NA          NA
#> 460 580 2018               Madagascar             NA          NA
#> 461 581 2015                  Comoros             NA          NA
#> 462 581 2016                  Comoros             NA          NA
#> 463 581 2017                  Comoros             NA          NA
#> 464 581 2018                  Comoros             NA          NA
#> 465 590 2015                Mauritius             NA          NA
#> 466 590 2016                Mauritius             NA          NA
#> 467 590 2017                Mauritius             NA          NA
#> 468 590 2018                Mauritius             NA          NA
#> 469 600 2015                  Morocco             NA          NA
#> 470 600 2016                  Morocco             NA          NA
#> 471 600 2017                  Morocco             NA          NA
#> 472 600 2018                  Morocco             NA          NA
#> 473 615 2015                  Algeria             NA          NA
#> 474 615 2016                  Algeria             NA          NA
#> 475 615 2017                  Algeria             NA          NA
#> 476 615 2018                  Algeria             NA          NA
#> 477 616 2015                  Tunisia             NA          NA
#> 478 616 2016                  Tunisia             NA          NA
#> 479 616 2017                  Tunisia             NA          NA
#> 480 616 2018                  Tunisia             NA          NA
#> 481 620 2015                    Libya             NA          NA
#> 482 620 2016                    Libya             NA          NA
#> 483 620 2017                    Libya             NA          NA
#> 484 620 2018                    Libya             NA          NA
#> 485 625 2015                    Sudan             NA          NA
#> 486 625 2016                    Sudan             NA          NA
#> 487 625 2017                    Sudan             NA          NA
#> 488 625 2018                    Sudan             NA          NA
#> 489 626 2015              South Sudan             NA          NA
#> 490 626 2016              South Sudan             NA          NA
#> 491 626 2017              South Sudan             NA          NA
#> 492 626 2018              South Sudan             NA          NA
#> 493 630 2015                     Iran             NA          NA
#> 494 630 2016                     Iran             NA          NA
#> 495 630 2017                     Iran             NA          NA
#> 496 630 2018                     Iran             NA          NA
#> 497 640 2015                   Turkey             NA          NA
#> 498 640 2016                   Turkey             NA          NA
#> 499 640 2017                   Turkey             NA          NA
#> 500 640 2018                   Turkey             NA          NA
#> 501 645 2015                     Iraq             NA          NA
#> 502 645 2016                     Iraq             NA          NA
#> 503 645 2017                     Iraq             NA          NA
#> 504 645 2018                     Iraq             NA          NA
#> 505 651 2015                    Egypt             NA          NA
#> 506 651 2016                    Egypt             NA          NA
#> 507 651 2017                    Egypt             NA          NA
#> 508 651 2018                    Egypt             NA          NA
#> 509 652 2015                    Syria             NA          NA
#> 510 652 2016                    Syria             NA          NA
#> 511 652 2017                    Syria             NA          NA
#> 512 652 2018                    Syria             NA          NA
#> 513 660 2015                  Lebanon             NA          NA
#> 514 660 2016                  Lebanon             NA          NA
#> 515 660 2017                  Lebanon             NA          NA
#> 516 660 2018                  Lebanon             NA          NA
#> 517 663 2015                   Jordan             NA          NA
#> 518 663 2016                   Jordan             NA          NA
#> 519 663 2017                   Jordan             NA          NA
#> 520 663 2018                   Jordan             NA          NA
#> 521 666 2015                   Israel             NA          NA
#> 522 666 2016                   Israel             NA          NA
#> 523 666 2017                   Israel             NA          NA
#> 524 666 2018                   Israel             NA          NA
#> 525 670 2015             Saudi Arabia             NA          NA
#> 526 670 2016             Saudi Arabia             NA          NA
#> 527 670 2017             Saudi Arabia             NA          NA
#> 528 670 2018             Saudi Arabia             NA          NA
#> 529 679 2015                    Yemen             NA          NA
#> 530 679 2016                    Yemen             NA          NA
#> 531 679 2017                    Yemen             NA          NA
#> 532 679 2018                    Yemen             NA          NA
#> 533 690 2015                   Kuwait             NA          NA
#> 534 690 2016                   Kuwait             NA          NA
#> 535 690 2017                   Kuwait             NA          NA
#> 536 690 2018                   Kuwait             NA          NA
#> 537 692 2015                  Bahrain             NA          NA
#> 538 692 2016                  Bahrain             NA          NA
#> 539 692 2017                  Bahrain             NA          NA
#> 540 692 2018                  Bahrain             NA          NA
#> 541 694 2015                    Qatar             NA          NA
#> 542 694 2016                    Qatar             NA          NA
#> 543 694 2017                    Qatar             NA          NA
#> 544 694 2018                    Qatar             NA          NA
#> 545 696 2015     United Arab Emirates             NA          NA
#> 546 696 2016     United Arab Emirates             NA          NA
#> 547 696 2017     United Arab Emirates             NA          NA
#> 548 696 2018     United Arab Emirates             NA          NA
#> 549 698 2015                     Oman             NA          NA
#> 550 698 2016                     Oman             NA          NA
#> 551 698 2017                     Oman             NA          NA
#> 552 698 2018                     Oman             NA          NA
#> 553 700 2015              Afghanistan             NA          NA
#> 554 700 2016              Afghanistan             NA          NA
#> 555 700 2017              Afghanistan             NA          NA
#> 556 700 2018              Afghanistan             NA          NA
#> 557 701 2015             Turkmenistan             NA          NA
#> 558 701 2016             Turkmenistan             NA          NA
#> 559 701 2017             Turkmenistan             NA          NA
#> 560 701 2018             Turkmenistan             NA          NA
#> 561 702 2015               Tajikistan             NA          NA
#> 562 702 2016               Tajikistan             NA          NA
#> 563 702 2017               Tajikistan             NA          NA
#> 564 702 2018               Tajikistan             NA          NA
#> 565 703 2015               Kyrgyzstan             NA          NA
#> 566 703 2016               Kyrgyzstan             NA          NA
#> 567 703 2017               Kyrgyzstan             NA          NA
#> 568 703 2018               Kyrgyzstan             NA          NA
#> 569 704 2015               Uzbekistan             NA          NA
#> 570 704 2016               Uzbekistan             NA          NA
#> 571 704 2017               Uzbekistan             NA          NA
#> 572 704 2018               Uzbekistan             NA          NA
#> 573 705 2015               Kazakhstan             NA          NA
#> 574 705 2016               Kazakhstan             NA          NA
#> 575 705 2017               Kazakhstan             NA          NA
#> 576 705 2018               Kazakhstan             NA          NA
#> 577 710 2015                    China             NA          NA
#> 578 710 2016                    China             NA          NA
#> 579 710 2017                    China             NA          NA
#> 580 710 2018                    China             NA          NA
#> 581 712 2015                 Mongolia             NA          NA
#> 582 712 2016                 Mongolia             NA          NA
#> 583 712 2017                 Mongolia             NA          NA
#> 584 712 2018                 Mongolia             NA          NA
#> 585 731 2015              North Korea             NA          NA
#> 586 731 2016              North Korea             NA          NA
#> 587 731 2017              North Korea             NA          NA
#> 588 731 2018              North Korea             NA          NA
#> 589 732 2015              South Korea             NA          NA
#> 590 732 2016              South Korea             NA          NA
#> 591 732 2017              South Korea             NA          NA
#> 592 732 2018              South Korea             NA          NA
#> 593 740 2015                    Japan             NA          NA
#> 594 740 2016                    Japan             NA          NA
#> 595 740 2017                    Japan             NA          NA
#> 596 740 2018                    Japan             NA          NA
#> 597 750 2015                    India             NA          NA
#> 598 750 2016                    India             NA          NA
#> 599 750 2017                    India             NA          NA
#> 600 750 2018                    India             NA          NA
#> 601 760 2015                   Bhutan             NA          NA
#> 602 760 2016                   Bhutan             NA          NA
#> 603 760 2017                   Bhutan             NA          NA
#> 604 760 2018                   Bhutan             NA          NA
#> 605 770 2015                 Pakistan             NA          NA
#> 606 770 2016                 Pakistan             NA          NA
#> 607 770 2017                 Pakistan             NA          NA
#> 608 770 2018                 Pakistan             NA          NA
#> 609 771 2015               Bangladesh             NA          NA
#> 610 771 2016               Bangladesh             NA          NA
#> 611 771 2017               Bangladesh             NA          NA
#> 612 771 2018               Bangladesh             NA          NA
#> 613 775 2015          Myanmar (Burma)             NA          NA
#> 614 775 2016          Myanmar (Burma)             NA          NA
#> 615 775 2017          Myanmar (Burma)             NA          NA
#> 616 775 2018          Myanmar (Burma)             NA          NA
#> 617 780 2015                Sri Lanka             NA          NA
#> 618 780 2016                Sri Lanka             NA          NA
#> 619 780 2017                Sri Lanka             NA          NA
#> 620 780 2018                Sri Lanka             NA          NA
#> 621 781 2015                 Maldives             NA          NA
#> 622 781 2016                 Maldives             NA          NA
#> 623 781 2017                 Maldives             NA          NA
#> 624 781 2018                 Maldives             NA          NA
#> 625 790 2015                    Nepal             NA          NA
#> 626 790 2016                    Nepal             NA          NA
#> 627 790 2017                    Nepal             NA          NA
#> 628 790 2018                    Nepal             NA          NA
#> 629 800 2015                 Thailand             NA          NA
#> 630 800 2016                 Thailand             NA          NA
#> 631 800 2017                 Thailand             NA          NA
#> 632 800 2018                 Thailand             NA          NA
#> 633 811 2015                 Cambodia             NA          NA
#> 634 811 2016                 Cambodia             NA          NA
#> 635 811 2017                 Cambodia             NA          NA
#> 636 811 2018                 Cambodia             NA          NA
#> 637 812 2015                     Laos             NA          NA
#> 638 812 2016                     Laos             NA          NA
#> 639 812 2017                     Laos             NA          NA
#> 640 812 2018                     Laos             NA          NA
#> 641 816 2015                  Vietnam             NA          NA
#> 642 816 2016                  Vietnam             NA          NA
#> 643 816 2017                  Vietnam             NA          NA
#> 644 816 2018                  Vietnam             NA          NA
#> 645 820 2015                 Malaysia             NA          NA
#> 646 820 2016                 Malaysia             NA          NA
#> 647 820 2017                 Malaysia             NA          NA
#> 648 820 2018                 Malaysia             NA          NA
#> 649 830 2015                Singapore             NA          NA
#> 650 830 2016                Singapore             NA          NA
#> 651 830 2017                Singapore             NA          NA
#> 652 830 2018                Singapore             NA          NA
#> 653 835 2015                   Brunei             NA          NA
#> 654 835 2016                   Brunei             NA          NA
#> 655 835 2017                   Brunei             NA          NA
#> 656 835 2018                   Brunei             NA          NA
#> 657 840 2015              Philippines             NA          NA
#> 658 840 2016              Philippines             NA          NA
#> 659 840 2017              Philippines             NA          NA
#> 660 840 2018              Philippines             NA          NA
#> 661 850 2015                Indonesia             NA          NA
#> 662 850 2016                Indonesia             NA          NA
#> 663 850 2017                Indonesia             NA          NA
#> 664 850 2018                Indonesia             NA          NA
#> 665 860 2015              Timor-Leste             NA          NA
#> 666 860 2016              Timor-Leste             NA          NA
#> 667 860 2017              Timor-Leste             NA          NA
#> 668 860 2018              Timor-Leste             NA          NA
#> 669 900 2015                Australia             NA          NA
#> 670 900 2016                Australia             NA          NA
#> 671 900 2017                Australia             NA          NA
#> 672 900 2018                Australia             NA          NA
#> 673 910 2015         Papua New Guinea             NA          NA
#> 674 910 2016         Papua New Guinea             NA          NA
#> 675 910 2017         Papua New Guinea             NA          NA
#> 676 910 2018         Papua New Guinea             NA          NA
#> 677 920 2015              New Zealand             NA          NA
#> 678 920 2016              New Zealand             NA          NA
#> 679 920 2017              New Zealand             NA          NA
#> 680 920 2018              New Zealand             NA          NA
#> 681 940 2015          Solomon Islands             NA          NA
#> 682 940 2016          Solomon Islands             NA          NA
#> 683 940 2017          Solomon Islands             NA          NA
#> 684 940 2018          Solomon Islands             NA          NA
#> 685 950 2015                     Fiji             NA          NA
#> 686 950 2016                     Fiji             NA          NA
#> 687 950 2017                     Fiji             NA          NA
#> 688 950 2018                     Fiji             NA          NA

# A GDELT-style extract: FIPS country codes, SQLDATE as YYYYMMDD.
gdelt_like <- data.frame(
  Actor1CountryCode = c("NI", "NI", "ML"),
  SQLDATE           = c(20160301L, 20171120L, 20150614L)
)

panel |>
  harmonize_conflict_data(
    data        = gdelt_like,
    country_col = "Actor1CountryCode",
    origin_code = "fips",
    date_col    = "SQLDATE",
    date_format = "%Y%m%d",
    prefix      = "gdelt"
  )
#>     cow year                  country gdelt_n_events gdelt_onset
#> 1     2 2015            United States             NA          NA
#> 2     2 2016            United States             NA          NA
#> 3     2 2017            United States             NA          NA
#> 4     2 2018            United States             NA          NA
#> 5    20 2015                   Canada             NA          NA
#> 6    20 2016                   Canada             NA          NA
#> 7    20 2017                   Canada             NA          NA
#> 8    20 2018                   Canada             NA          NA
#> 9    31 2015                  Bahamas             NA          NA
#> 10   31 2016                  Bahamas             NA          NA
#> 11   31 2017                  Bahamas             NA          NA
#> 12   31 2018                  Bahamas             NA          NA
#> 13   40 2015                     Cuba             NA          NA
#> 14   40 2016                     Cuba             NA          NA
#> 15   40 2017                     Cuba             NA          NA
#> 16   40 2018                     Cuba             NA          NA
#> 17   41 2015                    Haiti             NA          NA
#> 18   41 2016                    Haiti             NA          NA
#> 19   41 2017                    Haiti             NA          NA
#> 20   41 2018                    Haiti             NA          NA
#> 21   42 2015       Dominican Republic             NA          NA
#> 22   42 2016       Dominican Republic             NA          NA
#> 23   42 2017       Dominican Republic             NA          NA
#> 24   42 2018       Dominican Republic             NA          NA
#> 25   51 2015                  Jamaica             NA          NA
#> 26   51 2016                  Jamaica             NA          NA
#> 27   51 2017                  Jamaica             NA          NA
#> 28   51 2018                  Jamaica             NA          NA
#> 29   52 2015        Trinidad & Tobago             NA          NA
#> 30   52 2016        Trinidad & Tobago             NA          NA
#> 31   52 2017        Trinidad & Tobago             NA          NA
#> 32   52 2018        Trinidad & Tobago             NA          NA
#> 33   53 2015                 Barbados             NA          NA
#> 34   53 2016                 Barbados             NA          NA
#> 35   53 2017                 Barbados             NA          NA
#> 36   53 2018                 Barbados             NA          NA
#> 37   70 2015                   Mexico             NA          NA
#> 38   70 2016                   Mexico             NA          NA
#> 39   70 2017                   Mexico             NA          NA
#> 40   70 2018                   Mexico             NA          NA
#> 41   80 2015                   Belize             NA          NA
#> 42   80 2016                   Belize             NA          NA
#> 43   80 2017                   Belize             NA          NA
#> 44   80 2018                   Belize             NA          NA
#> 45   90 2015                Guatemala             NA          NA
#> 46   90 2016                Guatemala             NA          NA
#> 47   90 2017                Guatemala             NA          NA
#> 48   90 2018                Guatemala             NA          NA
#> 49   91 2015                 Honduras             NA          NA
#> 50   91 2016                 Honduras             NA          NA
#> 51   91 2017                 Honduras             NA          NA
#> 52   91 2018                 Honduras             NA          NA
#> 53   92 2015              El Salvador             NA          NA
#> 54   92 2016              El Salvador             NA          NA
#> 55   92 2017              El Salvador             NA          NA
#> 56   92 2018              El Salvador             NA          NA
#> 57   93 2015                Nicaragua             NA          NA
#> 58   93 2016                Nicaragua             NA          NA
#> 59   93 2017                Nicaragua             NA          NA
#> 60   93 2018                Nicaragua             NA          NA
#> 61   94 2015               Costa Rica             NA          NA
#> 62   94 2016               Costa Rica             NA          NA
#> 63   94 2017               Costa Rica             NA          NA
#> 64   94 2018               Costa Rica             NA          NA
#> 65   95 2015                   Panama             NA          NA
#> 66   95 2016                   Panama             NA          NA
#> 67   95 2017                   Panama             NA          NA
#> 68   95 2018                   Panama             NA          NA
#> 69  100 2015                 Colombia             NA          NA
#> 70  100 2016                 Colombia             NA          NA
#> 71  100 2017                 Colombia             NA          NA
#> 72  100 2018                 Colombia             NA          NA
#> 73  101 2015                Venezuela             NA          NA
#> 74  101 2016                Venezuela             NA          NA
#> 75  101 2017                Venezuela             NA          NA
#> 76  101 2018                Venezuela             NA          NA
#> 77  110 2015                   Guyana             NA          NA
#> 78  110 2016                   Guyana             NA          NA
#> 79  110 2017                   Guyana             NA          NA
#> 80  110 2018                   Guyana             NA          NA
#> 81  115 2015                 Suriname             NA          NA
#> 82  115 2016                 Suriname             NA          NA
#> 83  115 2017                 Suriname             NA          NA
#> 84  115 2018                 Suriname             NA          NA
#> 85  130 2015                  Ecuador             NA          NA
#> 86  130 2016                  Ecuador             NA          NA
#> 87  130 2017                  Ecuador             NA          NA
#> 88  130 2018                  Ecuador             NA          NA
#> 89  135 2015                     Peru             NA          NA
#> 90  135 2016                     Peru             NA          NA
#> 91  135 2017                     Peru             NA          NA
#> 92  135 2018                     Peru             NA          NA
#> 93  140 2015                   Brazil             NA          NA
#> 94  140 2016                   Brazil             NA          NA
#> 95  140 2017                   Brazil             NA          NA
#> 96  140 2018                   Brazil             NA          NA
#> 97  145 2015                  Bolivia             NA          NA
#> 98  145 2016                  Bolivia             NA          NA
#> 99  145 2017                  Bolivia             NA          NA
#> 100 145 2018                  Bolivia             NA          NA
#> 101 150 2015                 Paraguay             NA          NA
#> 102 150 2016                 Paraguay             NA          NA
#> 103 150 2017                 Paraguay             NA          NA
#> 104 150 2018                 Paraguay             NA          NA
#> 105 155 2015                    Chile             NA          NA
#> 106 155 2016                    Chile             NA          NA
#> 107 155 2017                    Chile             NA          NA
#> 108 155 2018                    Chile             NA          NA
#> 109 160 2015                Argentina             NA          NA
#> 110 160 2016                Argentina             NA          NA
#> 111 160 2017                Argentina             NA          NA
#> 112 160 2018                Argentina             NA          NA
#> 113 165 2015                  Uruguay             NA          NA
#> 114 165 2016                  Uruguay             NA          NA
#> 115 165 2017                  Uruguay             NA          NA
#> 116 165 2018                  Uruguay             NA          NA
#> 117 200 2015           United Kingdom             NA          NA
#> 118 200 2016           United Kingdom             NA          NA
#> 119 200 2017           United Kingdom             NA          NA
#> 120 200 2018           United Kingdom             NA          NA
#> 121 205 2015                  Ireland             NA          NA
#> 122 205 2016                  Ireland             NA          NA
#> 123 205 2017                  Ireland             NA          NA
#> 124 205 2018                  Ireland             NA          NA
#> 125 210 2015              Netherlands             NA          NA
#> 126 210 2016              Netherlands             NA          NA
#> 127 210 2017              Netherlands             NA          NA
#> 128 210 2018              Netherlands             NA          NA
#> 129 211 2015                  Belgium             NA          NA
#> 130 211 2016                  Belgium             NA          NA
#> 131 211 2017                  Belgium             NA          NA
#> 132 211 2018                  Belgium             NA          NA
#> 133 212 2015               Luxembourg             NA          NA
#> 134 212 2016               Luxembourg             NA          NA
#> 135 212 2017               Luxembourg             NA          NA
#> 136 212 2018               Luxembourg             NA          NA
#> 137 220 2015                   France             NA          NA
#> 138 220 2016                   France             NA          NA
#> 139 220 2017                   France             NA          NA
#> 140 220 2018                   France             NA          NA
#> 141 225 2015              Switzerland             NA          NA
#> 142 225 2016              Switzerland             NA          NA
#> 143 225 2017              Switzerland             NA          NA
#> 144 225 2018              Switzerland             NA          NA
#> 145 230 2015                    Spain             NA          NA
#> 146 230 2016                    Spain             NA          NA
#> 147 230 2017                    Spain             NA          NA
#> 148 230 2018                    Spain             NA          NA
#> 149 235 2015                 Portugal             NA          NA
#> 150 235 2016                 Portugal             NA          NA
#> 151 235 2017                 Portugal             NA          NA
#> 152 235 2018                 Portugal             NA          NA
#> 153 255 2015                  Germany             NA          NA
#> 154 255 2016                  Germany             NA          NA
#> 155 255 2017                  Germany             NA          NA
#> 156 255 2018                  Germany             NA          NA
#> 157 290 2015                   Poland             NA          NA
#> 158 290 2016                   Poland             NA          NA
#> 159 290 2017                   Poland             NA          NA
#> 160 290 2018                   Poland             NA          NA
#> 161 305 2015                  Austria             NA          NA
#> 162 305 2016                  Austria             NA          NA
#> 163 305 2017                  Austria             NA          NA
#> 164 305 2018                  Austria             NA          NA
#> 165 310 2015                  Hungary             NA          NA
#> 166 310 2016                  Hungary             NA          NA
#> 167 310 2017                  Hungary             NA          NA
#> 168 310 2018                  Hungary             NA          NA
#> 169 316 2015                  Czechia             NA          NA
#> 170 316 2016                  Czechia             NA          NA
#> 171 316 2017                  Czechia             NA          NA
#> 172 316 2018                  Czechia             NA          NA
#> 173 317 2015                 Slovakia             NA          NA
#> 174 317 2016                 Slovakia             NA          NA
#> 175 317 2017                 Slovakia             NA          NA
#> 176 317 2018                 Slovakia             NA          NA
#> 177 325 2015                    Italy             NA          NA
#> 178 325 2016                    Italy             NA          NA
#> 179 325 2017                    Italy             NA          NA
#> 180 325 2018                    Italy             NA          NA
#> 181 338 2015                    Malta             NA          NA
#> 182 338 2016                    Malta             NA          NA
#> 183 338 2017                    Malta             NA          NA
#> 184 338 2018                    Malta             NA          NA
#> 185 339 2015                  Albania             NA          NA
#> 186 339 2016                  Albania             NA          NA
#> 187 339 2017                  Albania             NA          NA
#> 188 339 2018                  Albania             NA          NA
#> 189 341 2015               Montenegro             NA          NA
#> 190 341 2016               Montenegro             NA          NA
#> 191 341 2017               Montenegro             NA          NA
#> 192 341 2018               Montenegro             NA          NA
#> 193 343 2015          North Macedonia             NA          NA
#> 194 343 2016          North Macedonia             NA          NA
#> 195 343 2017          North Macedonia             NA          NA
#> 196 343 2018          North Macedonia             NA          NA
#> 197 344 2015                  Croatia             NA          NA
#> 198 344 2016                  Croatia             NA          NA
#> 199 344 2017                  Croatia             NA          NA
#> 200 344 2018                  Croatia             NA          NA
#> 201 345 2015                   Serbia             NA          NA
#> 202 345 2016                   Serbia             NA          NA
#> 203 345 2017                   Serbia             NA          NA
#> 204 345 2018                   Serbia             NA          NA
#> 205 346 2015     Bosnia & Herzegovina             NA          NA
#> 206 346 2016     Bosnia & Herzegovina             NA          NA
#> 207 346 2017     Bosnia & Herzegovina             NA          NA
#> 208 346 2018     Bosnia & Herzegovina             NA          NA
#> 209 349 2015                 Slovenia             NA          NA
#> 210 349 2016                 Slovenia             NA          NA
#> 211 349 2017                 Slovenia             NA          NA
#> 212 349 2018                 Slovenia             NA          NA
#> 213 350 2015                   Greece             NA          NA
#> 214 350 2016                   Greece             NA          NA
#> 215 350 2017                   Greece             NA          NA
#> 216 350 2018                   Greece             NA          NA
#> 217 352 2015                   Cyprus             NA          NA
#> 218 352 2016                   Cyprus             NA          NA
#> 219 352 2017                   Cyprus             NA          NA
#> 220 352 2018                   Cyprus             NA          NA
#> 221 355 2015                 Bulgaria             NA          NA
#> 222 355 2016                 Bulgaria             NA          NA
#> 223 355 2017                 Bulgaria             NA          NA
#> 224 355 2018                 Bulgaria             NA          NA
#> 225 359 2015                  Moldova             NA          NA
#> 226 359 2016                  Moldova             NA          NA
#> 227 359 2017                  Moldova             NA          NA
#> 228 359 2018                  Moldova             NA          NA
#> 229 360 2015                  Romania             NA          NA
#> 230 360 2016                  Romania             NA          NA
#> 231 360 2017                  Romania             NA          NA
#> 232 360 2018                  Romania             NA          NA
#> 233 365 2015                   Russia             NA          NA
#> 234 365 2016                   Russia             NA          NA
#> 235 365 2017                   Russia             NA          NA
#> 236 365 2018                   Russia             NA          NA
#> 237 366 2015                  Estonia             NA          NA
#> 238 366 2016                  Estonia             NA          NA
#> 239 366 2017                  Estonia             NA          NA
#> 240 366 2018                  Estonia             NA          NA
#> 241 367 2015                   Latvia             NA          NA
#> 242 367 2016                   Latvia             NA          NA
#> 243 367 2017                   Latvia             NA          NA
#> 244 367 2018                   Latvia             NA          NA
#> 245 368 2015                Lithuania             NA          NA
#> 246 368 2016                Lithuania             NA          NA
#> 247 368 2017                Lithuania             NA          NA
#> 248 368 2018                Lithuania             NA          NA
#> 249 369 2015                  Ukraine             NA          NA
#> 250 369 2016                  Ukraine             NA          NA
#> 251 369 2017                  Ukraine             NA          NA
#> 252 369 2018                  Ukraine             NA          NA
#> 253 370 2015                  Belarus             NA          NA
#> 254 370 2016                  Belarus             NA          NA
#> 255 370 2017                  Belarus             NA          NA
#> 256 370 2018                  Belarus             NA          NA
#> 257 371 2015                  Armenia             NA          NA
#> 258 371 2016                  Armenia             NA          NA
#> 259 371 2017                  Armenia             NA          NA
#> 260 371 2018                  Armenia             NA          NA
#> 261 372 2015                  Georgia             NA          NA
#> 262 372 2016                  Georgia             NA          NA
#> 263 372 2017                  Georgia             NA          NA
#> 264 372 2018                  Georgia             NA          NA
#> 265 373 2015               Azerbaijan             NA          NA
#> 266 373 2016               Azerbaijan             NA          NA
#> 267 373 2017               Azerbaijan             NA          NA
#> 268 373 2018               Azerbaijan             NA          NA
#> 269 375 2015                  Finland             NA          NA
#> 270 375 2016                  Finland             NA          NA
#> 271 375 2017                  Finland             NA          NA
#> 272 375 2018                  Finland             NA          NA
#> 273 380 2015                   Sweden             NA          NA
#> 274 380 2016                   Sweden             NA          NA
#> 275 380 2017                   Sweden             NA          NA
#> 276 380 2018                   Sweden             NA          NA
#> 277 385 2015                   Norway             NA          NA
#> 278 385 2016                   Norway             NA          NA
#> 279 385 2017                   Norway             NA          NA
#> 280 385 2018                   Norway             NA          NA
#> 281 390 2015                  Denmark             NA          NA
#> 282 390 2016                  Denmark             NA          NA
#> 283 390 2017                  Denmark             NA          NA
#> 284 390 2018                  Denmark             NA          NA
#> 285 395 2015                  Iceland             NA          NA
#> 286 395 2016                  Iceland             NA          NA
#> 287 395 2017                  Iceland             NA          NA
#> 288 395 2018                  Iceland             NA          NA
#> 289 402 2015               Cape Verde             NA          NA
#> 290 402 2016               Cape Verde             NA          NA
#> 291 402 2017               Cape Verde             NA          NA
#> 292 402 2018               Cape Verde             NA          NA
#> 293 404 2015            Guinea-Bissau             NA          NA
#> 294 404 2016            Guinea-Bissau             NA          NA
#> 295 404 2017            Guinea-Bissau             NA          NA
#> 296 404 2018            Guinea-Bissau             NA          NA
#> 297 411 2015        Equatorial Guinea             NA          NA
#> 298 411 2016        Equatorial Guinea             NA          NA
#> 299 411 2017        Equatorial Guinea             NA          NA
#> 300 411 2018        Equatorial Guinea             NA          NA
#> 301 420 2015                   Gambia             NA          NA
#> 302 420 2016                   Gambia             NA          NA
#> 303 420 2017                   Gambia             NA          NA
#> 304 420 2018                   Gambia             NA          NA
#> 305 432 2015                     Mali              1           1
#> 306 432 2016                     Mali             NA          NA
#> 307 432 2017                     Mali             NA          NA
#> 308 432 2018                     Mali             NA          NA
#> 309 433 2015                  Senegal             NA          NA
#> 310 433 2016                  Senegal             NA          NA
#> 311 433 2017                  Senegal             NA          NA
#> 312 433 2018                  Senegal             NA          NA
#> 313 434 2015                    Benin             NA          NA
#> 314 434 2016                    Benin             NA          NA
#> 315 434 2017                    Benin             NA          NA
#> 316 434 2018                    Benin             NA          NA
#> 317 435 2015               Mauritania             NA          NA
#> 318 435 2016               Mauritania             NA          NA
#> 319 435 2017               Mauritania             NA          NA
#> 320 435 2018               Mauritania             NA          NA
#> 321 436 2015                    Niger             NA          NA
#> 322 436 2016                    Niger             NA          NA
#> 323 436 2017                    Niger             NA          NA
#> 324 436 2018                    Niger             NA          NA
#> 325 437 2015            Côte d’Ivoire             NA          NA
#> 326 437 2016            Côte d’Ivoire             NA          NA
#> 327 437 2017            Côte d’Ivoire             NA          NA
#> 328 437 2018            Côte d’Ivoire             NA          NA
#> 329 438 2015                   Guinea             NA          NA
#> 330 438 2016                   Guinea             NA          NA
#> 331 438 2017                   Guinea             NA          NA
#> 332 438 2018                   Guinea             NA          NA
#> 333 439 2015             Burkina Faso             NA          NA
#> 334 439 2016             Burkina Faso             NA          NA
#> 335 439 2017             Burkina Faso             NA          NA
#> 336 439 2018             Burkina Faso             NA          NA
#> 337 450 2015                  Liberia             NA          NA
#> 338 450 2016                  Liberia             NA          NA
#> 339 450 2017                  Liberia             NA          NA
#> 340 450 2018                  Liberia             NA          NA
#> 341 451 2015             Sierra Leone             NA          NA
#> 342 451 2016             Sierra Leone             NA          NA
#> 343 451 2017             Sierra Leone             NA          NA
#> 344 451 2018             Sierra Leone             NA          NA
#> 345 452 2015                    Ghana             NA          NA
#> 346 452 2016                    Ghana             NA          NA
#> 347 452 2017                    Ghana             NA          NA
#> 348 452 2018                    Ghana             NA          NA
#> 349 461 2015                     Togo             NA          NA
#> 350 461 2016                     Togo             NA          NA
#> 351 461 2017                     Togo             NA          NA
#> 352 461 2018                     Togo             NA          NA
#> 353 471 2015                 Cameroon             NA          NA
#> 354 471 2016                 Cameroon             NA          NA
#> 355 471 2017                 Cameroon             NA          NA
#> 356 471 2018                 Cameroon             NA          NA
#> 357 475 2015                  Nigeria             NA          NA
#> 358 475 2016                  Nigeria              1           1
#> 359 475 2017                  Nigeria              1           1
#> 360 475 2018                  Nigeria             NA          NA
#> 361 481 2015                    Gabon             NA          NA
#> 362 481 2016                    Gabon             NA          NA
#> 363 481 2017                    Gabon             NA          NA
#> 364 481 2018                    Gabon             NA          NA
#> 365 482 2015 Central African Republic             NA          NA
#> 366 482 2016 Central African Republic             NA          NA
#> 367 482 2017 Central African Republic             NA          NA
#> 368 482 2018 Central African Republic             NA          NA
#> 369 483 2015                     Chad             NA          NA
#> 370 483 2016                     Chad             NA          NA
#> 371 483 2017                     Chad             NA          NA
#> 372 483 2018                     Chad             NA          NA
#> 373 484 2015      Congo - Brazzaville             NA          NA
#> 374 484 2016      Congo - Brazzaville             NA          NA
#> 375 484 2017      Congo - Brazzaville             NA          NA
#> 376 484 2018      Congo - Brazzaville             NA          NA
#> 377 490 2015         Congo - Kinshasa             NA          NA
#> 378 490 2016         Congo - Kinshasa             NA          NA
#> 379 490 2017         Congo - Kinshasa             NA          NA
#> 380 490 2018         Congo - Kinshasa             NA          NA
#> 381 500 2015                   Uganda             NA          NA
#> 382 500 2016                   Uganda             NA          NA
#> 383 500 2017                   Uganda             NA          NA
#> 384 500 2018                   Uganda             NA          NA
#> 385 501 2015                    Kenya             NA          NA
#> 386 501 2016                    Kenya             NA          NA
#> 387 501 2017                    Kenya             NA          NA
#> 388 501 2018                    Kenya             NA          NA
#> 389 510 2015                 Tanzania             NA          NA
#> 390 510 2016                 Tanzania             NA          NA
#> 391 510 2017                 Tanzania             NA          NA
#> 392 510 2018                 Tanzania             NA          NA
#> 393 516 2015                  Burundi             NA          NA
#> 394 516 2016                  Burundi             NA          NA
#> 395 516 2017                  Burundi             NA          NA
#> 396 516 2018                  Burundi             NA          NA
#> 397 517 2015                   Rwanda             NA          NA
#> 398 517 2016                   Rwanda             NA          NA
#> 399 517 2017                   Rwanda             NA          NA
#> 400 517 2018                   Rwanda             NA          NA
#> 401 520 2015                  Somalia             NA          NA
#> 402 520 2016                  Somalia             NA          NA
#> 403 520 2017                  Somalia             NA          NA
#> 404 520 2018                  Somalia             NA          NA
#> 405 522 2015                 Djibouti             NA          NA
#> 406 522 2016                 Djibouti             NA          NA
#> 407 522 2017                 Djibouti             NA          NA
#> 408 522 2018                 Djibouti             NA          NA
#> 409 530 2015                 Ethiopia             NA          NA
#> 410 530 2016                 Ethiopia             NA          NA
#> 411 530 2017                 Ethiopia             NA          NA
#> 412 530 2018                 Ethiopia             NA          NA
#> 413 531 2015                  Eritrea             NA          NA
#> 414 531 2016                  Eritrea             NA          NA
#> 415 531 2017                  Eritrea             NA          NA
#> 416 531 2018                  Eritrea             NA          NA
#> 417 540 2015                   Angola             NA          NA
#> 418 540 2016                   Angola             NA          NA
#> 419 540 2017                   Angola             NA          NA
#> 420 540 2018                   Angola             NA          NA
#> 421 541 2015               Mozambique             NA          NA
#> 422 541 2016               Mozambique             NA          NA
#> 423 541 2017               Mozambique             NA          NA
#> 424 541 2018               Mozambique             NA          NA
#> 425 551 2015                   Zambia             NA          NA
#> 426 551 2016                   Zambia             NA          NA
#> 427 551 2017                   Zambia             NA          NA
#> 428 551 2018                   Zambia             NA          NA
#> 429 552 2015                 Zimbabwe             NA          NA
#> 430 552 2016                 Zimbabwe             NA          NA
#> 431 552 2017                 Zimbabwe             NA          NA
#> 432 552 2018                 Zimbabwe             NA          NA
#> 433 553 2015                   Malawi             NA          NA
#> 434 553 2016                   Malawi             NA          NA
#> 435 553 2017                   Malawi             NA          NA
#> 436 553 2018                   Malawi             NA          NA
#> 437 560 2015             South Africa             NA          NA
#> 438 560 2016             South Africa             NA          NA
#> 439 560 2017             South Africa             NA          NA
#> 440 560 2018             South Africa             NA          NA
#> 441 565 2015                  Namibia             NA          NA
#> 442 565 2016                  Namibia             NA          NA
#> 443 565 2017                  Namibia             NA          NA
#> 444 565 2018                  Namibia             NA          NA
#> 445 570 2015                  Lesotho             NA          NA
#> 446 570 2016                  Lesotho             NA          NA
#> 447 570 2017                  Lesotho             NA          NA
#> 448 570 2018                  Lesotho             NA          NA
#> 449 571 2015                 Botswana             NA          NA
#> 450 571 2016                 Botswana             NA          NA
#> 451 571 2017                 Botswana             NA          NA
#> 452 571 2018                 Botswana             NA          NA
#> 453 572 2015                 Eswatini             NA          NA
#> 454 572 2016                 Eswatini             NA          NA
#> 455 572 2017                 Eswatini             NA          NA
#> 456 572 2018                 Eswatini             NA          NA
#> 457 580 2015               Madagascar             NA          NA
#> 458 580 2016               Madagascar             NA          NA
#> 459 580 2017               Madagascar             NA          NA
#> 460 580 2018               Madagascar             NA          NA
#> 461 581 2015                  Comoros             NA          NA
#> 462 581 2016                  Comoros             NA          NA
#> 463 581 2017                  Comoros             NA          NA
#> 464 581 2018                  Comoros             NA          NA
#> 465 590 2015                Mauritius             NA          NA
#> 466 590 2016                Mauritius             NA          NA
#> 467 590 2017                Mauritius             NA          NA
#> 468 590 2018                Mauritius             NA          NA
#> 469 600 2015                  Morocco             NA          NA
#> 470 600 2016                  Morocco             NA          NA
#> 471 600 2017                  Morocco             NA          NA
#> 472 600 2018                  Morocco             NA          NA
#> 473 615 2015                  Algeria             NA          NA
#> 474 615 2016                  Algeria             NA          NA
#> 475 615 2017                  Algeria             NA          NA
#> 476 615 2018                  Algeria             NA          NA
#> 477 616 2015                  Tunisia             NA          NA
#> 478 616 2016                  Tunisia             NA          NA
#> 479 616 2017                  Tunisia             NA          NA
#> 480 616 2018                  Tunisia             NA          NA
#> 481 620 2015                    Libya             NA          NA
#> 482 620 2016                    Libya             NA          NA
#> 483 620 2017                    Libya             NA          NA
#> 484 620 2018                    Libya             NA          NA
#> 485 625 2015                    Sudan             NA          NA
#> 486 625 2016                    Sudan             NA          NA
#> 487 625 2017                    Sudan             NA          NA
#> 488 625 2018                    Sudan             NA          NA
#> 489 626 2015              South Sudan             NA          NA
#> 490 626 2016              South Sudan             NA          NA
#> 491 626 2017              South Sudan             NA          NA
#> 492 626 2018              South Sudan             NA          NA
#> 493 630 2015                     Iran             NA          NA
#> 494 630 2016                     Iran             NA          NA
#> 495 630 2017                     Iran             NA          NA
#> 496 630 2018                     Iran             NA          NA
#> 497 640 2015                   Turkey             NA          NA
#> 498 640 2016                   Turkey             NA          NA
#> 499 640 2017                   Turkey             NA          NA
#> 500 640 2018                   Turkey             NA          NA
#> 501 645 2015                     Iraq             NA          NA
#> 502 645 2016                     Iraq             NA          NA
#> 503 645 2017                     Iraq             NA          NA
#> 504 645 2018                     Iraq             NA          NA
#> 505 651 2015                    Egypt             NA          NA
#> 506 651 2016                    Egypt             NA          NA
#> 507 651 2017                    Egypt             NA          NA
#> 508 651 2018                    Egypt             NA          NA
#> 509 652 2015                    Syria             NA          NA
#> 510 652 2016                    Syria             NA          NA
#> 511 652 2017                    Syria             NA          NA
#> 512 652 2018                    Syria             NA          NA
#> 513 660 2015                  Lebanon             NA          NA
#> 514 660 2016                  Lebanon             NA          NA
#> 515 660 2017                  Lebanon             NA          NA
#> 516 660 2018                  Lebanon             NA          NA
#> 517 663 2015                   Jordan             NA          NA
#> 518 663 2016                   Jordan             NA          NA
#> 519 663 2017                   Jordan             NA          NA
#> 520 663 2018                   Jordan             NA          NA
#> 521 666 2015                   Israel             NA          NA
#> 522 666 2016                   Israel             NA          NA
#> 523 666 2017                   Israel             NA          NA
#> 524 666 2018                   Israel             NA          NA
#> 525 670 2015             Saudi Arabia             NA          NA
#> 526 670 2016             Saudi Arabia             NA          NA
#> 527 670 2017             Saudi Arabia             NA          NA
#> 528 670 2018             Saudi Arabia             NA          NA
#> 529 679 2015                    Yemen             NA          NA
#> 530 679 2016                    Yemen             NA          NA
#> 531 679 2017                    Yemen             NA          NA
#> 532 679 2018                    Yemen             NA          NA
#> 533 690 2015                   Kuwait             NA          NA
#> 534 690 2016                   Kuwait             NA          NA
#> 535 690 2017                   Kuwait             NA          NA
#> 536 690 2018                   Kuwait             NA          NA
#> 537 692 2015                  Bahrain             NA          NA
#> 538 692 2016                  Bahrain             NA          NA
#> 539 692 2017                  Bahrain             NA          NA
#> 540 692 2018                  Bahrain             NA          NA
#> 541 694 2015                    Qatar             NA          NA
#> 542 694 2016                    Qatar             NA          NA
#> 543 694 2017                    Qatar             NA          NA
#> 544 694 2018                    Qatar             NA          NA
#> 545 696 2015     United Arab Emirates             NA          NA
#> 546 696 2016     United Arab Emirates             NA          NA
#> 547 696 2017     United Arab Emirates             NA          NA
#> 548 696 2018     United Arab Emirates             NA          NA
#> 549 698 2015                     Oman             NA          NA
#> 550 698 2016                     Oman             NA          NA
#> 551 698 2017                     Oman             NA          NA
#> 552 698 2018                     Oman             NA          NA
#> 553 700 2015              Afghanistan             NA          NA
#> 554 700 2016              Afghanistan             NA          NA
#> 555 700 2017              Afghanistan             NA          NA
#> 556 700 2018              Afghanistan             NA          NA
#> 557 701 2015             Turkmenistan             NA          NA
#> 558 701 2016             Turkmenistan             NA          NA
#> 559 701 2017             Turkmenistan             NA          NA
#> 560 701 2018             Turkmenistan             NA          NA
#> 561 702 2015               Tajikistan             NA          NA
#> 562 702 2016               Tajikistan             NA          NA
#> 563 702 2017               Tajikistan             NA          NA
#> 564 702 2018               Tajikistan             NA          NA
#> 565 703 2015               Kyrgyzstan             NA          NA
#> 566 703 2016               Kyrgyzstan             NA          NA
#> 567 703 2017               Kyrgyzstan             NA          NA
#> 568 703 2018               Kyrgyzstan             NA          NA
#> 569 704 2015               Uzbekistan             NA          NA
#> 570 704 2016               Uzbekistan             NA          NA
#> 571 704 2017               Uzbekistan             NA          NA
#> 572 704 2018               Uzbekistan             NA          NA
#> 573 705 2015               Kazakhstan             NA          NA
#> 574 705 2016               Kazakhstan             NA          NA
#> 575 705 2017               Kazakhstan             NA          NA
#> 576 705 2018               Kazakhstan             NA          NA
#> 577 710 2015                    China             NA          NA
#> 578 710 2016                    China             NA          NA
#> 579 710 2017                    China             NA          NA
#> 580 710 2018                    China             NA          NA
#> 581 712 2015                 Mongolia             NA          NA
#> 582 712 2016                 Mongolia             NA          NA
#> 583 712 2017                 Mongolia             NA          NA
#> 584 712 2018                 Mongolia             NA          NA
#> 585 731 2015              North Korea             NA          NA
#> 586 731 2016              North Korea             NA          NA
#> 587 731 2017              North Korea             NA          NA
#> 588 731 2018              North Korea             NA          NA
#> 589 732 2015              South Korea             NA          NA
#> 590 732 2016              South Korea             NA          NA
#> 591 732 2017              South Korea             NA          NA
#> 592 732 2018              South Korea             NA          NA
#> 593 740 2015                    Japan             NA          NA
#> 594 740 2016                    Japan             NA          NA
#> 595 740 2017                    Japan             NA          NA
#> 596 740 2018                    Japan             NA          NA
#> 597 750 2015                    India             NA          NA
#> 598 750 2016                    India             NA          NA
#> 599 750 2017                    India             NA          NA
#> 600 750 2018                    India             NA          NA
#> 601 760 2015                   Bhutan             NA          NA
#> 602 760 2016                   Bhutan             NA          NA
#> 603 760 2017                   Bhutan             NA          NA
#> 604 760 2018                   Bhutan             NA          NA
#> 605 770 2015                 Pakistan             NA          NA
#> 606 770 2016                 Pakistan             NA          NA
#> 607 770 2017                 Pakistan             NA          NA
#> 608 770 2018                 Pakistan             NA          NA
#> 609 771 2015               Bangladesh             NA          NA
#> 610 771 2016               Bangladesh             NA          NA
#> 611 771 2017               Bangladesh             NA          NA
#> 612 771 2018               Bangladesh             NA          NA
#> 613 775 2015          Myanmar (Burma)             NA          NA
#> 614 775 2016          Myanmar (Burma)             NA          NA
#> 615 775 2017          Myanmar (Burma)             NA          NA
#> 616 775 2018          Myanmar (Burma)             NA          NA
#> 617 780 2015                Sri Lanka             NA          NA
#> 618 780 2016                Sri Lanka             NA          NA
#> 619 780 2017                Sri Lanka             NA          NA
#> 620 780 2018                Sri Lanka             NA          NA
#> 621 781 2015                 Maldives             NA          NA
#> 622 781 2016                 Maldives             NA          NA
#> 623 781 2017                 Maldives             NA          NA
#> 624 781 2018                 Maldives             NA          NA
#> 625 790 2015                    Nepal             NA          NA
#> 626 790 2016                    Nepal             NA          NA
#> 627 790 2017                    Nepal             NA          NA
#> 628 790 2018                    Nepal             NA          NA
#> 629 800 2015                 Thailand             NA          NA
#> 630 800 2016                 Thailand             NA          NA
#> 631 800 2017                 Thailand             NA          NA
#> 632 800 2018                 Thailand             NA          NA
#> 633 811 2015                 Cambodia             NA          NA
#> 634 811 2016                 Cambodia             NA          NA
#> 635 811 2017                 Cambodia             NA          NA
#> 636 811 2018                 Cambodia             NA          NA
#> 637 812 2015                     Laos             NA          NA
#> 638 812 2016                     Laos             NA          NA
#> 639 812 2017                     Laos             NA          NA
#> 640 812 2018                     Laos             NA          NA
#> 641 816 2015                  Vietnam             NA          NA
#> 642 816 2016                  Vietnam             NA          NA
#> 643 816 2017                  Vietnam             NA          NA
#> 644 816 2018                  Vietnam             NA          NA
#> 645 820 2015                 Malaysia             NA          NA
#> 646 820 2016                 Malaysia             NA          NA
#> 647 820 2017                 Malaysia             NA          NA
#> 648 820 2018                 Malaysia             NA          NA
#> 649 830 2015                Singapore             NA          NA
#> 650 830 2016                Singapore             NA          NA
#> 651 830 2017                Singapore             NA          NA
#> 652 830 2018                Singapore             NA          NA
#> 653 835 2015                   Brunei             NA          NA
#> 654 835 2016                   Brunei             NA          NA
#> 655 835 2017                   Brunei             NA          NA
#> 656 835 2018                   Brunei             NA          NA
#> 657 840 2015              Philippines             NA          NA
#> 658 840 2016              Philippines             NA          NA
#> 659 840 2017              Philippines             NA          NA
#> 660 840 2018              Philippines             NA          NA
#> 661 850 2015                Indonesia             NA          NA
#> 662 850 2016                Indonesia             NA          NA
#> 663 850 2017                Indonesia             NA          NA
#> 664 850 2018                Indonesia             NA          NA
#> 665 860 2015              Timor-Leste             NA          NA
#> 666 860 2016              Timor-Leste             NA          NA
#> 667 860 2017              Timor-Leste             NA          NA
#> 668 860 2018              Timor-Leste             NA          NA
#> 669 900 2015                Australia             NA          NA
#> 670 900 2016                Australia             NA          NA
#> 671 900 2017                Australia             NA          NA
#> 672 900 2018                Australia             NA          NA
#> 673 910 2015         Papua New Guinea             NA          NA
#> 674 910 2016         Papua New Guinea             NA          NA
#> 675 910 2017         Papua New Guinea             NA          NA
#> 676 910 2018         Papua New Guinea             NA          NA
#> 677 920 2015              New Zealand             NA          NA
#> 678 920 2016              New Zealand             NA          NA
#> 679 920 2017              New Zealand             NA          NA
#> 680 920 2018              New Zealand             NA          NA
#> 681 940 2015          Solomon Islands             NA          NA
#> 682 940 2016          Solomon Islands             NA          NA
#> 683 940 2017          Solomon Islands             NA          NA
#> 684 940 2018          Solomon Islands             NA          NA
#> 685 950 2015                     Fiji             NA          NA
#> 686 950 2016                     Fiji             NA          NA
#> 687 950 2017                     Fiji             NA          NA
#> 688 950 2018                     Fiji             NA          NA
```
