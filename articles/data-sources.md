# Data sources and interpretation

`contentiousR` standardizes country and year keys; it does not make the
underlying research designs interchangeable. Cite each source used in an
analysis and consult its codebook for definitions, scope, and
limitations.

| Argument | Bundled version and coverage | Unit returned | Source |
|----|----|----|----|
| GDP: `"gapminder"` | Gapminder v32 | Country-year | [Gapminder](https://www.gapminder.org/gdp-per-capita/) |
| GDP: `"fariss"` | Fariss et al. 2022, latent estimate, 1500–2019 | Country-year | [Dataverse](https://doi.org/10.7910/DVN/DC0ING) |
| Population: `"wpp"` | UN World Population Prospects 2024, 1949–2023 | Country-year | [UN Population Division](https://population.un.org/wpp/) |
| Population: `"nmc"` | National Material Capabilities v7.0, 1816–2022 | Country-year | [Correlates of War](https://correlatesofwar.org/data-sets/national-material-capabilities/) |
| Population: `"fariss"` | Fariss et al. 2022, latent estimate, 1500–2019 | Country-year | [Dataverse](https://doi.org/10.7910/DVN/DC0ING) |
| Military expenditure: `"sipri"` | SIPRI Milex Database v1.2, 1949–2025 | Country-year | [SIPRI](https://www.sipri.org/databases/milex) |
| Military expenditure: `"nmc"` | National Material Capabilities v7.0, 1816–2022 | Country-year | [Correlates of War](https://correlatesofwar.org/data-sets/national-material-capabilities/) |
| Military expenditure: `"barnum"` | Barnum et al. 2025, latent estimate, 1816–2019 | Country-year | [Dataverse](https://doi.org/10.7910/DVN/RKJAKJ) |
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

The bundled UN WPP extract has three rows for some China country-years:
a combined mainland+Hong Kong+Macao+Taiwan figure, a mainland-only
figure, and a Hong Kong-only figure, all of which matched COW code 710
during country-name conversion upstream.
`load_population_data(dataset = "wpp")` resolves this by taking the
median `pop` value within each `cow`-`year` group (returned as
`wpp_pop`), which is consistently the mainland-only figure; every other
country-year has a single row, so the median is a no-op there.

NMC’s documented `-9` missing-data sentinel is recoded to `NA` in
`nmc_tpop` and `nmc_upop`.

Fariss, Anders, Markowitz, and Barnum’s replication files contain one
row per country-year for each underlying source indicator (e.g. Bairoch,
Penn World Table, World Bank) plus one `"latent_*"` row holding the
model’s combined estimate. `load_gdp_data(dataset = "fariss")` and
`load_population_data(dataset = "fariss")` keep only the `"latent_gdp"`
/ `"latent_gdppc"` / `"latent_pop"` rows. Their absolute units are not
independently verified in this package; consult Fariss et al. (2022)
before using `fariss_gdp`, `fariss_gdppc`, or `fariss_pop` outside of
relative/comparative analysis.

The SIPRI workbook lists a small number of rows (e.g. “Africa”, “NATO”)
that are regional or organizational aggregates rather than countries;
these have no matching COW/Gleditsch-Ward code and are dropped.

Barnum, Fariss, Markowitz, and Morales’s military expenditure
replication file contains one row per country-year for each of 24
underlying source indicators, each in its own original currency/unit,
with no single combined value on a real monetary scale (unlike the
Fariss GDP/population files, the paper does not publish the shared
latent trait directly because “the average by itself does not have a
real or direct monetary unit”). Instead,
`load_military_expenditure_data(dataset = "barnum")` reports the model’s
posterior estimate of two specific indicators: `barnum_sipri`
(`"milex_con_2022_sipri"`) and `barnum_nmc` (`"milex_con_2017_nmc"`),
which extend each one’s coverage back to 1816 using information from all
24 sources. Both are in constant (inflation-adjusted) dollars, so
`barnum_nmc` is not directly comparable to `nmc_milex` from
`dataset = "nmc"`, which NMC documents in current-year dollars; their
ratio varies smoothly over time (around 2.4 for the United States in
1990, falling toward 1 by the mid-2010s) rather than reflecting
disagreement between the sources. `barnum_milburden` (`milexgdp`) is a
unit-free ratio of spending to GDP and so is published directly.

## Licensing

The package’s MIT license applies to the software, not to third-party
data. Gapminder and UCDP identify their bundled data as CC BY 4.0; NAVCO
2.1 and MEC are CC0; UN WPP is CC BY 3.0 IGO. Other source files,
including NMC, SIPRI, and the Fariss et al. and Barnum et al. estimates,
retain their creators’ terms — SIPRI in particular is free to use with
attribution but requires separately negotiating a royalty for commercial
use. See `inst/COPYRIGHTS` and verify the applicable terms before
redistributing a package build containing those files.

[^1]: The bundled file contains two records beginning in 1899.

[^2]: The bundled file contains two records beginning in 1899.

[^3]: Official coverage begins in 1990; one continuing event has a
    recorded 1989 start.
