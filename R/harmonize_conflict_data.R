#' Harmonize externally supplied conflict/event data onto a state panel
#'
#' @description
#' Joins a conflict or event dataset that the caller supplies directly --
#' downloaded via GDELT, ICEWS, ACLED, or any other source not bundled with
#' `contentiousR` -- onto an existing state panel. Unlike [add_conflict()],
#' this function never downloads or bundles any data itself: `data` is
#' whatever data frame the caller already has in R, in whatever raw column
#' names and country/date encodings that source happens to use.
#'
#' @param panel A data frame produced by `build_states_panel()`, containing
#'   a `cow` or `gw` column and a `year` column.
#' @param data A data frame of external conflict/event data, one row per
#'   event (the default; see `aggregate`).
#' @param country_col Character. Name of the column in `data` holding
#'   country identifiers.
#' @param origin_code Character. The `countrycode::countrycode()` origin
#'   code matching `country_col`'s format, e.g. `"country.name"`,
#'   `"iso3c"`, `"fips"` (GDELT's two-letter country codes), `"cown"`,
#'   or `"gwc"`. See `countrycode::codelist` for the full list of
#'   supported origins.
#' @param prefix Character. Prefix for the new column(s), e.g. `"gdelt"`
#'   produces `gdelt_onset`/`gdelt_n_events` (see `aggregate`).
#' @param year_col Character. Name of a column in `data` already holding
#'   an integer year. Exactly one of `year_col` or `date_col` must be
#'   supplied.
#' @param date_col Character. Name of a column in `data` holding a date to
#'   extract the year from. Exactly one of `year_col` or `date_col` must
#'   be supplied.
#' @param date_format Character. A `format` string for [as.Date()], e.g.
#'   `"%Y%m%d"` for GDELT's `SQLDATE` field, or `"%d %B %Y"` for ACLED's
#'   `event_date`. If `NULL` (the default), `date_col` is parsed with
#'   `as.Date()` directly, which expects ISO 8601 (`"%Y-%m-%d"`) or an
#'   already-`Date`-typed column. Ignored if `year_col` is supplied.
#' @param aggregate Logical. If `TRUE` (default), `data` is treated as one
#'   row per event and is collapsed to one row per country-year, adding
#'   `<prefix>_onset` (always `1`, since a row only exists where an event
#'   occurred) and `<prefix>_n_events` (event count that country-year). If
#'   `FALSE`, `data` is assumed to already be one row per country-year;
#'   every other column in `data` (besides `country_col`/`year_col`/
#'   `date_col`) is renamed with `<prefix>_` and joined as-is.
#'
#' @return `panel` with the new column(s) joined in via `left_join()`.
#'   Country-years absent from `data` remain `NA` -- as with
#'   [add_conflict()], that is not evidence of zero events, only that
#'   `data` doesn't cover that country-year.
#'
#' @details
#' Country matching uses `countrycode::countrycode()`, so any row whose
#' `country_col` value it cannot map to the panel's coding system (an
#' unrecognized name, a sub-national/organizational entry, etc.) is
#' dropped, with a message reporting how many rows were dropped.
#'
#' `contentiousR` deliberately does not depend on `gdeltr2`, `icews`, or
#' `acled.api` -- this function is a generic bridge instead, so the
#' package is not exposed to any of those clients' own dependencies,
#' rate limits, or licensing terms. Cite the original data source
#' directly (this function does not know anything about the specific
#' provenance of `data`).
#'
#' @examples
#' panel <- build_states_panel(2015, 2018, coding_system = "cow")
#'
#' # An ACLED-style extract: one row per event, country as free text.
#' acled_like <- data.frame(
#'   country    = c("Nigeria", "Nigeria", "Mali", "Mali", "Mali"),
#'   event_date = c("2016-03-01", "2017-11-20", "2015-06-14",
#'                   "2015-09-02", "2018-01-30"),
#'   stringsAsFactors = FALSE
#' )
#'
#' panel |>
#'   harmonize_conflict_data(
#'     data        = acled_like,
#'     country_col = "country",
#'     origin_code = "country.name",
#'     date_col    = "event_date",
#'     prefix      = "acled"
#'   )
#'
#' # A GDELT-style extract: FIPS country codes, SQLDATE as YYYYMMDD.
#' gdelt_like <- data.frame(
#'   Actor1CountryCode = c("NI", "NI", "ML"),
#'   SQLDATE           = c(20160301L, 20171120L, 20150614L)
#' )
#'
#' panel |>
#'   harmonize_conflict_data(
#'     data        = gdelt_like,
#'     country_col = "Actor1CountryCode",
#'     origin_code = "fips",
#'     date_col    = "SQLDATE",
#'     date_format = "%Y%m%d",
#'     prefix      = "gdelt"
#'   )
#'
#' @export
harmonize_conflict_data <- function(
    panel,
    data,
    country_col,
    origin_code,
    prefix,
    year_col    = NULL,
    date_col    = NULL,
    date_format = NULL,
    aggregate   = TRUE
) {
  coding_system <- detect_coding_system(panel)
  check_flag(aggregate, "aggregate")

  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }
  if (!is.character(prefix) || length(prefix) != 1L || is.na(prefix) || !nzchar(prefix)) {
    stop("`prefix` must be a single, non-empty string.", call. = FALSE)
  }
  if (!country_col %in% names(data)) {
    stop("`country_col` ('", country_col, "') not found in `data`.", call. = FALSE)
  }
  if (is.null(year_col) == is.null(date_col)) {
    stop("Supply exactly one of `year_col` or `date_col`, not both.", call. = FALSE)
  }
  if (!is.null(year_col) && !year_col %in% names(data)) {
    stop("`year_col` ('", year_col, "') not found in `data`.", call. = FALSE)
  }
  if (!is.null(date_col) && !date_col %in% names(data)) {
    stop("`date_col` ('", date_col, "') not found in `data`.", call. = FALSE)
  }

  origin_dest <- if (coding_system == "cow") "cown" else "gwn"
  unit <- suppressWarnings(
    countrycode::countrycode(data[[country_col]], origin_code, origin_dest)
  )

  year <- if (!is.null(year_col)) {
    year_values <- data[[year_col]]
    if (is.factor(year_values)) {
      year_values <- as.character(year_values)
    }
    suppressWarnings(as.integer(year_values))
  } else {
    date_values <- data[[date_col]]
    if (is.factor(date_values)) {
      date_values <- as.character(date_values)
    }
    parsed <- tryCatch(
      if (is.null(date_format)) {
        as.Date(date_values)
      } else {
        as.Date(as.character(date_values), format = date_format)
      },
      error = function(e) {
        stop(
          "`date_col` ('", date_col, "') could not be parsed as a date",
          if (!is.null(date_format)) paste0(" with `date_format = \"", date_format, "\"`"),
          ". Check that the format matches, e.g. `date_format = \"%d %B %Y\"` ",
          "for dates like \"01 March 2016\".",
          call. = FALSE
        )
      }
    )
    as.integer(format(parsed, "%Y"))
  }

  harmonized <- data
  harmonized[[coding_system]] <- unit
  harmonized$year <- year

  n_before <- nrow(harmonized)
  harmonized <- tidyr::drop_na(harmonized, dplyr::all_of(c(coding_system, "year")))
  n_dropped <- n_before - nrow(harmonized)
  if (n_dropped > 0L) {
    message(
      n_dropped, " row(s) of `data` dropped: `country_col` did not map to a ",
      "valid ", toupper(coding_system), " code, or `",
      if (!is.null(year_col)) year_col else date_col,
      "` did not parse to a year."
    )
  }

  if (aggregate) {
    new_cols <- paste0(prefix, c("_onset", "_n_events"))
    collisions <- intersect(new_cols, names(panel))
    if (length(collisions) > 0L) {
      stop(
        "`panel` already has column(s): ", paste(collisions, collapse = ", "),
        call. = FALSE
      )
    }

    joined <- harmonized |>
      dplyr::count(.data[[coding_system]], .data$year, name = paste0(prefix, "_n_events"))
    joined[[paste0(prefix, "_onset")]] <- 1L
  } else {
    check_unique_key(harmonized, c(coding_system, "year"))

    keep_cols <- setdiff(names(harmonized), c(country_col, year_col, date_col))
    joined <- harmonized[, keep_cols, drop = FALSE]
    rename_cols <- setdiff(keep_cols, c(coding_system, "year"))
    new_names <- paste0(prefix, "_", rename_cols)

    collisions <- intersect(new_names, names(panel))
    if (length(collisions) > 0L) {
      stop(
        "`panel` already has column(s): ", paste(collisions, collapse = ", "),
        call. = FALSE
      )
    }

    names(joined)[match(rename_cols, names(joined))] <- new_names
  }

  dplyr::left_join(panel, joined, by = c(coding_system, "year"))
}
