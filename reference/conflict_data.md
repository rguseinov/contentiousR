# Load conflict and mobilisation data

Loads one of ten conflict, protest, or revolutionary episode datasets
bundled with the package. `scad`, `ucdp_prio`, `ucdp_vpp`, `mm`, and
`mmad` are returned at the country-year level; their event- or
conflict-level source rows are aggregated inside this function.

`navco1.3`, `beissinger`, `csra`, and `mec` return campaign or episode
records; `navco2.1` returns campaign-year rows. These sources can
contain multiple rows for one country-year. Use
`add_conflict(aggregate = TRUE)` (the default) to collapse them to
country-year.

## Usage

``` r
conflict_data(
  start_year = 1945,
  end_year = 2013,
  dataset = c("navco1.3", "navco2.1", "beissinger", "csra", "scad", "ucdp_prio",
    "ucdp_vpp", "mm", "mmad", "mec"),
  coding_system = c("cow", "gw")
)
```

## Source

NAVCO 2.1: [doi:10.7910/DVN/MHOXDV](https://doi.org/10.7910/DVN/MHOXDV)
.

Beissinger Revolutionary Episodes:
<https://mbeissinger.scholar.princeton.edu/revolutionary-episodes-dataset>.

HSE Revolutions Dataset: <https://social.hse.ru/en/mr/rev_bd>.

SCAD:
<https://www.strausscenter.org/ccaps-research-areas/social-conflict/database/>.

UCDP: <https://ucdp.uu.se/downloads/replication_data.html>.

MMAD: <https://mmadatabase.org/>.

MEC: Chenoweth and Kang (2026),
[doi:10.1093/jopres/xjaf008](https://doi.org/10.1093/jopres/xjaf008) ;
data release
[doi:10.7910/DVN/JQWQNW](https://doi.org/10.7910/DVN/JQWQNW) .

## Arguments

- start_year:

  First year to include.

- end_year:

  Last year to include.

- dataset:

  Dataset to load. One of:

  `"navco1.3"`

  :   NAVCO 1.3 campaign onsets. Coverage: 1900-2019.

  `"navco2.1"`

  :   NAVCO 2.1 campaign-years. Coverage: 1945-2013.

  `"beissinger"`

  :   Beissinger revolutionary episode onsets. Coverage: 1900-2014.

  `"csra"`

  :   HSE CSRA revolutionary episodes. Coverage: 2000-2024.

  `"scad"`

  :   SCAD 2018 social conflict events, Africa and Latin America.
      Recorded event starts: 1989-2017 (the 1989 event continues into
      the source's 1990 coverage period). Prefix: `scad_`.

  `"ucdp_prio"`

  :   UCDP/PRIO Armed Conflict Dataset v26.1. Coverage: 1946-2025.
      Prefix: `ucdp_prio_`.

  `"ucdp_vpp"`

  :   UCDP Violent Political Protest Dataset v26.1. Coverage: 1989-2025.
      Prefix: `ucdp_vpp_`. Requires the `readxl` package.

  `"mm"`

  :   Mass Mobilization Project v4 (Clark and Regan). Coverage:
      1990-2020. Prefix: `mm_`.

  `"mmad"`

  :   Mass Mobilization in Autocracies Database. Coverage: 2003-2022.
      Prefix: `mmad_`.

  `"mec"`

  :   Major Episodes of Contention. Global coverage: 1955-2018. Episode
      records; prefix: `mec_`. Requires the `haven` package.

- coding_system:

  Country coding system: `"cow"` or `"gw"`. `ucdp_prio` and `ucdp_vpp`
  use GW codes natively; when `coding_system = "cow"` they are converted
  via `countrycode` and countries without a COW equivalent are dropped.

## Value

A data frame. `navco1.3`, `beissinger`, `csra`, and `mec` contain one
row per campaign or episode record; `navco2.1` contains campaign-year
rows. The other datasets contain one row per country-year.

## Details

All outputs use the requested `cow` or `gw` key and `year`.
Dataset-specific columns have a stable source prefix. A missing
country-year row is not created by this loader; after
[`add_conflict()`](https://rguseinov.github.io/contentiousR/reference/add_conflict.md),
an unmatched year is `NA`, not an assumed zero.

SCAD is deduplicated to one row per event before country-year
aggregation. Its UCDP placeholder rows are excluded, and documented
negative codes for unknown death counts are treated as missing.

For UCDP/PRIO, `ucdp_prio_incidence` identifies any active conflict-year
and `ucdp_prio_onset` identifies a new episode using the source's
`start_date2`. The VPP source does not include an episode-start
variable; `ucdp_vpp_incidence` should be preferred. The legacy
`ucdp_vpp_onset` column is retained as an incidence alias for
compatibility.

The Mass Mobilization source mixes exact participant counts with text
such as ranges and inequalities. `mm_participants` is the maximum among
genuinely numeric values; `mm_participants_reported` preserves the
source strings.

MEC is kept at its published episode level. Its source `byear` becomes
`year`, `ccode` becomes `cow`, and all other source columns receive the
`mec_` prefix. `mec_episode` equals one for every returned episode
record. Fourteen left-censored records have an actual `mec_bdate` before
1955 while their source `byear` is 1955. With GW coding, COW 679 (Yemen)
maps to GW 678 and COW 817 (South Vietnam) maps to GW 817; Tonga has no
GW state equivalent and is omitted.

## Examples

``` r
navco <- conflict_data(1990, 2010, dataset = "navco2.1", coding_system = "cow")

scad  <- conflict_data(1995, 2015, dataset = "scad",      coding_system = "cow")

ucdp  <- conflict_data(1990, 2020, dataset = "ucdp_prio", coding_system = "gw")

if (requireNamespace("haven", quietly = TRUE)) {
  mec <- conflict_data(1990, 2010, dataset = "mec", coding_system = "cow")
}
```
