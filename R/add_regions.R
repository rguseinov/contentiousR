#' Add region names to a state panel
#'
#' @description
#' Joins region names onto an existing state panel via
#' `countrycode::countrycode()`, mapping the panel's `cow`/`gw` codes to one
#' or more of `countrycode`'s regional classifications. The coding system is
#' detected automatically from the panel.
#'
#' @param panel A data frame produced by `build_states_panel()`, containing
#'   a `cow` or `gw` column.
#' @param region Character vector selecting one or more `countrycode`
#'   destination classifications to add, from:
#'   * `"region"` (default): World Bank 7-region classification.
#'   * `"region23"`: World Bank's finer, 23-region classification.
#'   * `"un.region.name"`: UN macro-region (continent-level).
#'   * `"un.regionsub.name"`: UN sub-region.
#'
#'   See `countrycode::countrycode()` for details on these classifications.
#'
#' @return The input panel with one additional column per entry in
#'   `region`, named after the classification (e.g. `region`, `region23`),
#'   holding the corresponding region name for each row (`NA` where
#'   `countrycode()` finds no match).
#'
#' @examples
#' panel <- build_states_panel(1990, 2000, coding_system = "cow") |>
#'   add_regions()
#'
#' panel <- build_states_panel(1990, 2000, coding_system = "cow") |>
#'   add_regions(region = c("region", "un.regionsub.name"))
#'
#' @export
add_regions <- function(panel, region = "region") {
  coding_system <- detect_coding_system(panel)

  valid_regions <- c("region", "region23", "un.region.name", "un.regionsub.name")
  if (!is.character(region) || length(region) == 0L || anyNA(region) ||
        !all(region %in% valid_regions)) {
    stop(
      "`region` must be one or more of: ", paste(valid_regions, collapse = ", "),
      call. = FALSE
    )
  }
  region <- unique(region)

  collisions <- intersect(region, names(panel))
  if (length(collisions) > 0L) {
    stop(
      "`panel` already has column(s): ", paste(collisions, collapse = ", "),
      call. = FALSE
    )
  }

  origin <- if (coding_system == "cow") "cown" else "gwn"
  units  <- unique(panel[[coding_system]])

  lookup <- data.frame(unit = units)
  names(lookup) <- coding_system
  for (r in region) {
    lookup[[r]] <- suppressWarnings(
      countrycode::countrycode(units, origin, r)
    )
  }

  dplyr::left_join(panel, lookup, by = coding_system)
}
