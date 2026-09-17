## Release summary

This is the first public release candidate (0.1.0). It adds validation,
corrects documented source-data interpretation bugs, restores one historical
export, expands tests, and adds vignettes, pkgdown, and continuous integration.

## Test environments

* Local: R 4.5.0, macOS 26.5.1, arm64
* GitHub Actions (configured): R devel, release, and oldrel-1 on Ubuntu;
  R release on macOS and Windows

## R CMD check results

Local standard check: 0 errors | 0 warnings | 0 notes

Local `R CMD check --as-cran`: 0 errors | 0 warnings | 1 note

CRAN incoming feasibility and URL checks could not run because the check
sandbox had no DNS/network access. Source URLs were reviewed separately.

The PDF and HTML manuals, examples, tests, and rebuilt vignettes all pass.
The source tarball is approximately 7.5 MB and the installed package is 7.4 MB.

## Submission checklist

Before publishing the repository or submitting to CRAN, the maintainer must
confirm that redistribution is permitted for every third-party file listed in
`inst/COPYRIGHTS`. Explicit open licenses were found for Gapminder, UCDP, and
NAVCO 2.1; several other bundled academic sources publish downloads but do not
state unambiguous redistribution terms on their landing pages.

The pkgdown URL will become live when the site workflow first deploys the
`main` branch. Re-run online URL checks after that deployment and before CRAN
submission.

## Downstream dependencies

There are no known downstream dependencies.
