# Changelog

## contentiousR 0.1.0

### Data

- Added the Major Episodes of Contention (MEC) dataset: 2,734 globally
  covered reformist and maximalist episodes from 1955 through 2018. MEC
  is available through `conflict_data(dataset = "mec")` and
  `add_conflict(dataset = "mec")`. Episode-level rows are preserved
  unless the existing `aggregate = TRUE` policy is requested.

### Correctness

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
- Restored the previously exported
  [`build_states_cow_panel()`](https://rguseinov.github.io/contentiousR/reference/build_states_cow_panel.md)
  entry point for compatibility with contentiousR 0.0.1.
- Added strict validation for years, logical flags, panel keys, and
  output-key uniqueness.
- Added `ucdp_vpp_incidence`. The existing `ucdp_vpp_onset` column
  remains as a compatibility alias and is now documented as incidence
  rather than onset.
- Removed the `magrittr` dependency in favor of R’s native pipe.

### Release infrastructure

- Added broader test coverage, two introductory vignettes, package-level
  documentation, data provenance and licensing notes, pkgdown
  configuration, and GitHub Actions for package checks and site
  deployment.
