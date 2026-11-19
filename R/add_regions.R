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
  # States countrycode does not code in this system, matched through their
  # ISO code: Serbia (COW 345; GW 340 and 345), Kosovo (347), Yemen (GW
  # 678), the Czech Republic and Czechoslovakia (GW 315, 316), Vietnam (GW
  # 816), and Germany.
  iso_fallback <- if (coding_system == "cow") {
    c("345" = "SRB", "347" = "XKX", "255" = "DEU")
  } else {
    c("340" = "SRB", "345" = "SRB", "347" = "XKX", "678" = "YEM",
      "315" = "CZE", "316" = "CZE", "816" = "VNM", "255" = "DEU",
      "260" = "DEU")
  }
  iso <- unname(iso_fallback[as.character(units)])
  for (r in region) {
    values <- suppressWarnings(
      countrycode::countrycode(units, origin, r)
    )
    missing <- is.na(values) & !is.na(iso)
    values[missing] <- suppressWarnings(
      countrycode::countrycode(iso[missing], "iso3c", r)
    )
    lookup[[r]] <- values
  }

  dplyr::left_join(panel, lookup, by = coding_system)
}
