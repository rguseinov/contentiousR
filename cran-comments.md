## Resubmission

This is a resubmission. In response to the review:

* The Description field now states where to obtain the optional 'vdemdata'
  package (Suggests), which is not on CRAN:
  <https://github.com/vdeminstitute/vdemdata>. It is only used
  conditionally via `requireNamespace()`.
* The tarball is reduced from 11.3 MB to 8.9 MB (installed size from
  18.7 MB to 9.7 MB) by recompressing the bundled data files in
  `inst/extdata` with xz and storing the MEC data as a compressed `.rds`
  instead of an uncompressed Stata file. The loaded data are unchanged
  (verified identical output for every loader and dataset).

## Release summary

This is the first public release candidate (0.1.0). It adds validation,
corrects documented source-data interpretation bugs, restores one historical
export, expands tests, and adds vignettes, pkgdown, and continuous integration.

## Test environments

* Local: R 4.5.0, macOS 26.5.1, arm64, full network access
* GitHub Actions: R devel, release, and oldrel-1 on Ubuntu; R release on
  macOS and Windows -- all passing
* win-builder (R-devel), via `devtools::check_win_devel()`

## R CMD check results

Local `R CMD check --as-cran` (with `remote = TRUE`, full network access,
manual rebuilt): 0 errors | 0 warnings | 1 note

The note flags `vdemdata` (Suggests) as not being in a mainstream
repository. This is expected: `vdemdata` is not on CRAN and is only used
conditionally (`requireNamespace()`), with install instructions in the
package documentation.

An earlier check run also flagged one broken DOI and two unreachable/
bot-blocked source URLs cited in documentation; these have been corrected
(the DOI was wrong and has been replaced with the correct one; the URLs
now point to stable Wayback Machine snapshots) and no longer appear in the
incoming-feasibility check.

## Submission checklist

Redistribution terms for every third-party file in `inst/extdata` were
reviewed against each source's own terms of use (see `inst/COPYRIGHTS` for
the full list). Findings:

* Gapminder, UCDP/PRIO, UCDP VPP, NAVCO 2.1, NAVCO 1.3, Mass Mobilization,
  Major Episodes of Contention, UN WPP, Correlates of War NMC, and the
  Fariss et al. (2022) / Barnum et al. (2025) latent estimates all have
  either an explicit open license (CC0/CC-BY) or terms that permit
  non-commercial redistribution with citation.
* `mmad_events.csv.xz` (Mass Mobilization in Autocracies Database) is
  licensed CC BY-NC-SA 4.0 by its source, not MIT; this is called out
  explicitly in `inst/COPYRIGHTS` rather than left to the package-wide
  license statement.
* SCAD's terms of use grant only search/browse/view rights through its own
  web interface and do not address redistributing the underlying data
  files; the HSE CSRA dataset is subject to HSE's site-wide terms, which
  restrict copying/reproducing site materials outside on-site review. For
  both, and for three sources with no stated terms at all (Beissinger,
  Archigos, REIGN -- silence, not a grant of permission), the maintainer
  has reviewed the risk and decided to proceed without seeking further
  permission at this time.

## Downstream dependencies

There are no known downstream dependencies.
