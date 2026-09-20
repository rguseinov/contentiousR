# Add conflict or protest data to a state panel

Joins a conflict, protest, or revolutionary episode dataset onto an
existing state panel at the country-year level.

**Country-year datasets** (`"scad"`, `"ucdp_prio"`, `"ucdp_vpp"`,
`"mm"`, `"mmad"`) are already at the country-year level when loaded, so
the `aggregate` argument has no effect for them.

**Campaign and episode datasets** (`"navco1.3"`, `"navco2.1"`,
`"beissinger"`, `"csra"`, `"mec"`) can have multiple rows per
country-year. With `aggregate = TRUE` (the default) these are collapsed
to country-year by taking the maximum of all numeric columns, and an
`n_campaigns` count column is added. Set `aggregate = FALSE` to keep
campaign-level rows (may produce duplicates).

## Usage

``` r
add_conflict(panel, dataset, aggregate = TRUE)
```

## Arguments

- panel:

  A data frame produced by
  [`build_states_panel()`](https://rguseinov.github.io/contentiousR/reference/build_states_panel.md).

- dataset:

  Dataset to load. One of:

  `"navco1.3"`

  :   NAVCO 1.3 campaign onsets (1900-2019).

  `"navco2.1"`

  :   NAVCO 2.1 campaign-years (1945-2013).

  `"beissinger"`

  :   Beissinger revolutionary episode onsets (1900-2014).

  `"csra"`

  :   HSE CSRA revolutionary episodes (2000-2024).

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
      episode-level coverage. Prefix: `mec_`. Requires the `haven`
      package.

- aggregate:

  Logical. If `TRUE` (default), aggregates to country-year before
  joining (relevant for campaign and episode datasets only). If `FALSE`,
  performs a raw left join.

## Value

The input panel with conflict/protest columns added via left join.
Unmatched country-years remain `NA`; the function does not assume that
an unobserved event indicator is zero.

## References

Chenoweth, E., & Shay, C. W. (2020). *List of Campaigns in NAVCO 1.3*.
Harvard Dataverse.
[doi:10.7910/DVN/ON9XND/PTMCCV](https://doi.org/10.7910/DVN/ON9XND/PTMCCV)

Chenoweth, E., & Shay, C. W. (2019). *NAVCO 2.1 Dataset*. Harvard
Dataverse. [doi:10.7910/DVN/MHOXDV](https://doi.org/10.7910/DVN/MHOXDV)

Beissinger, M. (2022). *Revolutionary Episodes Dataset*.

Ustyuzhanin, V., Korotayev, A., & Semichev, D. (2025). *Revolutions
Dataset*. HSE University, Centre for Stability and Risk Analysis.

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
Data Project: An introduction. *Journal of Peace Research*.
[doi:10.1093/jopres/xjaf008](https://doi.org/10.1093/jopres/xjaf008)

## Examples

``` r
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
if (requireNamespace("haven", quietly = TRUE)) {
  panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
    add_conflict(dataset = "mec", aggregate = FALSE)
}
```
