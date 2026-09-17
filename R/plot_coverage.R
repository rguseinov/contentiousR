#' Plot country-year onset/event coverage of a binary variable
#'
#' @description
#' Draws a country-by-year heatmap of a binary (0/1) event column: `1`
#' years are shaded as an event, `0` years as no event, and years where the
#' state does not appear in `panel` at all (e.g. before independence) or
#' `var` is `NA` are left blank. Useful for eyeballing when and where
#' events (e.g. conflict onsets) actually occurred, as opposed to just
#' where a source has any data.
#'
#' @param panel A data frame produced by `build_states_panel()`, containing
#'   a `cow` or `gw` column, a `year` column, and `var`.
#' @param var Character. Name of a binary (0/1) column in `panel`, such as
#'   `"ucdp_prio_onset"`.
#' @param drop_empty Logical. If `TRUE` (default), drop states with zero
#'   years where `var == 1` before plotting. A state that never has the
#'   event contributes a row with no blue tiles at all, which adds clutter
#'   without showing where/when events happened; set to `FALSE` to include
#'   these states anyway.
#'
#' @return A `ggplot` object (one tile per country-year, filled by
#'   `"Event"` / `"No event"`, with unobserved country-years left blank).
#'   States are ordered top-to-bottom by their number of events, most first.
#'   Requires the `ggplot2` package.
#'
#' @examples
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   build_states_panel(1990, 2015, coding_system = "cow") |>
#'     add_conflict("ucdp_prio") |>
#'     plot_coverage("ucdp_prio_onset")
#' }
#'
#' @export
plot_coverage <- function(panel, var, drop_empty = TRUE) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop(
      "Package 'ggplot2' is required for plot_coverage(). ",
      "Install it with: install.packages('ggplot2')",
      call. = FALSE
    )
  }

  coding_system <- detect_coding_system(panel)

  if (!var %in% names(panel)) {
    stop("Column '", var, "' not found in `panel`.", call. = FALSE)
  }
  if (!all(panel[[var]] %in% c(0L, 1L, NA))) {
    stop("`var` must be binary (0/1, with NA for unobserved years).", call. = FALSE)
  }
  check_flag(drop_empty, "drop_empty")

  label_col <- if ("country" %in% names(panel)) "country" else coding_system

  # One row per state-year that actually exists in `panel`; any (label, year)
  # combination absent from this stays blank ("not observed") below, the
  # same as a genuine NA.
  existing <- panel |>
    dplyr::transmute(
      label  = .data[[label_col]],
      year   = .data$year,
      status = dplyr::case_when(
        .data[[var]] == 1 ~ "Event",
        .data[[var]] == 0 ~ "No event",
        TRUE ~ NA_character_
      )
    ) |>
    dplyr::distinct()

  events_by_label <- existing |>
    dplyr::group_by(.data$label) |>
    dplyr::summarise(n_events = sum(.data$status == "Event", na.rm = TRUE), .groups = "drop") |>
    dplyr::arrange(.data$n_events)

  if (drop_empty) {
    events_by_label <- events_by_label[events_by_label$n_events > 0, ]
    existing <- existing[existing$label %in% events_by_label$label, ]
  }

  plot_data <- tidyr::expand_grid(
    label = events_by_label$label,
    year  = seq(min(existing$year), max(existing$year))
  ) |>
    dplyr::left_join(existing, by = c("label", "year"))

  plot_data$label  <- factor(plot_data$label, levels = events_by_label$label)
  plot_data$status <- factor(plot_data$status, levels = c("Event", "No event"))

  ggplot2::ggplot(
    plot_data,
    ggplot2::aes(x = .data$year, y = .data$label, fill = .data$status)
  ) +
    ggplot2::geom_tile(color = "white", linewidth = 0.1) +
    ggplot2::scale_fill_manual(
      name   = NULL,
      values = c("Event" = "#2c7fb8", "No event" = "grey80"),
      na.value = "white",
      na.translate = FALSE,
      drop = FALSE
    ) +
    ggplot2::labs(x = "Year", y = NULL, title = paste("Coverage of", var)) +
    ggplot2::theme_minimal() +
    ggplot2::theme(axis.text.y = ggplot2::element_text(size = 6))
}
