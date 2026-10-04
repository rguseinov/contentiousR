#' Lag a vector within a panel, respecting gaps in the year sequence
#'
#' @param x Vector to lag.
#' @param year Integer year vector, same length as `x`, for the same
#'   cross-sectional unit and already sorted ascending.
#' @param n Integer. Number of years to lag by.
#'
#' @return `x` shifted back by `n` positions, with `NA` wherever the
#'   corresponding row is not exactly `n` years earlier (e.g. because that
#'   year is missing from the data).
#'
#' @keywords internal
lag_with_year_gap_check <- function(x, year, n) {
  lagged   <- dplyr::lag(x, n)
  year_lag <- dplyr::lag(year, n)
  gap_ok   <- !is.na(year_lag) & (year - year_lag == n)
  lagged[!gap_ok] <- NA
  lagged
}


#' Add lagged variables to a state panel
#'
#' @description
#' Adds a lagged version of each requested column, computed within each
#' state (`group_by(cow)` or `group_by(gw)`, matching the panel's coding
#' system) after sorting by year — required for lags to be meaningful in
#' panel data. Unlike a plain `dplyr::lag()`, the lag is `NA` wherever the
#' preceding row is not exactly `n` years earlier, so gaps in the year
#' sequence (e.g. after filtering with `tidyr::drop_na()`) do not silently
#' produce a lag from the wrong year.
#'
#' @param panel A data frame produced by `build_states_panel()`, containing
#'   a `cow` or `gw` column and a `year` column.
#' @param vars Character vector of column names in `panel` to lag.
#' @param n Integer. Number of years to lag by. Default `1`.
#'
#' @return The input panel with one additional column per entry in `vars`,
#'   named `<var>_l`, holding the value of `<var>` from `n` years earlier
#'   for the same state (or `NA` if that year is not present in `panel`).
#'
#' @examples
#' panel <- build_states_panel(1990, 2000, coding_system = "cow") |>
#'   add_gdp() |>
#'   add_lag(vars = c("gdp_pcap", "gdp_growth"), n = 1)
#'
#' @export
add_lag <- function(panel, vars, n = 1) {
  coding_system <- detect_coding_system(panel)

  missing_vars <- setdiff(vars, names(panel))
  if (length(missing_vars) > 0L) {
    stop(
      "Column(s) not found in `panel`: ", paste(missing_vars, collapse = ", "),
      call. = FALSE
    )
  }

  if (!is.numeric(n) || length(n) != 1L || is.na(n) || n %% 1 != 0 || n < 1) {
    stop("`n` must be a single positive whole number.", call. = FALSE)
  }
  n <- as.integer(n)

  new_cols <- paste0(vars, "_l")
  collisions <- intersect(new_cols, names(panel))
  if (length(collisions) > 0L) {
    stop(
      "`panel` already has column(s): ", paste(collisions, collapse = ", "),
      call. = FALSE
    )
  }

  panel |>
    dplyr::arrange(.data[[coding_system]], .data$year) |>
    dplyr::group_by(.data[[coding_system]]) |>
    dplyr::mutate(
      dplyr::across(
        dplyr::all_of(vars),
        ~ lag_with_year_gap_check(.x, .data$year, n),
        .names = "{.col}_l"
      )
    ) |>
    dplyr::ungroup()
}
