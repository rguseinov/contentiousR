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

Unmatched panel rows remain `NA`, because absence from a source is not
always evidence of zero events.

MEC contains 2,734 reformist and maximalist contentious episodes
worldwide. `contentiousR` preserves its episode-level rows and all
published variables, using the source’s `byear` as `year`. Fourteen
left-censored episodes have a `mec_bdate` before 1955 but a source
`byear` of 1955. With `add_conflict(aggregate = TRUE)`, MEC follows the
same explicit aggregation policy as the other campaign and episode
sources; use `aggregate = FALSE` to retain individual episodes.

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
