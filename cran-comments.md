## Resubmission

This is a resubmission. In response to the second review:

* The Title no longer starts with the redundant "Tools and Data for"; it is
  now "Contentious Politics and Civil Conflict Research".
* The one `\dontrun{}` example (`add_from_peacesciencer()`) is unwrapped.
  It runs in under 1 second and is only guarded by
  `if (requireNamespace("peacesciencer"))`, since 'peacesciencer' is in
  Suggests. No example uses `\dontrun{}` or `\donttest{}`; the slowest
  example takes about 2 seconds.

I also checked the package against the CRAN Cookbook and fixed the
following before resubmitting:

* `cn_cite()` no longer prints with `cat()`. It returns a `bibentry` object
  with an added class whose `print()` method displays BibTeX, so nothing is
  printed unless the result is printed.
* Every exported and internal function's Rd file now has a `\value` section.
* The Description field explains all acronyms (NAVCO, UCDP/PRIO, V-Dem) and
  cites references in the form authors (year) <doi:...>.
* A `Copyright` field points to `inst/COPYRIGHTS`, which lists the
  copyright holders and terms of the third-party data in `inst/extdata`.
* The package is now 4.3 MB as a tarball (previously 8.9 MB) and its
  installed size is below the 5 MB check threshold: the bundled data files
  keep only the columns the package reads, and Stata files are stored as
  compressed `.rds`. The loaded data are unchanged (verified identical
  output for every loader and dataset). 'haven' is therefore no longer
  needed and has been removed from Suggests.

In the first review, the Description field gained a statement of where to
obtain the optional 'vdemdata' package (Suggests), which is not on CRAN:
<https://github.com/vdeminstitute/vdemdata>. It is only used conditionally
via `requireNamespace()`.

Words in the Description that the spell check may flag are author surnames
(Chenoweth, Gleditsch, Guseinov, Kang, Salehyan), dataset and organization
names (Gapminder, Uppsala), and acronyms that are spelled out in the text
(NAVCO, UCDP, PRIO).

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

## Bundled data

The third-party data in `inst/extdata` are credited, with their source
licenses or terms of use, in `inst/COPYRIGHTS`, which the DESCRIPTION
`Copyright` field references; each source is also cited in the
documentation of the function that loads it. The one source under a license
other than the package's MIT license, the Mass Mobilization in Autocracies
Database (CC BY-NC-SA 4.0), is called out explicitly there.

## Downstream dependencies

There are no known downstream dependencies.
