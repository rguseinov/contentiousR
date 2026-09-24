#' Build a state panel
#'
#' @param start_year First year. Must be `1816` or later.
#' @param end_year Last year. Must be `2025` or earlier.
#' @param coding_system Country coding system. Either `"cow"` or `"gw"`.
#' @param exclude_microstates Logical. Exclude entities identified as
#'   microstates by [states::state_panel()].
#' @param exclude_non_un Logical. Exclude the package's fixed set of non-UN
#'   entities (Kosovo, Taiwan, Hong Kong, the European Union, and South Vietnam
#'   for COW; Kosovo, Taiwan, and South Vietnam for GW).
#' @param exclude_islands Logical. Exclude six small Caribbean island states:
#'   Dominica, Grenada, Saint Lucia, Saint Vincent and the Grenadines, Antigua
#'   and Barbuda, and Saint Kitts and Nevis.
#'
#' @return A data frame with state-year observations.
#'
#' @export
build_states_panel <- function(
    start_year = 1946,
    end_year = 2013,
    coding_system = c("cow", "gw"),
    exclude_microstates = TRUE,
    exclude_non_un = TRUE,
    exclude_islands = FALSE
) {
  check_year_range(start_year, end_year, min_year = 1816, max_year = 2025)
  check_flag(exclude_microstates, "exclude_microstates")
  check_flag(exclude_non_un, "exclude_non_un")
  check_flag(exclude_islands, "exclude_islands")
  coding_system <- match.arg(coding_system)
  if (coding_system == "cow") {
    return(
      build_states_cow_panel(
        start_year = start_year,
        end_year = end_year,
        exclude_microstates = exclude_microstates,
        exclude_non_un = exclude_non_un,
        exclude_islands = exclude_islands
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
        exclude_islands = exclude_islands
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
    exclude_islands = FALSE
) {

  check_year_range(start_year, end_year, min_year = 1816, max_year = 2025)
  check_flag(exclude_microstates, "exclude_microstates")
  check_flag(exclude_non_un, "exclude_non_un")
  check_flag(exclude_islands, "exclude_islands")

  microstates <- states::cowstates |>
    dplyr::filter(.data$microstate) |>
    dplyr::distinct(.data$cowcode)

  states <- states::state_panel(
    start = start_year,
    end = end_year,
    by = "year",
    useGW = FALSE
  ) |>
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
      country = suppressWarnings(countrycode::countrycode(.data$cow, "cown", "country.name")),
      country = ifelse(.data$cow == 260, "German Federal Republic", .data$country),
      country = ifelse(.data$country == "Yugoslavia" & .data$year >= 2006, "Serbia", .data$country),
      cow = dplyr::case_when(
        .data$cow == 315 ~ 316,
        .data$cow == 260 ~ 255,
        TRUE ~ .data$cow
      )
    ) |>
    tidyr::drop_na("country") |>
    dplyr::filter(!(
      .data$cow == 255 &
        .data$year == 1990 &
        .data$country == "German Federal Republic"
    )) |>
    dplyr::arrange(.data$cow, .data$year)

  check_unique_key(states, c("cow", "year"))

  return(states)
}

build_states_gw_panel <- function(
    start_year = 1946,
    end_year = 2013,
    exclude_microstates = TRUE,
    exclude_non_un = TRUE,
    exclude_islands = FALSE
) {

  check_year_range(start_year, end_year, min_year = 1816, max_year = 2025)
  check_flag(exclude_microstates, "exclude_microstates")
  check_flag(exclude_non_un, "exclude_non_un")
  check_flag(exclude_islands, "exclude_islands")

  microstates <- states::gwstates |>
    dplyr::filter(.data$microstate) |>
    dplyr::distinct(.data$gwcode)

  states <- states::state_panel(
    start = start_year,
    end = end_year,
    by = "year",
    useGW = TRUE
  ) |>
    dplyr::rename(gw = "gwcode")

  #Exclude Kosovo, Taiwan, South Vietnam
  if (exclude_non_un) {
    non_un_entities <- c(347, 713, 817)
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
      country = suppressWarnings(countrycode::countrycode(.data$gw, "gwn", "country.name")),
      country = ifelse(.data$gw == 260, "German Federal Republic", .data$country),
      country = ifelse(.data$gw == 255, "Germany", .data$country),
      country = ifelse(.data$country == "Yugoslavia" & .data$year >= 2006, "Serbia", .data$country)
    ) |>
    tidyr::drop_na("gw", "country") |>
    dplyr::arrange(.data$gw, .data$year)

  check_unique_key(states, c("gw", "year"))

  return(states)
}
