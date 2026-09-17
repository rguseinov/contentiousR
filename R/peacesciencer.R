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
#'   (Gleditsch-Ward) alias and the attributes `ps_system` and
#'   `ps_data_type = "state_year"`. Rows and analytical variables are not
#'   changed.
#'
#' @details
#' `peacesciencer` dispatches its `add_*()` functions using attributes created
#' by `peacesciencer::create_stateyears()`. It also expects its own key names:
#' `ccode` for COW panels and `gwcode` for Gleditsch-Ward panels. This adapter
#' supplies that interface without replacing contentiousR's `cow` or `gw` key.
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
  ps_key <- if (coding_system == "cow") "ccode" else "gwcode"

  if (
    ps_key %in% names(panel) &&
      !isTRUE(all.equal(
        panel[[ps_key]],
        panel[[coding_system]],
        check.attributes = FALSE
      ))
  ) {
    stop(
      "Existing `", ps_key, "` values do not match `", coding_system, "`.",
      call. = FALSE
    )
  }

  panel[[ps_key]] <- panel[[coding_system]]
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
#' state-year data. It does not alter country codes: `ccode` is simply
#' `peacesciencer`'s name for the COW code stored as `cow` by contentiousR.
#'
#' Use [as_peacesciencer_panel()] instead when several `peacesciencer`
#' functions will be applied in one uninterrupted pipeline and retaining the
#' compatibility metadata until the end is preferable.
#'
#' @examples
#' \dontrun{
#' library(peacesciencer)
#'
#' panel <- build_states_panel(1990, 1995, coding_system = "cow") |>
#'   add_from_peacesciencer(add_archigos)
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
    result[[coding_system]] <- result[[ps_key]]
  }

  if (
    ps_key %in% names(result) &&
      !isTRUE(all.equal(
        result[[ps_key]],
        result[[coding_system]],
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
