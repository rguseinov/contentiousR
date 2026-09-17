#' contentiousR: Tools and Data for Contentious Politics and Civil Conflict Research
#'
#' contentiousR creates COW- or Gleditsch-Ward-coded state-year panels and
#' joins bundled socioeconomic, conflict, protest, and leader data. V-Dem data
#' are available through the optional `vdemdata` package.
#'
#' The main workflow starts with [build_states_panel()] and continues with the
#' `add_*()` functions. The corresponding `load_*()` functions return source
#' data without joining it to a state panel.
#'
#' @section Country-code conversions:
#' Conversions use [countrycode::countrycode()]. Rows with no equivalent in the
#' requested coding system are omitted. Historical entities can differ between
#' COW and Gleditsch-Ward; users should inspect coverage for their study period.
#'
#' @section Data provenance:
#' See `vignette("data-sources", package = "contentiousR")` and
#' `citation("contentiousR")` for dataset versions, source links, licenses, and
#' requested citations.
#'
#' @keywords internal
"_PACKAGE"
