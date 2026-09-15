# contentiousR: Build Peace Science Data Panels

contentiousR creates COW- or Gleditsch-Ward-coded state-year panels and
joins bundled socioeconomic, conflict, protest, and leader data. V-Dem
data are available through the optional `vdemdata` package.

## Details

The main workflow starts with
[`build_states_panel()`](https://rguseinov.github.io/contentiousR/reference/build_states_panel.md)
and continues with the `add_*()` functions. The corresponding `load_*()`
functions return source data without joining it to a state panel.

## Country-code conversions

Conversions use
[`countrycode::countrycode()`](https://rdrr.io/pkg/countrycode/man/countrycode.html).
Rows with no equivalent in the requested coding system are omitted.
Historical entities can differ between COW and Gleditsch-Ward; users
should inspect coverage for their study period.

## Data provenance

See
[`vignette("data-sources", package = "contentiousR")`](https://rguseinov.github.io/contentiousR/articles/data-sources.md)
and `citation("contentiousR")` for dataset versions, source links,
licenses, and requested citations.

## See also

Useful links:

- <https://rguseinov.github.io/contentiousR/>

- <https://github.com/rguseinov/contentiousR>

- Report bugs at <https://github.com/rguseinov/contentiousR/issues>

## Author

**Maintainer**: Ruslan Guseinov <rigusseinov@gmail.com>
([ORCID](https://orcid.org/0009-0000-1156-9495))

Authors:

- Ruslan Guseinov <rigusseinov@gmail.com>
  ([ORCID](https://orcid.org/0009-0000-1156-9495))
