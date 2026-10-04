# Add conflict spell (peace-years) durations to a state panel

Computes a BTSCS-style spell/duration counter from a binary conflict
column already present in the panel (typically added by
[`add_conflict()`](https://rguseinov.github.io/contentiousR/reference/add_conflict.md)):
the number of years since the last event for that state, restarting
after each new event. This is the same construct as
[`peacesciencer::add_spells()`](https://rdrr.io/pkg/peacesciencer/man/add_spells.html),
generalized to work with any binary column rather than a fixed set of
bundled column names. Named `add_spell_duration()`, not
[`add_spells()`](https://rdrr.io/pkg/peacesciencer/man/add_spells.html),
to avoid colliding with
[`peacesciencer::add_spells()`](https://rdrr.io/pkg/peacesciencer/man/add_spells.html)
when both packages are attached.

## Usage

``` r
add_spell_duration(panel, event = NULL, ongoing = NULL)
```

## Arguments

- panel:

  A data frame produced by
  [`build_states_panel()`](https://rguseinov.github.io/contentiousR/reference/build_states_panel.md),
  optionally already joined with conflict data via
  [`add_conflict()`](https://rguseinov.github.io/contentiousR/reference/add_conflict.md).

- event:

  Character. Name of the binary (0/1) column to compute spells from. If
  `NULL` (the default), `add_spell_duration()` looks for exactly one
  column in `panel` whose name ends in `_onset`, `_incidence`, or
  `_ongoing`; if zero or more than one match, it errors and asks for an
  explicit `event`.

- ongoing:

  Logical. If `TRUE`, `event` is treated as an "ongoing" series where a
  run of consecutive `1`s is one continuous event (only the first year
  of the run counts as a new failure; the remaining years of that run
  get `NA` in the output, matching
  [`peacesciencer::add_spells()`](https://rdrr.io/pkg/peacesciencer/man/add_spells.html)'s
  convention of excluding within-event years from a spell that measures
  time since the last event). If `FALSE`, every `1` in `event` is
  treated as its own event, appropriate for an already onset-coded
  column. If `NULL` (the default), this is inferred from the column
  name: `TRUE` for `_incidence`/`_ongoing` suffixes, `FALSE` for
  `_onset`.

## Value

The input panel with one additional integer column, named after `event`
with its onset/incidence/ongoing suffix (if any) replaced by `_spell`.
In a fresh spell, the first observed year is `0` and each subsequent
year without a new event increments by one; the event year itself
carries the final count of the spell it closes.

## Details

`event` must not contain `NA`.
[`add_conflict()`](https://rguseinov.github.io/contentiousR/reference/add_conflict.md)'s
output frequently has `NA` for country-years unmatched by the source
(documented behavior: absence from a source is not evidence of zero
events), and a spell count cannot be computed across a gap of unknown
conflict status. Filter or otherwise resolve these `NA`s before calling
`add_spell_duration()`.

## Examples

``` r
panel <- build_states_panel(1990, 2010, coding_system = "gw") |>
  add_conflict(dataset = "ucdp_prio") |>
  tidyr::drop_na(ucdp_prio_onset) |>
  add_spell_duration(event = "ucdp_prio_onset")
```
