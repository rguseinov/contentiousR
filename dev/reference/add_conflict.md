# Add conflict or protest data to a state panel

Joins a conflict, protest, or revolutionary episode dataset onto an
existing state panel. The panel's coding system and time unit (year,
month, or day; see
[`build_states_panel()`](https://rguseinov.github.io/contentiousR/dev/reference/build_states_panel.md))
are detected automatically, and the data are aggregated to that unit.

**Event and conflict-year datasets** (`"scad"`, `"ucdp_prio"`,
`"ucdp_vpp"`, `"mm"`, `"mmad"`, `"arc"`, `"navco3.0"`) are already
aggregated to the panel's unit when loaded, so the `aggregate` argument
has no effect for them.

**Campaign and episode datasets** (`"navco1.3"`, `"navco2.1"`,
`"beissinger"`, `"raqed"`, `"mec"`, and `"omg"`) can have multiple rows
per country-period. With `aggregate = TRUE` (the default) these are
collapsed to the panel's unit by taking the maximum of all numeric
columns, and an `n_campaigns` count column is added. Set
`aggregate = FALSE` to keep campaign-level rows (may produce
duplicates). Onset columns mark the period in which an episode started;
for all of these datasets, `<prefix>incidence` and `<prefix>n_active`
also mark every period in which an episode was in progress, from its
start to its end date (see Details).

## Usage

``` r
add_conflict(panel, dataset, aggregate = TRUE, fill_zero = FALSE)
```

## Arguments

- panel:

  A data frame produced by
  [`build_states_panel()`](https://rguseinov.github.io/contentiousR/dev/reference/build_states_panel.md).

- dataset:

  Dataset to load. One of:

  `"navco1.3"`

  :   NAVCO 1.3 campaign onsets (1900-2019).

  `"navco2.1"`

  :   NAVCO 2.1 campaign-years (1945-2013).

  `"beissinger"`

  :   Beissinger revolutionary episode onsets (1900-2014).

  `"raqed"`

  :   RAQED v1.4 revolutionary and quasi-revolutionary episodes
      (2000-2026). Prefix: `raqed_`.

  `"scad"`

  :   SCAD 2018 social conflict events, Africa and Latin America
      (recorded starts 1989-2017). Prefix: `scad_`.

  `"ucdp_prio"`

  :   UCDP/PRIO Armed Conflict Dataset v26.1 (1946-2025). Prefix:
      `ucdp_prio_`.

  `"ucdp_vpp"`

  :   UCDP Violent Political Protest v26.1 (1989-2025). Prefix:
      `ucdp_vpp_`. Requires the `readxl` package.

  `"mm"`

  :   Mass Mobilization Project v4 (1990-2020). Prefix: `mm_`.

  `"mmad"`

  :   Mass Mobilization in Autocracies Database (2003-2022). Prefix:
      `mmad_`.

  `"mec"`

  :   Major Episodes of Contention (1955-2018), with global
      episode-level coverage. Prefix: `mec_`.

  `"omg"`

  :   Opposition Movements and Groups v1, campaign phases (1789-2019).
      `omg_onset` marks a campaign's first phase. Prefix: `omg_`.

  `"arc"`

  :   Anatomy of Resistance Campaigns 2.0 events with participating
      organizations, Africa, Latin America and the Caribbean
      (1990-2018). Prefix: `arc_`.

  `"navco3.0"`

  :   NAVCO 3.0 events on 26 countries (1990-2012): actions by
      anti-government campaigns, states, and others, with tactics,
      goals, and state responses. Prefix: `nvc3.0_`.

- aggregate:

  Logical. If `TRUE` (default), aggregates to the panel's unit before
  joining (relevant for campaign and episode datasets only). If `FALSE`,
  performs a raw left join.

- fill_zero:

  Logical. If `FALSE` (default), periods without a record are `NA`. If
  `TRUE`, event indicators and counts (onset, incidence, and count
  columns) are set to 0 in periods the dataset covers but in which it
  records nothing, and stay `NA` outside its coverage. See Details and
  [`list_datasets()`](https://rguseinov.github.io/contentiousR/dev/reference/list_datasets.md)
  for how coverage is defined.

## Value

The input panel with conflict/protest columns added via left join. With
`fill_zero = FALSE`, unmatched periods remain `NA`; the function does
not assume that an unobserved event indicator is zero.

## Details

**Coverage and `fill_zero`.** A missing record can mean that nothing
happened or that the source does not cover that country and year. With
`fill_zero = TRUE`, a country-year counts as covered by these rules:

- Global datasets (`"navco1.3"`, `"navco2.1"`, `"beissinger"`,
  `"raqed"`, `"mec"`, `"omg"`, `"ucdp_prio"`, `"ucdp_vpp"`): every state
  in the panel, within the dataset's years.

- Regional datasets (`"scad"`, `"arc"`, `"navco3.0"`): the countries
  with at least one record, within the dataset's years.

- `"mm"`: the country-years the source lists, including those it codes
  as having no protest.

- `"mmad"`: MMAD covers autocracies, and the package does not ship its
  list of autocratic country-years; a country counts as covered from the
  first to the last year in which MMAD records an event there. A 0
  inside that span can therefore still be a period the source did not
  code (for example, MMAD has no events in Egypt from July to December
  2012).

Only indicators and counts are filled (columns ending in `_onset`,
`_incidence`, `_episode`, `_n_*`, or `_total`, `n_campaigns`, the UCDP
conflict-type indicators, and NAVCO 3.0 fatalities and injuries).
Maxima, means, and descriptive columns stay `NA` in periods without
records. Coverage is decided by year, so in finer panels every period of
a covered year is covered.

**Active episodes.** `<prefix>incidence` is 1 in every period in which
at least one episode was in progress and `<prefix>n_active` counts them.
An episode is in progress from its start to its end date. Start dates
less precise than the panel's unit drop the episode, as for onsets. An
end date less precise than the unit is taken to be the last day of the
period the source gives: an OMG phase that ended "in 2005" is active
through December 2005. Beissinger episodes end at the start date plus
the source's duration (in days, or in calendar months for month-precise
starts). Episodes the source codes as ongoing run to the end of its
coverage. For `"navco2.1"`, every campaign-year counts as active.

**Dates.** In a country-quarter, country-month, or country-day panel,
each event or episode onset is placed in the period of its start date.
Records whose source date is less precise than the panel's unit (for
example, an OMG phase dated only to a year in a country-month panel) are
dropped with a message. `"navco1.3"`, `"navco2.1"`, `"ucdp_prio"`, and
`"ucdp_vpp"` record only years and are available for country-year panels
only.

## References

Chenoweth, E., & Shay, C. W. (2020). *List of Campaigns in NAVCO 1.3*.
Harvard Dataverse.
[doi:10.7910/DVN/ON9XND](https://doi.org/10.7910/DVN/ON9XND)

Chenoweth, E., & Shay, C. W. (2019). *NAVCO 2.1 Dataset*. Harvard
Dataverse. [doi:10.7910/DVN/MHOXDV](https://doi.org/10.7910/DVN/MHOXDV)

Beissinger, M. (2022). *Revolutionary Episodes Dataset*.

Ustyuzhanin, V., Semichev, D., Grinin, L., & Korotaev, A. (2026). New
possibilities for analysing revolution: Introducing a database of
revolutions of the 21st century. *Russian Sociological Review*, 25(1),
9-61.
[doi:10.17323/1728-192X-2026-1-9-61](https://doi.org/10.17323/1728-192X-2026-1-9-61)

Ustyuzhanin, V., Semichev, D., Grinin, L., & Korotaev, A. (2026).
*Revolutionary and Quasi-revolutionary Episodes Dataset (RAQED)
(2000-2025)*, Version 1.4. HSE University, Centre for Stability and Risk
Analysis. <https://social.hse.ru/mr/rev_bd>

Salehyan, I., Hendrix, C. S., Hamner, J., Case, C., Linebarger, C.,
Stull, E., & Williams, J. (2012). Social conflict in Africa: A new
database. *International Interactions*, 38(4), 503-511.
[doi:10.1080/03050629.2012.697426](https://doi.org/10.1080/03050629.2012.697426)

Gleditsch, N. P., Wallensteen, P., Eriksson, M., Sollenberg, M., &
Strand, H. (2002). Armed conflict 1946-2001: A new dataset. *Journal of
Peace Research*, 39(5), 615-637.
[doi:10.1177/0022343302039005007](https://doi.org/10.1177/0022343302039005007)

Svensson, I., Schaftenaar, S., & Allansson, M. (2022). Violent political
protest: Introducing a new Uppsala Conflict Data Program data set on
organized violence, 1989-2019. *Journal of Conflict Resolution*, 66(9),
1703-1730.

Clark, D. H., & Regan, P. M. (2016). *Mass Mobilization Protest Data*.
Harvard Dataverse.
[doi:10.7910/DVN/HTTWYL](https://doi.org/10.7910/DVN/HTTWYL)

Weidmann, N. B., & Rød, E. G. (2019). *The Internet and Political
Protest in Autocracies*. Oxford University Press.

Chenoweth, E., & Kang, S. (2026). The Major Episodes of Contention (MEC)
Data Project: An introduction. *Journal of Peace Research*, 63(4),
724-734.
[doi:10.1093/jopres/xjaf008](https://doi.org/10.1093/jopres/xjaf008)

Dahl, M., Dahlum, S., Fjelde, H., Gjerløw, H., Knutsen, C. H.,
Strøm-Sedgwick, C., & Wig, T. (2026). Mass mobilization in the modern
era: Introducing the Opposition Movements and Groups (OMG) dataset,
1789-2019. *Comparative Political Studies*, 59(10), 2117-2158.
[doi:10.1177/00104140251369330](https://doi.org/10.1177/00104140251369330)

Vüllers, J., Bakken, I. V., Johansen, T., Dworschak, C., Butcher, C., &
Braithwaite, J. M. (2026). (Un)organized protest: Introducing the
Anatomy of Resistance Campaigns 2.0. *Journal of Peace Research*, 63(3),
484-494.
[doi:10.1093/jopres/xjag013](https://doi.org/10.1093/jopres/xjag013)

Chenoweth, E., Pinckney, J., & Lewis, O. (2018). Days of rage:
Introducing the NAVCO 3.0 dataset. *Journal of Peace Research*, 55(4),
524-534.
[doi:10.1177/0022343318759411](https://doi.org/10.1177/0022343318759411)

## Examples

``` r
# Country-month panel of protest events
monthly <- build_states_panel(2010, 2012, coding_system = "cow", unit = "month") |>
  add_conflict(dataset = "mmad")

# 0 instead of NA where the dataset covers the country but records nothing
monthly <- build_states_panel(2010, 2012, coding_system = "cow", unit = "month") |>
  add_conflict(dataset = "navco3.0", fill_zero = TRUE)

# Episodes in progress, not only their onsets
panel <- build_states_panel(2000, 2020, coding_system = "cow") |>
  add_conflict(dataset = "raqed")
#> Multiple campaigns or episodes per country-year detected in 'raqed'. Aggregating to country-year using max() for numeric columns. Use `aggregate = FALSE` or `conflict_data()` for record-level data.
panel[panel$cow == 652, c("year", "raqed_onset", "raqed_incidence")]
#>      year raqed_onset raqed_incidence
#> 2651 2000          NA              NA
#> 2652 2001          NA              NA
#> 2653 2002          NA              NA
#> 2654 2003          NA              NA
#> 2655 2004          NA              NA
#> 2656 2005          NA              NA
#> 2657 2006          NA              NA
#> 2658 2007          NA              NA
#> 2659 2008          NA              NA
#> 2660 2009          NA              NA
#> 2661 2010          NA              NA
#> 2662 2011           1               1
#> 2663 2012           1               1
#> 2664 2013          NA               1
#> 2665 2014           1               1
#> 2666 2015          NA               1
#> 2667 2016          NA               1
#> 2668 2017          NA               1
#> 2669 2018          NA               1
#> 2670 2019          NA               1
#> 2671 2020          NA               1

panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
  add_conflict(dataset = "navco2.1")
#> Multiple campaigns or episodes per country-year detected in 'navco2.1'. Aggregating to country-year using max() for numeric columns. Use `aggregate = FALSE` or `conflict_data()` for record-level data.

panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
  add_conflict(dataset = "ucdp_prio")

panel <- build_states_panel(2005, 2020, coding_system = "cow") |>
  add_conflict(dataset = "mmad")

# Raw join for legacy datasets — researcher handles aggregation manually
panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
  add_conflict(dataset = "navco1.3", aggregate = FALSE)

# MEC is episode-level; keep individual episodes with aggregate = FALSE
panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
  add_conflict(dataset = "mec", aggregate = FALSE)
```
