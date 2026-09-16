# Data sources and interpretation

`contentiousR` standardizes country and year keys; it does not make the
underlying research designs interchangeable. Cite each source used in an
analysis and consult its codebook for definitions, scope, and
limitations.

| Argument | Bundled version and coverage | Unit returned | Source |
|----|----|----|----|
| GDP | Gapminder v32 | Country-year | [Gapminder](https://www.gapminder.org/gdp-per-capita/) |
| `"navco1.3"` | NAVCO 1.3, 1900–2019[^1] | Campaign onset | [NAVCO project](https://ash.harvard.edu/programs/nonviolent-and-violent-campaigns-and-outcomes-data-project/) |
| `"navco2.1"` | NAVCO 2.1, 1945–2013 | Campaign-year | [Dataverse](https://doi.org/10.7910/DVN/MHOXDV) |
| `"beissinger"` | Revolutionary Episodes 1.0, 1900–2014[^2] | Episode onset | [Beissinger](https://mbeissinger.scholar.princeton.edu/revolutionary-episodes-dataset) |
| `"csra"` | CSRA 1.1, 2000–2024 | Episode onset | [HSE University](https://social.hse.ru/en/mr/rev_bd) |
| `"scad"` | SCAD 3.3, 1990–2017[^3] | Country-year | [Strauss Center](https://www.strausscenter.org/ccaps-research-areas/social-conflict/database/) |
| `"ucdp_prio"` | UCDP/PRIO 26.1, 1946–2025 | Country-year | [UCDP](https://ucdp.uu.se/downloads/) |
| `"ucdp_vpp"` | UCDP VPP 26.1, 1989–2025 | Country-year | [UCDP](https://ucdp.uu.se/downloads/) |
| `"mm"` | Mass Mobilization v4, 1990–2020 | Country-year | [Project repository](https://github.com/MassMobilization) |
| `"mmad"` | MMAD 5.0, 2003–2022 | Country-year | [MMAD](https://mmadatabase.org/) |
| `"mec"` | Major Episodes of Contention, 1955–2018 | Episode (global) | [Article](https://doi.org/10.1093/jopres/xjaf008) / [data](https://doi.org/10.7910/DVN/JQWQNW) |
| `"archigos"` | Archigos 4.1, 1875–2015 | Country-year | [Archigos](https://ksgleditsch.com/archigos.html) |
| `"reign"` | REIGN, 1921–2021 | Country-year | [REIGN](https://oefdatascience.github.io/REIGN.github.io/) |
| V-Dem | Installed `vdemdata` release | Country-year | [V-Dem](https://v-dem.net/data/the-v-dem-dataset/) |

## Transformations that affect interpretation

SCAD repeats events when they span multiple locations. For country-level
use, `contentiousR` retains one row per positive event ID before
aggregating. Its documented `-99`, `-88`, and `-77` death-count values
are represented as missing rather than as negative deaths.

UCDP/PRIO expands conflicts with multiple location codes before
aggregation. `ucdp_prio_incidence` marks any active conflict in a
country-year, while `ucdp_prio_onset` is one only when `start_date2`
falls in that year. The VPP file has no equivalent episode-start field;
`ucdp_vpp_onset` is retained only as a backwards-compatible alias of
`ucdp_vpp_incidence`.

Mass Mobilization reports participant size through a mixture of exact
numbers, ranges, inequalities, and qualitative strings.
`mm_participants` contains the maximum of exact numeric reports.
`mm_participants_reported` preserves all reported strings so users can
apply a substantively appropriate recoding.

Legacy campaign and episode sources can contain several rows for one
country-year. `add_conflict(aggregate = TRUE)` reports their count and
takes a missing-safe maximum of numeric fields. Use `aggregate = FALSE`
or call
[`conflict_data()`](https://rguseinov.github.io/contentiousR/reference/conflict_data.md)
directly when campaign-level observations are required.

MEC contains 2,734 reformist and maximalist contentious episodes
worldwide. `contentiousR` preserves its episode-level rows and all
published variables, using the source’s `byear` as `year`. Fourteen
left-censored episodes have a `mec_bdate` before 1955 but a source
`byear` of 1955. With `add_conflict(aggregate = TRUE)`, MEC follows the
same explicit aggregation policy as the other campaign and episode
sources; use `aggregate = FALSE` to retain individual episodes.

## `conflict_data()` / `add_conflict()`

Loads one of ten conflict, protest, and revolutionary-episode datasets.
Every loader honors `start_year` and `end_year` and supports both COW
and GW coding.

| Dataset | Source | Coverage | Output level | Prefix |
|----|----|----|----|----|
| `"navco1.3"` | [NAVCO 1.3](https://doi.org/10.7910/DVN/ON9XND) | 1900–2019† | Campaign onset | `nvc1.3_` |
| `"navco2.1"` | [NAVCO 2.1](https://doi.org/10.7910/DVN/MHOXDV) | 1945–2013 | Campaign-year | `nvc2.1_` |
| `"beissinger"` | [Mark Beissinger’s Revolutionary Episodes Dataset](https://mbeissinger.scholar.princeton.edu/revolutionary-episodes-dataset) | 1900–2014† | Episode onset | `beissinger_` |
| `"csra"` | [HSE CSRA Revolutions Dataset v1.1](https://social.hse.ru/en/mr/rev_bd) | 2000–2024 | Episode onset | `csra_` |
| `"scad"` | [Social Conflict Analysis Database 3.3](https://www.strausscenter.org/ccaps-research-areas/social-conflict/database/) | 1990–2017† | Country-year events | `scad_` |
| `"ucdp_prio"` | [UCDP/PRIO Armed Conflict v26.1](https://ucdp.uu.se/downloads/) | 1946–2025 | Country-year incidence and onset | `ucdp_prio_` |
| `"ucdp_vpp"` | [UCDP Violent Political Protest v26.1](https://ucdp.uu.se/downloads/) | 1989–2025 | Country-year incidence | `ucdp_vpp_` |
| `"mm"` | [Mass Mobilization Project v4](https://massmobilization.github.io) | 1990–2020 | Country-year protests | `mm_` |
| `"mmad"` | [Mass Mobilization in Autocracies v5](https://mmadatabase.org) | 2003–2022 | Country-year events | `mmad_` |
| `"mec"` | [Major Episodes of Contention](https://doi.org/10.1093/jopres/xjaf008) | 1955–2018 | Episode (global) | `mec_` |

† The bundled source has a small number of records beginning in 1899.
SCAD’s official coverage is 1990–2017, but one continuing event has a
recorded 1989 start.

The country-year sources (`scad`, `ucdp_prio`, `ucdp_vpp`, `mm`, `mmad`)
are pre-aggregated to country-year inside
[`conflict_data()`](https://rguseinov.github.io/contentiousR/reference/conflict_data.md).
Legacy campaign and episode datasets, including MEC, return one row per
campaign or episode;
[`add_conflict()`](https://rguseinov.github.io/contentiousR/reference/add_conflict.md)
collapses these with a missing-safe maximum by default. Unmatched panel
rows remain `NA`, because absence from a source is not always evidence
of zero events.

For UCDP/PRIO, `ucdp_prio_incidence` marks active conflict-years and
`ucdp_prio_onset` marks the first year of a conflict episode as defined
by the source’s `start_date2`. For VPP, prefer `ucdp_vpp_incidence`;
`ucdp_vpp_onset` remains as a backwards-compatible incidence alias
because the source has no episode-start field.

``` r

# Standalone
navco   <- conflict_data(1990, 2015, dataset = "navco2.1",  coding_system = "cow")
scad    <- conflict_data(1995, 2015, dataset = "scad",      coding_system = "cow")
ucdp    <- conflict_data(1990, 2020, dataset = "ucdp_prio", coding_system = "gw")
mm_data <- conflict_data(1995, 2015, dataset = "mm",        coding_system = "cow")
mmad    <- conflict_data(2005, 2020, dataset = "mmad",      coding_system = "cow")
mec     <- conflict_data(1955, 2018, dataset = "mec",       coding_system = "cow")

# Pipeline — all datasets work with add_conflict()
panel |> add_conflict(dataset = "navco2.1")
panel |> add_conflict(dataset = "ucdp_prio")
panel |> add_conflict(dataset = "mmad")
panel |> add_conflict(dataset = "mec")

# Raw join without aggregation (for campaign and episode datasets)
panel |> add_conflict(dataset = "navco1.3", aggregate = FALSE)
panel |> add_conflict(dataset = "mec", aggregate = FALSE)
```

> **Note:** `ucdp_vpp` requires the `readxl` package:
> `install.packages("readxl")` MEC requires the `haven` package:
> `install.packages("haven")`

## Licensing

The package’s MIT license applies to the software, not to third-party
data. Gapminder and UCDP identify their bundled data as CC BY 4.0; NAVCO
2.1 and MEC are CC0. Other source files retain their creators’ terms.
See `inst/COPYRIGHTS` and verify the applicable terms before
redistributing a package build containing those files.

[^1]: The bundled file contains two records beginning in 1899.

[^2]: The bundled file contains two records beginning in 1899.

[^3]: Official coverage begins in 1990; one continuing event has a
    recorded 1989 start.
