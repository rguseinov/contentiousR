# Changelog

## contentiousR 0.1.0

### Bring your own data

- Added
  [`harmonize_conflict_data()`](https://rguseinov.github.io/contentiousR/reference/harmonize_conflict_data.md)
  to join externally supplied conflict/ event data (GDELT, ICEWS, ACLED,
  or anything else not bundled with `contentiousR`) onto a state panel:
  it maps the caller’s country column to COW/GW codes via
  [`countrycode::countrycode()`](https://rdrr.io/pkg/countrycode/man/countrycode.html),
  extracts a year from either a pre-parsed `year_col` or a
  `date_col`/`date_format`, optionally aggregates event-level rows to
  country-year (`<prefix>_onset`, `<prefix>_n_events`), and joins the
  result in. Unlike
  [`add_conflict()`](https://rguseinov.github.io/contentiousR/reference/add_conflict.md),
  it never downloads or bundles data itself, so `contentiousR` gains no
  dependency on `gdeltr2`, `icews`, or `acled.api`.

### Visualization

- [`plot_coverage()`](https://rguseinov.github.io/contentiousR/reference/plot_coverage.md)
  gained a `show_labels` argument (default `TRUE`). Set it to `FALSE` to
  drop the per-row country/code labels, which otherwise overlap and
  become illegible once the panel covers more than a few dozen states.
- [`plot_regional_coverage()`](https://rguseinov.github.io/contentiousR/reference/plot_regional_coverage.md)’s
  region labels are now horizontal and word-wrapped instead of angled,
  and its region field’s canonical “Middle East” label is the shorter
  “Middle East & North Africa” form.
  [`plot_temporal_coverage()`](https://rguseinov.github.io/contentiousR/reference/plot_temporal_coverage.md)’s
  period labels are now vertical instead of angled. Both plots no longer
  set a `ggplot2` title (redundant with a caption in a manuscript).
- Added
  [`plot_regional_coverage()`](https://rguseinov.github.io/contentiousR/reference/plot_regional_coverage.md)
  and
  [`plot_temporal_coverage()`](https://rguseinov.github.io/contentiousR/reference/plot_temporal_coverage.md)
  to compare regional and temporal event coverage across any combination
  of
  [`conflict_data()`](https://rguseinov.github.io/contentiousR/reference/conflict_data.md)
  campaign/episode datasets, plus a “Comparing revolutionary-event
  datasets” article reproducing the descriptive exercise in Guseinov,
  Ustyuzhanin & Korotayev (2026).
- Added
  [`add_regions()`](https://rguseinov.github.io/contentiousR/reference/add_regions.md)
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

- [`fetch_campaign_events()`](https://rguseinov.github.io/contentiousR/reference/fetch_campaign_events.md)
  (used by
  [`plot_regional_coverage()`](https://rguseinov.github.io/contentiousR/reference/plot_regional_coverage.md)
  and
  [`plot_temporal_coverage()`](https://rguseinov.github.io/contentiousR/reference/plot_temporal_coverage.md))
  now compares NAVCO 2.1 at the same campaign-onset level as the other
  datasets, using
  [`conflict_data()`](https://rguseinov.github.io/contentiousR/reference/conflict_data.md)’s
  own `nvc2.1_ONSET` flag (keyed on the numeric campaign id) instead of
  re-deriving onsets from the campaign name, which is not unique and
  could silently merge distinct campaigns that happen to share a name.
- [`fetch_campaign_events()`](https://rguseinov.github.io/contentiousR/reference/fetch_campaign_events.md)’s
  `region` field now stays at exactly 7 categories.
  [`countrycode::countrycode()`](https://rdrr.io/pkg/countrycode/man/countrycode.html)’s
  `"region"` destination labels a few pre-1990 historical entities
  (Yemen Arab Republic, Yemen People’s Republic, the United Arab
  Republic) with the World Bank’s older “Middle East & North Africa”
  string while every other MENA country gets the newer “Middle East,
  North Africa, Afghanistan & Pakistan” string; since campaign data
  covering the 1950s-80s includes those historical codes, the region was
  silently splitting into two bars in
  [`plot_regional_coverage()`](https://rguseinov.github.io/contentiousR/reference/plot_regional_coverage.md)/[`plot_temporal_coverage()`](https://rguseinov.github.io/contentiousR/reference/plot_temporal_coverage.md).
- `gdp_growth`
  ([`load_gdp_data()`](https://rguseinov.github.io/contentiousR/reference/load_gdp_data.md),
  `dataset = "gapminder"`) is now `NA` unless the preceding row is
  genuinely one year earlier for the same country, the same gap-safety
  check
  [`add_lag()`](https://rguseinov.github.io/contentiousR/reference/add_lag.md)
  uses.
- Removed `add_pop()`. It was an exact duplicate of
  [`add_population()`](https://rguseinov.github.io/contentiousR/reference/add_population.md)
  (same body, same arguments, two visually identical Reference entries)
  and every other `add_*()`/`load_*_data()` pair in the package already
  shares one name
  ([`add_vdem()`](https://rguseinov.github.io/contentiousR/reference/add_vdem.md)/[`load_vdem_data()`](https://rguseinov.github.io/contentiousR/reference/load_vdem_data.md),
  [`add_leader_data()`](https://rguseinov.github.io/contentiousR/reference/add_leader_data.md)/[`load_leader_data()`](https://rguseinov.github.io/contentiousR/reference/load_leader_data.md),
  etc.) –
  [`add_population()`](https://rguseinov.github.io/contentiousR/reference/add_population.md)
  is the one that matches
  [`load_population_data()`](https://rguseinov.github.io/contentiousR/reference/load_population_data.md).
  Use
  [`add_population()`](https://rguseinov.github.io/contentiousR/reference/add_population.md)
  instead.
- Renamed
  [`add_spells()`](https://rdrr.io/pkg/peacesciencer/man/add_spells.html)
  to
  [`add_spell_duration()`](https://rguseinov.github.io/contentiousR/reference/add_spell_duration.md)
  to stop it silently shadowing (or being shadowed by)
  [`peacesciencer::add_spells()`](https://rdrr.io/pkg/peacesciencer/man/add_spells.html)
  when both packages are attached in the same session – the two are
  similar in spirit but not interchangeable (contentiousR’s version
  works on any binary `_onset`/`_incidence`/`_ongoing` column, not a
  fixed set of bundled columns).
- [`conflict_data()`](https://rguseinov.github.io/contentiousR/reference/conflict_data.md)
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
- [`add_conflict()`](https://rguseinov.github.io/contentiousR/reference/add_conflict.md)
  no longer re-aggregates sources that are already unique by
  country-year, preventing character-valued source fields from being
  dropped.

### API and robustness

- Added
  [`as_peacesciencer_panel()`](https://rguseinov.github.io/contentiousR/reference/as_peacesciencer_panel.md)
  to supply the state-year key aliases and metadata required by
  `peacesciencer` while preserving contentiousR’s API.
- Added
  [`add_from_peacesciencer()`](https://rguseinov.github.io/contentiousR/reference/add_from_peacesciencer.md)
  to apply a state-year `peacesciencer` function while keeping temporary
  `ccode`/`gwcode` keys out of the result.
- [`build_states_cow_panel()`](https://rguseinov.github.io/contentiousR/reference/build_states_cow_panel.md)
  is internal again (not exported). It’s the actual COW-panel
  implementation `build_states_panel(coding_system = "cow")` dispatches
  to, but there’s no public reason to call it directly instead of
  [`build_states_panel()`](https://rguseinov.github.io/contentiousR/reference/build_states_panel.md)
  – and its GW counterpart, `build_states_gw_panel()`, was never
  exported in the first place.
- Added strict validation for years, logical flags, panel keys, and
  output-key uniqueness.
- [`build_states_panel()`](https://rguseinov.github.io/contentiousR/reference/build_states_panel.md)
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
