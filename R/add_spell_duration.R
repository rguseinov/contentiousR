#' Add conflict spell (peace-years) durations to a state panel
#'
#' @description
#' Computes a BTSCS-style spell/duration counter from a binary conflict
#' column already present in the panel (typically added by
#' [add_conflict()]): the number of years since the last event for that
#' state, restarting after each new event. This is the same construct as
#' `peacesciencer::add_spells()`, generalized to work with any binary
#' column rather than a fixed set of bundled column names. Named
#' `add_spell_duration()`, not `add_spells()`, to avoid colliding with
#' `peacesciencer::add_spells()` when both packages are attached.
#'
#' @param panel A data frame produced by `build_states_panel()`, optionally
#'   already joined with conflict data via [add_conflict()].
#' @param event Character. Name of the binary (0/1) column to compute spells
#'   from. If `NULL` (the default), `add_spell_duration()` looks for exactly
#'   one column in `panel` whose name ends in `_onset`, `_incidence`, or
#'   `_ongoing`; if zero or more than one match, it errors and asks for an
#'   explicit `event`.
#' @param ongoing Logical. If `TRUE`, `event` is treated as an "ongoing"
#'   series where a run of consecutive `1`s is one continuous event (only
#'   the first year of the run counts as a new failure; the remaining years
#'   of that run get `NA` in the output, matching
#'   `peacesciencer::add_spells()`'s convention of excluding within-event
#'   years from a spell that measures time since the last event). If
#'   `FALSE`, every `1` in `event` is treated as its own event, appropriate
#'   for an already onset-coded column. If `NULL` (the default), this is
#'   inferred from the column name: `TRUE` for `_incidence`/`_ongoing`
#'   suffixes, `FALSE` for `_onset`.
#'
#' @return The input panel with one additional integer column, named after
#'   `event` with its onset/incidence/ongoing suffix (if any) replaced by
#'   `_spell`. In a fresh spell, the first observed year is `0` and each
#'   subsequent year without a new event increments by one; the event year
#'   itself carries the final count of the spell it closes.
#'
#' @details
#' `event` must not contain `NA`. `add_conflict()`'s output frequently has
#' `NA` for country-years unmatched by the source (documented behavior:
#' absence from a source is not evidence of zero events), and a spell count
#' cannot be computed across a gap of unknown conflict status. Filter or
#' otherwise resolve these `NA`s before calling `add_spell_duration()`.
#'
#' @examples
#' panel <- build_states_panel(1990, 2010, coding_system = "gw") |>
#'   add_conflict(dataset = "ucdp_prio") |>
#'   tidyr::drop_na(ucdp_prio_onset) |>
#'   add_spell_duration(event = "ucdp_prio_onset")
#'
#' @export
add_spell_duration <- function(panel, event = NULL, ongoing = NULL) {
  coding_system <- detect_coding_system(panel)

  if (is.null(event)) {
    candidates <- grep("_(onset|incidence|ongoing)$", names(panel), value = TRUE)
    if (length(candidates) == 0L) {
      stop(
        "No column in `panel` ends in '_onset', '_incidence', or '_ongoing'. ",
        "Specify `event` explicitly.",
        call. = FALSE
      )
    }
    if (length(candidates) > 1L) {
      stop(
        "Multiple candidate conflict columns found (",
        paste(candidates, collapse = ", "),
        "). Specify `event` explicitly.",
        call. = FALSE
      )
    }
    event <- candidates
  } else {
    if (!event %in% names(panel)) {
      stop("`event` column '", event, "' not found in `panel`.", call. = FALSE)
    }
  }

  if (is.null(ongoing)) {
    ongoing <- grepl("_(incidence|ongoing)$", event)
  }
  check_flag(ongoing, "ongoing")

  spell_col <- paste0(sub("_(onset|incidence|ongoing)$", "", event), "_spell")
  if (spell_col %in% names(panel)) {
    stop(
      "`panel` already has a column named '", spell_col, "'. ",
      "Rename or remove it before continuing.",
      call. = FALSE
    )
  }

  if (any(is.na(panel[[event]]))) {
    stop(
      "`", event, "` contains NA values, which add_spell_duration() cannot span. ",
      "Filter these rows (e.g. tidyr::drop_na(", event, ")) before continuing.",
      call. = FALSE
    )
  }
  if (!all(panel[[event]] %in% c(0L, 1L))) {
    stop("`", event, "` must be binary (0/1).", call. = FALSE)
  }

  panel[[spell_col]] <- compute_spells(
    unit    = panel[[coding_system]],
    year    = panel$year,
    event   = panel[[event]],
    ongoing = ongoing
  )

  panel
}


#' Compute a BTSCS spell/duration counter
#'
#' @param unit Cross-sectional unit identifier, one value per row.
#' @param year Integer year, one value per row.
#' @param event Binary (0/1) event indicator, one value per row.
#' @param ongoing Logical. See [add_spell_duration()].
#'
#' @return An integer vector of spell values, one per input row (in the
#'   original row order).
#'
#' @keywords internal
compute_spells <- function(unit, year, event, ongoing) {
  data <- data.frame(
    orig_order = seq_along(unit), unit = unit, year = year, event = event
  ) |>
    dplyr::arrange(.data$unit, .data$year) |>
    dplyr::group_by(.data$unit)

  if (ongoing) {
    data <- data |>
      dplyr::mutate(
        failure    = pmax(0L, .data$event - dplyr::lag(.data$event, default = 0L)),
        is_ongoing = as.integer(.data$event == 1L & .data$failure == 0L)
      )
  } else {
    data <- data |>
      dplyr::mutate(failure = .data$event, is_ongoing = 0L)
  }

  data <- data |>
    dplyr::mutate(
      end_spell = as.integer(.data$year == max(.data$year) | .data$failure == 1L),
      spell_id  = rev(cumsum(rev(.data$end_spell))),
      spell_id  = dplyr::if_else(.data$is_ongoing == 1L, NA_integer_, .data$spell_id)
    ) |>
    dplyr::ungroup() |>
    dplyr::group_by(.data$unit, .data$spell_id) |>
    dplyr::arrange(.data$year, .by_group = TRUE) |>
    dplyr::mutate(
      spell = dplyr::if_else(
        is.na(.data$spell_id), NA_integer_, .data$year - min(.data$year)
      )
    ) |>
    dplyr::ungroup() |>
    dplyr::arrange(.data$orig_order)

  data$spell
}
