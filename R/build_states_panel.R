#' Build a state panel
#'
#' @param start_year First year. Must be `1816` or later.
#' @param end_year Last year. Must be `2025` or earlier.
#' @param coding_system Country coding system. Either `"cow"` or `"gw"`.
#' @param exclude_microstates Logical. Exclude entities identified as
#'   microstates by [states::state_panel()].
#' @param exclude_non_un Logical. Exclude the package's fixed set of non-UN
#'   entities (Kosovo, Taiwan, Hong Kong, the European Union, and South Vietnam
#'   for COW; Kosovo, Abkhazia, South Ossetia, Taiwan, and South Vietnam for
#'   GW).
#' @param exclude_islands Logical. Exclude six small Caribbean island states:
#'   Dominica, Grenada, Saint Lucia, Saint Vincent and the Grenadines, Antigua
#'   and Barbuda, and Saint Kitts and Nevis.
#' @param unit Time unit of the panel: `"year"` (default), `"quarter"`,
#'   `"month"`, or `"day"`. A state is included in a period if it was a
#'   member of the state system for any part of that period.
#'
#' @return A data frame with one row per state and period. A country-year
#'   panel has the country code, `year`, and `country`; a country-quarter
#'   panel adds `quarter` (1-4); a country-month panel adds `month` (1-12); a
#'   country-day panel adds `month`, `day`, and `date`.
#'
#' @details
#' Annual data (`add_gdp()`, `add_population()`, `add_military_expenditure()`,
#' `add_vdem()`) are joined to a country-quarter, country-month, or
#' country-day panel by country and year, so every period of a year takes
#' that year's value. `add_leader_data()` uses the leaders' exact dates in
#' office, and `add_conflict()` aggregates event data to the panel's own
#' unit, for the datasets that record exact event dates. `add_lag()` and
#' `add_spell_duration()` count periods in the panel's unit. Use
#' [aggregate_panel()] to collapse a finer panel to a coarser unit.
#'
#' A country-day panel is large (about 70,000 rows per year of data), so
#' restrict it to the years you need.
#'
#' @examples
#' yearly  <- build_states_panel(1990, 2000, coding_system = "cow")
#' quarterly <- build_states_panel(2010, 2012, coding_system = "cow", unit = "quarter")
#' monthly <- build_states_panel(2010, 2012, coding_system = "gw", unit = "month")
#' daily   <- build_states_panel(2011, 2011, coding_system = "cow", unit = "day")
#'
#' @export
build_states_panel <- function(
    start_year = 1946,
    end_year = 2013,
    coding_system = c("cow", "gw"),
    exclude_microstates = TRUE,
    exclude_non_un = TRUE,
    exclude_islands = FALSE,
    unit = c("year", "quarter", "month", "day")
) {
  check_year_range(start_year, end_year, min_year = 1816, max_year = 2025)
  check_flag(exclude_microstates, "exclude_microstates")
  check_flag(exclude_non_un, "exclude_non_un")
  check_flag(exclude_islands, "exclude_islands")
  coding_system <- match.arg(coding_system)
  unit <- match.arg(unit)
  if (coding_system == "cow") {
    return(
      build_states_cow_panel(
        start_year = start_year,
        end_year = end_year,
        exclude_microstates = exclude_microstates,
        exclude_non_un = exclude_non_un,
        exclude_islands = exclude_islands,
        unit = unit
      )
    )
  }
  if (coding_system == "gw") {
    return(
      build_states_gw_panel(
        start_year = start_year,
        end_year = end_year,
        exclude_microstates = exclude_microstates,
        exclude_non_un = exclude_non_un,
        exclude_islands = exclude_islands,
        unit = unit
      )
    )
  }
}

#' Build a COW-coded state panel
#'
#' @inheritParams build_states_panel
#'
#' @return A data frame with COW-coded state-year observations.
#'
#' @keywords internal
build_states_cow_panel <- function(
    start_year = 1946,
    end_year = 2013,
    exclude_microstates = TRUE,
    exclude_non_un = TRUE,
    exclude_islands = FALSE,
    unit = "year"
) {

  check_year_range(start_year, end_year, min_year = 1816, max_year = 2025)
  check_flag(exclude_microstates, "exclude_microstates")
  check_flag(exclude_non_un, "exclude_non_un")
  check_flag(exclude_islands, "exclude_islands")

  microstates <- states::cowstates |>
    dplyr::filter(.data$microstate) |>
    dplyr::distinct(.data$cowcode)

  states <- state_panel_by_unit(start_year, end_year, unit, useGW = FALSE) |>
    dplyr::rename(cow = "cowcode")

  #Exclude Kosovo, Taiwan, Hong Kong, EU, South Vietnam
  if (exclude_non_un) {
    non_un_entities <- c(347, 713, 817, 995, 997)
    states <- states |>
      dplyr::filter(!.data$cow %in% non_un_entities)
  }

  # Exclude six small Caribbean island states.
  if (exclude_islands) {
    small_island_states <- c(54, 55, 56, 57, 58, 60)
    states <- states |>
      dplyr::filter(!.data$cow %in% small_island_states)
  }

  if (exclude_microstates) {
    states <- states |>
      dplyr::filter(!(.data$cow %in% microstates$cowcode))
  }

  states <- states |>
    dplyr::mutate(
      country = state_names(.data$cow, "cow"),
      country = ifelse(.data$cow == 260, "German Federal Republic", .data$country),
      country = ifelse(.data$country == "Yugoslavia" & .data$year >= 2006, "Serbia", .data$country),
      cow = dplyr::case_when(
        .data$cow == 315 ~ 316,
        .data$cow == 260 ~ 255,
        TRUE ~ .data$cow
      )
    ) |>
    tidyr::drop_na("country")

  # COW 260 (German Federal Republic) is recoded to 255 (Germany) above. In
  # the period of unification (1990, or October 1990 in a monthly panel)
  # both appear; keep the unified Germany row.
  keys <- c("cow", time_keys(unit))
  gfr_overlap <- states$cow == 255 &
    states$country == "German Federal Republic" &
    (duplicated(states[keys]) | duplicated(states[keys], fromLast = TRUE))
  states <- states[!gfr_overlap, ]
  states <- dplyr::arrange(states, dplyr::across(dplyr::all_of(keys)))

  check_unique_key(states, keys)

  return(states)
}

build_states_gw_panel <- function(
    start_year = 1946,
    end_year = 2013,
    exclude_microstates = TRUE,
    exclude_non_un = TRUE,
    exclude_islands = FALSE,
    unit = "year"
) {

  check_year_range(start_year, end_year, min_year = 1816, max_year = 2025)
  check_flag(exclude_microstates, "exclude_microstates")
  check_flag(exclude_non_un, "exclude_non_un")
  check_flag(exclude_islands, "exclude_islands")

  microstates <- states::gwstates |>
    dplyr::filter(.data$microstate) |>
    dplyr::distinct(.data$gwcode)

  states <- state_panel_by_unit(start_year, end_year, unit, useGW = TRUE) |>
    dplyr::rename(gw = "gwcode")

  #Exclude Kosovo, Abkhazia, South Ossetia, Taiwan, South Vietnam
  if (exclude_non_un) {
    non_un_entities <- c(347, 396, 397, 713, 817)
    states <- states |>
      dplyr::filter(!.data$gw %in% non_un_entities)
  }

  # Exclude six small Caribbean island states.
  if (exclude_islands) {
    small_island_states <- c(54, 55, 56, 57, 58, 60)
    states <- states |>
      dplyr::filter(!.data$gw %in% small_island_states)
  }

  if (exclude_microstates) {
    states <- states |>
      dplyr::filter(!(.data$gw %in% microstates$gwcode))
  }

  states <- states |>
    dplyr::mutate(
      country = state_names(.data$gw, "gw"),
      country = ifelse(.data$gw == 260, "German Federal Republic", .data$country),
      country = ifelse(.data$gw == 255, "Germany", .data$country),
      country = ifelse(.data$country == "Yugoslavia" & .data$year >= 2006, "Serbia", .data$country)
    ) |>
    tidyr::drop_na("gw", "country")

  keys <- c("gw", time_keys(unit))
  states <- dplyr::arrange(states, dplyr::across(dplyr::all_of(keys)))

  check_unique_key(states, keys)

  return(states)
}

#' State-system membership panel at a given time unit
#'
#' @param start_year,end_year First and last year.
#' @param unit `"year"`, `"quarter"`, `"month"`, or `"day"`.
#' @param useGW Logical, passed to [states::state_panel()].
#'
#' @return A data frame with `cowcode` or `gwcode`, `year`, and, for
#'   sub-annual units, `quarter` or `month` (and `day` and `date` for
#'   `"day"`).
#'
#' @keywords internal
state_panel_by_unit <- function(start_year, end_year, unit, useGW) {
  if (unit == "year") {
    return(states::state_panel(
      start = start_year, end = end_year, by = "year", useGW = useGW
    ))
  }

  out <- states::state_panel(
    start = as.Date(sprintf("%04d-01-01", as.integer(start_year))),
    end   = as.Date(sprintf("%04d-12-31", as.integer(end_year))),
    by    = if (unit == "quarter") "month" else unit,
    useGW = useGW
  )
  out$year  <- as.integer(format(out$date, "%Y"))
  out$month <- as.integer(format(out$date, "%m"))
  if (unit == "day") {
    out$day <- as.integer(format(out$date, "%d"))
    out <- out[c(setdiff(names(out), "date"), "date")]
  } else {
    out$date <- NULL
  }
  if (unit == "quarter") {
    # A state is in a quarter if it was in the state system in any month of
    # it.
    code <- if (useGW) "gwcode" else "cowcode"
    out$quarter <- (out$month - 1L) %/% 3L + 1L
    out <- out[!duplicated(out[c(code, "year", "quarter")]), ]
    out$month <- NULL
  }
  out
}
