# Changelog

## contentiousR (development version)

### New data

- [`conflict_data()`](https://rguseinov.github.io/contentiousR/dev/reference/conflict_data.md)
  and
  [`add_conflict()`](https://rguseinov.github.io/contentiousR/dev/reference/add_conflict.md)
  gain `dataset = "raqed"`: the Revolutionary and Quasi-revolutionary
  Episodes Dataset (RAQED) v1.4, 2000-2026, HSE University. RAQED is the
  renamed successor of the CSRA Revolutionary Database. Columns use the
  `raqed_` prefix, and `raqed_type_re`, `raqed_type_re_q`, and
  `raqed_type_qre` are dummies for the source’s episode `type`.
- [`conflict_data()`](https://rguseinov.github.io/contentiousR/dev/reference/conflict_data.md)
  and
  [`add_conflict()`](https://rguseinov.github.io/contentiousR/dev/reference/add_conflict.md)
  gain `dataset = "omg"`: the Opposition Movements and Groups (OMG)
  dataset v1, 1789-2019 (Dahl et al. 2026), at the campaign-phase level.
  `omg_onset` marks a campaign’s first phase and `omg_phase_onset` every
  phase.
- [`conflict_data()`](https://rguseinov.github.io/contentiousR/dev/reference/conflict_data.md)
  and
  [`add_conflict()`](https://rguseinov.github.io/contentiousR/dev/reference/add_conflict.md)
  gain `dataset = "arc"`: the Anatomy of Resistance Campaigns (ARC) 2.0
  events, 1990-2018 (Vüllers et al. 2026), aggregated to country-year:
  event counts by source and by maximalist demands, and the number of
  events with, and distinct organizations taking part in, dissent.
- [`conflict_data()`](https://rguseinov.github.io/contentiousR/dev/reference/conflict_data.md)
  and
  [`add_conflict()`](https://rguseinov.github.io/contentiousR/dev/reference/add_conflict.md)
  gain `dataset = "navco3.0"`: the NAVCO 3.0 event data on 26 countries,
  1990-2012 (Chenoweth, Pinckney, and Lewis 2018), aggregated to counts
  of campaign actions by tactic and goal, state concessions and
  repression, and fatality, injury, and participant ranges.
- `cn_cite("raqed")`, `cn_cite("omg")`, `cn_cite("arc")`, and
  `cn_cite("navco3.0")` return the new citations.

### Country-quarter, country-month, and country-day panels

- [`build_states_panel()`](https://rguseinov.github.io/contentiousR/dev/reference/build_states_panel.md)
  gains `unit = c("year", "quarter", "month", "day")`. Quarterly panels
  add a `quarter` column, monthly panels a `month` column, daily panels
  `month`, `day`, and `date`. Yearly panels are unchanged.
- [`conflict_data()`](https://rguseinov.github.io/contentiousR/dev/reference/conflict_data.md)
  gains `unit`, and
  [`add_conflict()`](https://rguseinov.github.io/contentiousR/dev/reference/add_conflict.md)
  detects the panel’s unit: event data are aggregated, and campaign and
  episode records placed, by the month or day of their start date. SCAD,
  MM, MMAD, ARC, NAVCO 3.0, Beissinger, RAQED, MEC, and OMG support all
  units; NAVCO 1.3, NAVCO 2.1, UCDP/PRIO, and UCDP VPP record only years
  and error for a finer unit. Records dated less precisely than the unit
  are dropped with a message.
- [`add_lag()`](https://rguseinov.github.io/contentiousR/dev/reference/add_lag.md)
  and
  [`add_spell_duration()`](https://rguseinov.github.io/contentiousR/dev/reference/add_spell_duration.md)
  count months or days in sub-annual panels.
  [`plot_coverage()`](https://rguseinov.github.io/contentiousR/dev/reference/plot_coverage.md)
  shows them by year.
  [`as_peacesciencer_panel()`](https://rguseinov.github.io/contentiousR/dev/reference/as_peacesciencer_panel.md),
  [`add_from_peacesciencer()`](https://rguseinov.github.io/contentiousR/dev/reference/add_from_peacesciencer.md),
  and
  [`harmonize_conflict_data()`](https://rguseinov.github.io/contentiousR/dev/reference/harmonize_conflict_data.md)
  require a country-year panel.
- `conflict_data(dataset = "beissinger")` gains
  `beissinger_startdatetxt`, the source’s start date text.
- [`load_leader_data()`](https://rguseinov.github.io/contentiousR/dev/reference/load_leader_data.md)
  gains `unit`, and
  [`add_leader_data()`](https://rguseinov.github.io/contentiousR/dev/reference/add_leader_data.md)
  detects the panel’s unit. Leaders are placed by their dates in office,
  so each period gets the leader in power at its end (Mubarak in January
  2011, Tantawi from February). Finer units add
  `leader_tenure_quarters`, `leader_tenure_months`, or
  `leader_tenure_days`; `leader_tenure` still counts calendar years.
  REIGN supports up to months.
- New
  [`aggregate_panel()`](https://rguseinov.github.io/contentiousR/dev/reference/aggregate_panel.md)
  collapses a country-day, country-month, or country-quarter panel to a
  coarser unit: counts are summed, indicators and maxima take the
  maximum, other columns take the value of the last period, and lags and
  spell counters are dropped. The rules can be overridden per column.

### Coverage, zero-filling, and episodes in progress

- [`add_conflict()`](https://rguseinov.github.io/contentiousR/dev/reference/add_conflict.md)
  gains `fill_zero = FALSE`. With `fill_zero = TRUE`, event indicators
  and counts are 0 in periods the dataset covers but records nothing,
  and stay `NA` outside its coverage. Coverage is defined per dataset:
  global datasets cover every state, SCAD, ARC, and NAVCO 3.0 the
  countries they record, MM the country-years it lists, and MMAD each
  country from its first to its last recorded year.
- [`add_conflict()`](https://rguseinov.github.io/contentiousR/dev/reference/add_conflict.md)
  adds `<prefix>incidence` and `<prefix>n_active` for NAVCO 1.3, NAVCO
  2.1, Beissinger, RAQED, MEC, and OMG: whether, and how many, episodes
  were in progress in each period, from start to end date. Onset columns
  are unchanged.
- `conflict_data(dataset = "navco1.3")` gains `nvc1.3_EYEAR`, the
  campaign’s end year.
- New
  [`list_datasets()`](https://rguseinov.github.io/contentiousR/dev/reference/list_datasets.md)
  lists the bundled datasets with their years, countries, record type,
  supported units, column prefix, and coverage rule.

### Bug fixes

#### Country codes

Several states were silently dropped or matched to the wrong country,
because `countrycode` converts codes without regard to the year and has
no equivalent for some states. Conversions between COW and
Gleditsch-Ward codes now go through one year-aware function, used by
every loader.

- GW panels from `build_states_panel(coding_system = "gw")` had no
  Vietnam (GW 816) and, with `exclude_microstates = FALSE`, no Caribbean
  island states or other microstates: rows were dropped when
  `countrycode` had no country name for the code. Names now fall back to
  the `states` package. Abkhazia and South Ossetia are now removed by
  `exclude_non_un = TRUE`.
- COW panels code West Germany as 255 and Czechoslovakia as 316, but
  data using standard COW codes (NMC population and military
  expenditure, V-Dem, Archigos and REIGN leaders, SIPRI, and the
  conflict datasets) kept 260 and 315, so West Germany (1955-1989) and
  Czechoslovakia (up to 1992) got no data in COW panels, including
  NAVCO, MEC, and OMG campaigns such as the Prague Spring. All loaders
  now use the panels’ codes.
  [`as_peacesciencer_panel()`](https://rguseinov.github.io/contentiousR/dev/reference/as_peacesciencer_panel.md)
  and
  [`add_from_peacesciencer()`](https://rguseinov.github.io/contentiousR/dev/reference/add_from_peacesciencer.md)
  give `peacesciencer` the standard COW codes (`ccode` 260 and 315).
- Yemen: GW-coded sources (UCDP/PRIO, UCDP VPP, Fariss, Barnum) were not
  matched to COW 679 (Yemen from 1990), e.g. 19 conflict-years of
  UCDP/PRIO; COW-coded sources lost Yemen from 1990 in GW panels.
  Sources that code Yemen as one unit throughout now give COW 678 up to
  1990.
- Serbia: GW panels code Yugoslavia as 345 up to 2006 and Serbia as 340
  after, but conversions used one code for all years, so Serbia’s data
  were lost in one period or the other (e.g. Gapminder, SIPRI, NMC,
  V-Dem, MEC, MMAD, RAQED). Germany before 1945 (GW 255) and Vietnam
  were lost in COW panels with GW-coded sources (Fariss, Barnum).
- Mass Mobilization uses its own codes for several states. Kosovo
  (MM 341) was matched to Montenegro (COW 341), and Yugoslavia and
  Serbia and Montenegro (1992-2006), Serbia and Montenegro from 2006,
  the USSR, South Sudan, Ethiopia from 2016, and Yemen from 2016 were
  not matched at all.
- [`add_regions()`](https://rguseinov.github.io/contentiousR/dev/reference/add_regions.md)
  returned `NA` for Serbia, and in GW panels for Yemen, Czechoslovakia,
  and Vietnam.
- [`harmonize_conflict_data()`](https://rguseinov.github.io/contentiousR/dev/reference/harmonize_conflict_data.md)
  converts country names by year too (Serbia in COW panels and Yemen in
  GW panels were dropped), and with `aggregate = FALSE` no longer errors
  when `year_col` is `"year"` or `country_col` is the panel’s code
  column.

#### UN World Population Prospects

- The WPP population data are rebuilt reproducibly from the ‘wpp2024’
  package (`data-raw/extdata.R`). The previous extract had been matched
  to COW codes by country name, which left out Serbia and Yugoslavia
  entirely, and gave historical states the population of today’s country
  with the same code: e.g. the USSR had Russia’s population (139 instead
  of 267 million in 1980), Pakistan before 1971 lacked East Pakistan,
  and West Germany had the population of unified Germany.
- `load_population_data(dataset = "wpp")` now assigns each WPP country
  to the state that governed it in each year: states that later split
  are the sum of their parts (USSR, Yugoslavia, Czechoslovakia,
  Ethiopia, Pakistan, Sudan, Indonesia with Timor-Leste, Malaysia with
  Singapore, the United Arab Republic), Hong Kong and Macao join China
  from 1997 and 1999, and parts of later unified states that WPP cannot
  separate are `NA` (the two Germanys and Yemens before 1990, the two
  Vietnams before 1976, Tanganyika and Zanzibar before 1964). It returns
  only the years each state exists, and works the same way for GW codes.

#### Other bug fixes

- [`plot_temporal_coverage()`](https://rguseinov.github.io/contentiousR/dev/reference/plot_temporal_coverage.md)
  skipped periods without events instead of plotting 0, so lines ran
  straight across gaps.
- `cn_cite("gapminder")` and `cn_cite("vdem")` now return citations,
  like every other `dataset =` value.
- Documentation: Barnum et al. coverage is 1816-2023 (military burden to
  2019); the Gapminder file runs to 2100, and its most recent years are
  forecasts and projections, not observations.
- `load_leader_data(dataset = "reign")` dropped leaders still in office
  when the REIGN data end (no exit date in the source), so every
  country-year of their tenure was missing (e.g. Russia from 2000 on):
  135 of 194 countries had a leader in 2015 and 29 in 2021, against 194
  now. They are now kept in office through August 2021, the last month
  REIGN covers. When two leaders took office in the same month, the
  later one by day is now kept, as the year-end leader.
- In a country-month or country-day panel,
  [`add_conflict()`](https://rguseinov.github.io/contentiousR/dev/reference/add_conflict.md)
  with an episode dataset (Beissinger, RAQED, MEC, OMG) added a `day`
  column, which made the panel look like a country-day panel to later
  functions.
- `conflict_data(dataset = "mm")` counted the source’s `protest = 0`
  rows, which mark country-years without a protest, as protests: 1,906
  of 4,877 country-years had `mm_onset = 1` and `mm_n_protests = 1` but
  no protest. They now have `mm_onset = 0` and `mm_n_protests = 0`.

### Package size

- The SIPRI military expenditure data are now stored as a compact `.rds`
  table built from the two workbook sheets the package uses, instead of
  the full ten-sheet `.xlsx` workbook (0.9 MB to 0.12 MB).
  `load_military_expenditure_data(dataset = "sipri")` returns exactly
  the same data as before and no longer reads the workbook with
  ‘readxl’.

### Breaking changes

- `dataset = "csra"` is removed: the CSRA Revolutionary Database has
  been renamed RAQED.
  [`conflict_data()`](https://rguseinov.github.io/contentiousR/dev/reference/conflict_data.md)
  and
  [`add_conflict()`](https://rguseinov.github.io/contentiousR/dev/reference/add_conflict.md)
  now stop with a message pointing to `dataset = "raqed"` (version 1.4),
  and the CSRA v1.102 file is no longer bundled.

## contentiousR 0.1.0

CRAN release: 2026-10-15

### Changes made for CRAN

- The package title is now “Contentious Politics and Civil Conflict
  Research”.
- [`cn_cite()`](https://rguseinov.github.io/contentiousR/dev/reference/cn_cite.md)
  now returns its result visibly instead of printing it with
  [`cat()`](https://rdrr.io/r/base/cat.html). The result is a `bibentry`
  object with the additional class `cn_citation`; typing
  `cn_cite("archigos")` at the console still shows the BibTeX, and
  [`print()`](https://rdrr.io/r/base/print.html) shows it explicitly.
- The bundled data files are smaller (tarball 4.3 MB): they keep only
  the columns the package reads, and the MEC and NMC Stata files are
  stored as compressed `.rds`. Loader output is unchanged. ‘haven’ is no
  longer used.
- `citation("contentiousR")` now lists the SSRN preprint describing the
  package, followed by the software citation.

### Bug fixes

- `load_vdem_data(coding_system = "cow")` no longer silently drops East
  Germany (COW 265, 1949-1990); it was previously excluded only in the
  `"cow"` branch, so V-Dem coverage for Germany differed depending on
  the chosen coding system with no indication why.
- [`add_spell_duration()`](https://rguseinov.github.io/contentiousR/dev/reference/add_spell_duration.md)
  now computes spells from the actual calendar-year difference instead
  of row position within a state. A gap in the input years (e.g. left by
  `tidyr::drop_na(event)`, which the package’s own examples recommend)
  previously understated the elapsed time.
- [`plot_coverage()`](https://rguseinov.github.io/contentiousR/dev/reference/plot_coverage.md)
  now errors with a clear message instead of crashing when
  `drop_empty = TRUE` removes every state (e.g. the chosen event never
  occurs in the supplied panel/year range).
- [`cn_cite()`](https://rguseinov.github.io/contentiousR/dev/reference/cn_cite.md)
  matched keywords by substring, so a short `dataset` name (e.g. `"mm"`)
  could also match an unrelated entry whose keyword merely contained it
  as a substring (`"mmad"`). Keyword matching is now exact against the
  comma-separated keyword list.
- [`harmonize_conflict_data()`](https://rguseinov.github.io/contentiousR/dev/reference/harmonize_conflict_data.md):
  a factor `year_col` was coerced with
  [`as.integer()`](https://rdrr.io/r/base/integer.html), which returns
  the factor’s internal level codes rather than the printed year. It is
  now converted to character first. A `date_col` that fails to parse
  (e.g. a non-ISO format without a matching `date_format`) now raises a
  clear error instead of a generic base-R one.

### Bring your own data

- Added
  [`harmonize_conflict_data()`](https://rguseinov.github.io/contentiousR/dev/reference/harmonize_conflict_data.md)
  to join externally supplied conflict/ event data (GDELT, ICEWS, ACLED,
  or anything else not bundled with `contentiousR`) onto a state panel:
  it maps the caller’s country column to COW/GW codes via
  [`countrycode::countrycode()`](https://rdrr.io/pkg/countrycode/man/countrycode.html),
  extracts a year from either a pre-parsed `year_col` or a
  `date_col`/`date_format`, optionally aggregates event-level rows to
  country-year (`<prefix>_onset`, `<prefix>_n_events`), and joins the
  result in. Unlike
  [`add_conflict()`](https://rguseinov.github.io/contentiousR/dev/reference/add_conflict.md),
  it never downloads or bundles data itself, so `contentiousR` gains no
  dependency on `gdeltr2`, `icews`, or `acled.api`.

### Visualization

- [`plot_coverage()`](https://rguseinov.github.io/contentiousR/dev/reference/plot_coverage.md)
  gained a `show_labels` argument (default `TRUE`). Set it to `FALSE` to
  drop the per-row country/code labels, which otherwise overlap and
  become illegible once the panel covers more than a few dozen states.
- [`plot_regional_coverage()`](https://rguseinov.github.io/contentiousR/dev/reference/plot_regional_coverage.md)’s
  region labels are now horizontal and word-wrapped instead of angled,
  and its region field’s canonical “Middle East” label is the shorter
  “Middle East & North Africa” form.
  [`plot_temporal_coverage()`](https://rguseinov.github.io/contentiousR/dev/reference/plot_temporal_coverage.md)’s
  period labels are now vertical instead of angled. Both plots no longer
  set a `ggplot2` title (redundant with a caption in a manuscript).
- Added
  [`plot_regional_coverage()`](https://rguseinov.github.io/contentiousR/dev/reference/plot_regional_coverage.md)
  and
  [`plot_temporal_coverage()`](https://rguseinov.github.io/contentiousR/dev/reference/plot_temporal_coverage.md)
  to compare regional and temporal event coverage across any combination
  of
  [`conflict_data()`](https://rguseinov.github.io/contentiousR/dev/reference/conflict_data.md)
  campaign/episode datasets, plus a “Comparing revolutionary-event
  datasets” article reproducing the descriptive exercise in Guseinov,
  Ustyuzhanin & Korotayev (2026).
- Added
  [`add_regions()`](https://rguseinov.github.io/contentiousR/dev/reference/add_regions.md)
  to join one or more `countrycode` region classifications (`region`,
  `region23`, `un.region.name`, `un.regionsub.name`) onto a state panel
  by `cow`/`gw` code.

### Data

- Added the Major Episodes of Contention (MEC) dataset: 2,734 globally
  covered reformist and maximalist episodes from 1955 through 2018. MEC
  is available through `conflict_data(dataset = "mec")` and
  `add_conflict(dataset = "mec")`. Episode-level rows are preserved
  unless the existing `aggregate = TRUE` policy is requested.

### Correctness

- [`fetch_campaign_events()`](https://rguseinov.github.io/contentiousR/dev/reference/fetch_campaign_events.md)
  (used by
  [`plot_regional_coverage()`](https://rguseinov.github.io/contentiousR/dev/reference/plot_regional_coverage.md)
  and
  [`plot_temporal_coverage()`](https://rguseinov.github.io/contentiousR/dev/reference/plot_temporal_coverage.md))
  now compares NAVCO 2.1 at the same campaign-onset level as the other
  datasets, using
  [`conflict_data()`](https://rguseinov.github.io/contentiousR/dev/reference/conflict_data.md)’s
  own `nvc2.1_ONSET` flag (keyed on the numeric campaign id) instead of
  re-deriving onsets from the campaign name, which is not unique and
  could silently merge distinct campaigns that happen to share a name.
- [`fetch_campaign_events()`](https://rguseinov.github.io/contentiousR/dev/reference/fetch_campaign_events.md)’s
  `region` field now stays at exactly 7 categories.
  [`countrycode::countrycode()`](https://rdrr.io/pkg/countrycode/man/countrycode.html)’s
  `"region"` destination labels a few pre-1990 historical entities
  (Yemen Arab Republic, Yemen People’s Republic, the United Arab
  Republic) with the World Bank’s older “Middle East & North Africa”
  string while every other MENA country gets the newer “Middle East,
  North Africa, Afghanistan & Pakistan” string; since campaign data
  covering the 1950s-80s includes those historical codes, the region was
  silently splitting into two bars in
  [`plot_regional_coverage()`](https://rguseinov.github.io/contentiousR/dev/reference/plot_regional_coverage.md)/[`plot_temporal_coverage()`](https://rguseinov.github.io/contentiousR/dev/reference/plot_temporal_coverage.md).
- `gdp_growth`
  ([`load_gdp_data()`](https://rguseinov.github.io/contentiousR/dev/reference/load_gdp_data.md),
  `dataset = "gapminder"`) is now `NA` unless the preceding row is
  genuinely one year earlier for the same country, the same gap-safety
  check
  [`add_lag()`](https://rguseinov.github.io/contentiousR/dev/reference/add_lag.md)
  uses.
- Removed `add_pop()`. It was an exact duplicate of
  [`add_population()`](https://rguseinov.github.io/contentiousR/dev/reference/add_population.md)
  (same body, same arguments, two visually identical Reference entries)
  and every other `add_*()`/`load_*_data()` pair in the package already
  shares one name
  ([`add_vdem()`](https://rguseinov.github.io/contentiousR/dev/reference/add_vdem.md)/[`load_vdem_data()`](https://rguseinov.github.io/contentiousR/dev/reference/load_vdem_data.md),
  [`add_leader_data()`](https://rguseinov.github.io/contentiousR/dev/reference/add_leader_data.md)/[`load_leader_data()`](https://rguseinov.github.io/contentiousR/dev/reference/load_leader_data.md),
  etc.) –
  [`add_population()`](https://rguseinov.github.io/contentiousR/dev/reference/add_population.md)
  is the one that matches
  [`load_population_data()`](https://rguseinov.github.io/contentiousR/dev/reference/load_population_data.md).
  Use
  [`add_population()`](https://rguseinov.github.io/contentiousR/dev/reference/add_population.md)
  instead.
- Renamed
  [`add_spells()`](https://rdrr.io/pkg/peacesciencer/man/add_spells.html)
  to
  [`add_spell_duration()`](https://rguseinov.github.io/contentiousR/dev/reference/add_spell_duration.md)
  to stop it silently shadowing (or being shadowed by)
  [`peacesciencer::add_spells()`](https://rdrr.io/pkg/peacesciencer/man/add_spells.html)
  when both packages are attached in the same session – the two are
  similar in spirit but not interchangeable (contentiousR’s version
  works on any binary `_onset`/`_incidence`/`_ongoing` column, not a
  fixed set of bundled columns).
- [`conflict_data()`](https://rguseinov.github.io/contentiousR/dev/reference/conflict_data.md)
  now applies `start_year` and `end_year` consistently to every bundled
  source.
- UCDP/PRIO output now distinguishes conflict incidence from episode
  onset. `ucdp_prio_onset` is based on `start_date2`; the new
  `ucdp_prio_incidence` column identifies all active conflict-years.
- SCAD country-year totals now exclude UCDP placeholder records,
  deduplicate multi-location rows by event ID, and treat documented
  negative death-count codes as missing.
- All-missing groups now produce `NA` instead of `-Inf`, `NaN`, and
  associated warnings during conflict aggregation.
- Mass Mobilization participant strings are retained in
  `mm_participants_reported`; `mm_participants` summarizes only exact
  numeric reports.
- [`add_conflict()`](https://rguseinov.github.io/contentiousR/dev/reference/add_conflict.md)
  no longer re-aggregates sources that are already unique by
  country-year, preventing character-valued source fields from being
  dropped.

### API and robustness

- Added
  [`as_peacesciencer_panel()`](https://rguseinov.github.io/contentiousR/dev/reference/as_peacesciencer_panel.md)
  to supply the state-year key aliases and metadata required by
  `peacesciencer` while preserving contentiousR’s API.
- Added
  [`add_from_peacesciencer()`](https://rguseinov.github.io/contentiousR/dev/reference/add_from_peacesciencer.md)
  to apply a state-year `peacesciencer` function while keeping temporary
  `ccode`/`gwcode` keys out of the result.
- [`build_states_cow_panel()`](https://rguseinov.github.io/contentiousR/dev/reference/build_states_cow_panel.md)
  is internal again (not exported). It’s the actual COW-panel
  implementation `build_states_panel(coding_system = "cow")` dispatches
  to, but there’s no public reason to call it directly instead of
  [`build_states_panel()`](https://rguseinov.github.io/contentiousR/dev/reference/build_states_panel.md)
  – and its GW counterpart, `build_states_gw_panel()`, was never
  exported in the first place.
- Added strict validation for years, logical flags, panel keys, and
  output-key uniqueness.
- [`build_states_panel()`](https://rguseinov.github.io/contentiousR/dev/reference/build_states_panel.md)
  now validates `start_year`/`end_year` against the Correlates of War /
  Gleditsch-Ward state system’s actual coverage: `1816`-`2025`.
- Added `ucdp_vpp_incidence`. The existing `ucdp_vpp_onset` column
  remains as a compatibility alias and is now documented as incidence
  rather than onset.
- Removed the `magrittr` dependency in favor of R’s native pipe.

### Release infrastructure

- Added broader test coverage, two introductory vignettes, package-level
  documentation, data provenance and licensing notes, pkgdown
  configuration, and GitHub Actions for package checks and site
  deployment.
- Added a case study article assembling a panel and modeling
  revolutionary onset, and a “Comparing revolutionary-event datasets”
  article (see Visualization above).
- Added a package logo, shown in the README and the pkgdown site navbar.
- Added formal `References` sections to
  [`load_gdp_data()`](https://rguseinov.github.io/contentiousR/dev/reference/load_gdp_data.md)/[`add_gdp()`](https://rguseinov.github.io/contentiousR/dev/reference/add_gdp.md),
  [`load_population_data()`](https://rguseinov.github.io/contentiousR/dev/reference/load_population_data.md)/[`add_population()`](https://rguseinov.github.io/contentiousR/dev/reference/add_population.md),
  [`load_military_expenditure_data()`](https://rguseinov.github.io/contentiousR/dev/reference/load_military_expenditure_data.md)/[`add_military_expenditure()`](https://rguseinov.github.io/contentiousR/dev/reference/add_military_expenditure.md),
  [`load_vdem_data()`](https://rguseinov.github.io/contentiousR/dev/reference/load_vdem_data.md)/[`add_vdem()`](https://rguseinov.github.io/contentiousR/dev/reference/add_vdem.md),
  [`conflict_data()`](https://rguseinov.github.io/contentiousR/dev/reference/conflict_data.md)/[`add_conflict()`](https://rguseinov.github.io/contentiousR/dev/reference/add_conflict.md),
  [`load_leader_data()`](https://rguseinov.github.io/contentiousR/dev/reference/load_leader_data.md)/[`add_leader_data()`](https://rguseinov.github.io/contentiousR/dev/reference/add_leader_data.md),
  and
  [`plot_regional_coverage()`](https://rguseinov.github.io/contentiousR/dev/reference/plot_regional_coverage.md)/[`plot_temporal_coverage()`](https://rguseinov.github.io/contentiousR/dev/reference/plot_temporal_coverage.md),
  citing the underlying data source(s) for each.
- Corrected the SCAD citation’s DOI (in `DESCRIPTION` and the bundled
  bibliography behind
  [`cn_cite()`](https://rguseinov.github.io/contentiousR/dev/reference/cn_cite.md)):
  the previous DOI did not resolve.
