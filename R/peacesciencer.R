#' Make a state panel compatible with peacesciencer
#'
#' Adds the key alias and metadata expected by state-year functions from the
#' `peacesciencer` package. The original `cow` or `gw` column is retained, so
#' the result remains compatible with all `contentiousR` functions.
#'
#' @param panel A state-year data frame containing exactly one of `cow` or `gw`
#'   and a `year` column.
#'
#' @return The input data frame with an additional `ccode` (COW) or `gwcode`
#'   (Gleditsch-Ward) key and the attributes `ps_system` and
#'   `ps_data_type = "state_year"`. Rows and analytical variables are not
#'   changed.
#'
#' @details
#' `peacesciencer` dispatches its `add_*()` functions using attributes created
#' by `peacesciencer::create_stateyears()`. It also expects its own key names:
#' `ccode` for COW panels and `gwcode` for Gleditsch-Ward panels. This adapter
#' supplies that interface without replacing contentiousR's `cow` or `gw` key.
#'
#' contentiousR's COW panels code the German Federal Republic as 255 and
#' Czechoslovakia as 316, so that each state keeps one code over time.
#' `ccode` uses the standard COW codes that `peacesciencer` expects: 260 for
#' West Germany (1955-1989) and 315 for Czechoslovakia (up to 1992). `gwcode`
#' equals `gw`.
#'
#' Place the adapter immediately before the first `peacesciencer` function, or
#' earlier in the pipeline. Dplyr joins used by contentiousR preserve these
#' attributes.
#'
#' @examples
#' panel <- build_states_panel(1990, 1995, coding_system = "cow") |>
#'   add_gdp() |>
#'   as_peacesciencer_panel()
#'
#' names(panel)
#' attr(panel, "ps_system")
#' attr(panel, "ps_data_type")
#'
#' @export
as_peacesciencer_panel <- function(panel) {
  coding_system <- detect_coding_system(panel)
  check_yearly_panel(panel, "as_peacesciencer_panel")
  ps_key <- if (coding_system == "cow") "ccode" else "gwcode"

  expected <- peacesciencer_code(panel, coding_system)
  if (
    ps_key %in% names(panel) &&
      !isTRUE(all.equal(panel[[ps_key]], expected, check.attributes = FALSE))
  ) {
    stop(
      "Existing `", ps_key, "` values do not match `", coding_system, "`.",
      call. = FALSE
    )
  }

  panel[[ps_key]] <- expected
  attr(panel, "ps_system") <- coding_system
  attr(panel, "ps_data_type") <- "state_year"

  panel
}


#' Add data from peacesciencer and restore the contentiousR schema
#'
#' Temporarily adapts a contentiousR state-year panel to the column names and
#' metadata expected by a `peacesciencer` `add_*()` function. After that
#' function returns, the temporary `ccode` or `gwcode` alias and dispatch
#' attributes are removed. The original `cow` or `gw` key is retained.
#'
#' @param panel A contentiousR state-year data frame containing exactly one of
#'   `cow` or `gw` and a `year` column.
#' @param .fun A `peacesciencer` function whose first argument is a state-year
#'   data frame, such as `peacesciencer::add_archigos`.
#' @param ... Additional arguments passed to `.fun`.
#'
#' @return The data frame returned by `.fun`, restored to the input
#'   contentiousR key schema. A pre-existing `ccode` or `gwcode` column and
#'   pre-existing `ps_system` or `ps_data_type` attributes are preserved.
#'
#' @details
#' This helper is intended for `peacesciencer` functions that support
#' state-year data. `ccode` is the standard COW code (see
#' [as_peacesciencer_panel()]): West Germany and Czechoslovakia get their
#' own COW codes, 260 and 315, while `peacesciencer` adds its data, and the
#' panel keeps contentiousR's `cow` codes afterwards.
#'
#' Use [as_peacesciencer_panel()] instead when several `peacesciencer`
#' functions will be applied in one uninterrupted pipeline and retaining the
#' compatibility metadata until the end is preferable.
#'
#' @examples
#' if (requireNamespace("peacesciencer", quietly = TRUE)) {
#'   library(peacesciencer)
#'
#'   panel <- build_states_panel(1990, 1995, coding_system = "cow") |>
#'     add_from_peacesciencer(add_archigos)
#' }
#'
#' @export
add_from_peacesciencer <- function(panel, .fun, ...) {
  if (!is.function(.fun)) {
    stop(
      "`.fun` must be a function, such as `peacesciencer::add_archigos`.",
      call. = FALSE
    )
  }

  coding_system <- detect_coding_system(panel)
  check_yearly_panel(panel, "add_from_peacesciencer")
  ps_key <- if (coding_system == "cow") "ccode" else "gwcode"
  original_attributes <- attributes(panel)
  had_ps_key <- ps_key %in% names(panel)
  had_ps_system <- "ps_system" %in% names(original_attributes)
  had_ps_data_type <- "ps_data_type" %in% names(original_attributes)
  original_ps_system <- attr(panel, "ps_system", exact = TRUE)
  original_ps_data_type <- attr(panel, "ps_data_type", exact = TRUE)

  result <- .fun(as_peacesciencer_panel(panel), ...)

  if (!is.data.frame(result)) {
    stop("`.fun` must return a data frame.", call. = FALSE)
  }

  if (!coding_system %in% names(result)) {
    if (!ps_key %in% names(result)) {
      stop(
        "`.fun` removed both `", coding_system, "` and `", ps_key, "`.",
        call. = FALSE
      )
    }
    result[[coding_system]] <- if (coding_system == "cow") {
      standardize_cow(result[[ps_key]])
    } else {
      result[[ps_key]]
    }
  }

  if (
    ps_key %in% names(result) &&
      !isTRUE(all.equal(
        result[[ps_key]],
        peacesciencer_code(result, coding_system),
        check.attributes = FALSE
      ))
  ) {
    stop(
      "`", ps_key, "` returned by `.fun` no longer matches `",
      coding_system, "`.",
      call. = FALSE
    )
  }

  if (!had_ps_key && ps_key %in% names(result)) {
    result[[ps_key]] <- NULL
  }

  if (had_ps_system) {
    attr(result, "ps_system") <- original_ps_system
  } else {
    attr(result, "ps_system") <- NULL
  }

  if (had_ps_data_type) {
    attr(result, "ps_data_type") <- original_ps_data_type
  } else {
    attr(result, "ps_data_type") <- NULL
  }

  result
}

#' peacesciencer's country code for a contentiousR panel
#'
#' @param panel A country-year panel.
#' @param coding_system `"cow"` or `"gw"`.
#'
#' @return The `ccode` (standard COW: 260 for West Germany in 1955-1989, 315
#'   for Czechoslovakia up to 1992) or `gwcode` (equal to `gw`) values.
#'
#' @keywords internal
peacesciencer_code <- function(panel, coding_system) {
  code <- as.integer(panel[[coding_system]])
  if (coding_system == "cow") {
    year <- panel$year
    code[code %in% 255L & year >= 1955L & year <= 1989L] <- 260L
    code[code %in% 316L & year <= 1992L] <- 315L
  }
  code
}
