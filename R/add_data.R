#' Add GDP data to a state panel
#'
#' @description
#' Joins GDP data onto an existing state panel. The coding system (`"cow"` or
#' `"gw"`) and year range are detected automatically from the panel.
#'
#' @param panel A data frame produced by `build_states_panel()`, containing
#'   a `cow` or `gw` column and a `year` column.
#' @param dataset Dataset to use: `"gapminder"` (default) or `"fariss"`.
#'   See `load_gdp_data()` for details and added columns.
#'
#' @return The input panel with GDP columns added via left join.
#'
#' @references
#' Gapminder. (2024). *GDP per capita in constant PPP dollars*.
#' \url{https://www.gapminder.org/gdp-per-capita/}
#'
#' Fariss, C. J., Anders, T., Markowitz, J. N., & Barnum, M. (2022). New
#' estimates of over 500 years of historic GDP and population data.
#' *Journal of Conflict Resolution*, 66(3), 553-591. \doi{10.1177/00220027211054432}
#'
#' @examples
#' panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
#'   add_gdp()
#'
#' panel <- build_states_panel(1900, 2010, coding_system = "cow") |>
#'   add_gdp(dataset = "fariss")
#'
#' @export
add_gdp <- function(panel, dataset = c("gapminder", "fariss")) {
  dataset       <- match.arg(dataset)
  coding_system <- detect_coding_system(panel)
  yr <- range(panel$year, na.rm = TRUE)

  gdp <- load_gdp_data(
    start_year    = yr[1],
    end_year      = yr[2],
    dataset       = dataset,
    coding_system = coding_system
  )

  dplyr::left_join(panel, gdp, by = c(coding_system, "year"))
}


#' Add population data to a state panel
#'
#' @description
#' Joins country-year population data onto an existing state panel. The
#' coding system and year range are detected automatically from the panel.
#'
#' @param panel A data frame produced by `build_states_panel()`.
#' @param dataset Dataset to use: `"wpp"` (default), `"nmc"`, or `"fariss"`.
#'   See `load_population_data()` for details and added columns.
#'
#' @return The input panel with population columns added via left join.
#'
#' @references
#' United Nations, Department of Economic and Social Affairs, Population
#' Division. (2024). *World Population Prospects 2024*.
#' \url{https://population.un.org/wpp/}
#'
#' Fariss, C. J., Anders, T., Markowitz, J. N., & Barnum, M. (2022). New
#' estimates of over 500 years of historic GDP and population data.
#' *Journal of Conflict Resolution*, 66(3), 553-591. \doi{10.1177/00220027211054432}
#'
#' Singer, J. D., Bremer, S., & Stuckey, J. (1972). Capability distribution,
#' uncertainty, and major power war, 1820-1965. In B. Russett (Ed.), *Peace,
#' War, and Numbers* (pp. 19-48). Sage.
#'
#' Singer, J. D. (1988). Reconstructing the Correlates of War dataset on
#' material capabilities of states, 1816-1985. *International Interactions*,
#' 14, 115-132.
#'
#' @examples
#' panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
#'   add_population(dataset = "wpp")
#'
#' panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
#'   add_population(dataset = "nmc")
#'
#' @export
add_population <- function(panel, dataset = c("wpp", "nmc", "fariss")) {
  dataset       <- match.arg(dataset)
  coding_system <- detect_coding_system(panel)
  yr            <- range(panel$year, na.rm = TRUE)

  pop <- load_population_data(
    start_year    = yr[1],
    end_year      = yr[2],
    dataset       = dataset,
    coding_system = coding_system
  )

  dplyr::left_join(panel, pop, by = c(coding_system, "year"))
}


#' Add military expenditure data to a state panel
#'
#' @description
#' Joins country-year military expenditure data onto an existing state
#' panel. The coding system and year range are detected automatically from
#' the panel.
#'
#' @param panel A data frame produced by `build_states_panel()`.
#' @param dataset Dataset to use: `"sipri"` (default), `"nmc"`, or
#'   `"barnum"`. See `load_military_expenditure_data()` for details and
#'   added columns.
#'
#' @return The input panel with military expenditure columns added via left
#'   join.
#'
#' @references
#' Singer, J. D., Bremer, S., & Stuckey, J. (1972). Capability distribution,
#' uncertainty, and major power war, 1820-1965. In B. Russett (Ed.), *Peace,
#' War, and Numbers* (pp. 19-48). Sage.
#'
#' Singer, J. D. (1988). Reconstructing the Correlates of War dataset on
#' material capabilities of states, 1816-1985. *International Interactions*,
#' 14, 115-132.
#'
#' Stockholm International Peace Research Institute. (2025). *SIPRI
#' Military Expenditure Database*. \doi{10.55163/CQGC9685}
#'
#' Barnum, M., Fariss, C. J., Markowitz, J. N., & Morales, G. (2025).
#' Measuring arms: Introducing the Global Military Spending Dataset.
#' *Journal of Conflict Resolution*, 69(2-3), 540-567. \doi{10.1177/00220027241232964}
#'
#' @examples
#' panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
#'   add_military_expenditure()
#'
#' panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
#'   add_military_expenditure(dataset = "nmc")
#'
#' @export
add_military_expenditure <- function(panel, dataset = c("sipri", "nmc", "barnum")) {
  dataset       <- match.arg(dataset)
  coding_system <- detect_coding_system(panel)
  yr            <- range(panel$year, na.rm = TRUE)

  milex <- load_military_expenditure_data(
    start_year    = yr[1],
    end_year      = yr[2],
    dataset       = dataset,
    coding_system = coding_system
  )

  dplyr::left_join(panel, milex, by = c(coding_system, "year"))
}


#' Add V-Dem indicators to a state panel
#'
#' @description
#' Joins V-Dem country-year data onto an existing state panel. The coding
#' system and year range are detected automatically from the panel.
#'
#' Requires the `vdemdata` package:
#' `remotes::install_github("vdeminstitute/vdemdata")`
#'
#' @param panel A data frame produced by `build_states_panel()`.
#' @param vars Character vector of V-Dem variable names. If `NULL`, a default
#'   set of democracy, civil liberties, civil society, and rule-of-law
#'   indicators is used. See `load_vdem_data()` for the full default list.
#'
#' @return The input panel with V-Dem columns added via left join.
#'
#' @references
#' Coppedge, M., Gerring, J., Knutsen, C. H., Lindberg, S. I., Teorell, J.,
#' Altman, D., Bernhard, M., Fish, M. S., Glynn, A., Hicken, A., et al.
#' (2025). *V-Dem \[Country-Year/Country-Date\] Dataset v15*. Varieties of
#' Democracy.
#'
#' @examples
#' if (requireNamespace("vdemdata", quietly = TRUE)) {
#' panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
#'   add_vdem(vars = c("v2x_polyarchy", "v2x_libdem", "v2x_rule"))
#' }
#'
#' @export
add_vdem <- function(panel, vars = NULL) {
  coding_system <- detect_coding_system(panel)
  yr <- range(panel$year, na.rm = TRUE)

  vdem <- load_vdem_data(
    vars          = vars,
    start_year    = yr[1],
    end_year      = yr[2],
    coding_system = coding_system
  )

  dplyr::left_join(panel, vdem, by = c(coding_system, "year"))
}


#' Add conflict or protest data to a state panel
#'
#' @description
#' Joins a conflict, protest, or revolutionary episode dataset onto an existing
#' state panel at the country-year level.
#'
#' **Country-year datasets** (`"scad"`, `"ucdp_prio"`, `"ucdp_vpp"`, `"mm"`,
#' `"mmad"`) are already at the country-year level when loaded, so the
#' `aggregate` argument has no effect for them.
#'
#' **Campaign and episode datasets** (`"navco1.3"`, `"navco2.1"`,
#' `"beissinger"`, `"csra"`, `"mec"`) can have multiple rows per country-year.
#' With `aggregate = TRUE` (the default) these are collapsed to country-year
#' by taking the maximum of all numeric columns, and an `n_campaigns` count
#' column is added. Set `aggregate = FALSE` to keep campaign-level rows (may
#' produce duplicates).
#'
#' @param panel A data frame produced by `build_states_panel()`.
#' @param dataset Dataset to load. One of:
#'   \describe{
#'     \item{`"navco1.3"`}{NAVCO 1.3 campaign onsets (1900-2019).}
#'     \item{`"navco2.1"`}{NAVCO 2.1 campaign-years (1945-2013).}
#'     \item{`"beissinger"`}{Beissinger revolutionary episode onsets (1900-2014).}
#'     \item{`"csra"`}{HSE CSRA revolutionary episodes (2000-2024).}
#'     \item{`"scad"`}{SCAD 2018 social conflict events, Africa and Latin America
#'       (recorded starts 1989-2017). Prefix: `scad_`.}
#'     \item{`"ucdp_prio"`}{UCDP/PRIO Armed Conflict Dataset v26.1 (1946-2025).
#'       Prefix: `ucdp_prio_`.}
#'     \item{`"ucdp_vpp"`}{UCDP Violent Political Protest v26.1 (1989-2025).
#'       Prefix: `ucdp_vpp_`. Requires the `readxl` package.}
#'     \item{`"mm"`}{Mass Mobilization Project v4 (1990-2020). Prefix: `mm_`.}
#'     \item{`"mmad"`}{Mass Mobilization in Autocracies Database (2003-2022).
#'       Prefix: `mmad_`.}
#'     \item{`"mec"`}{Major Episodes of Contention (1955-2018), with global
#'       episode-level coverage. Prefix: `mec_`.}
#'   }
#' @param aggregate Logical. If `TRUE` (default), aggregates to country-year
#'   before joining (relevant for campaign and episode datasets only). If
#'   `FALSE`, performs a raw left join.
#'
#' @return The input panel with conflict/protest columns added via left join.
#'   Unmatched country-years remain `NA`; the function does not assume that an
#'   unobserved event indicator is zero.
#'
#' @references
#' Chenoweth, E., & Shay, C. W. (2020). *List of Campaigns in NAVCO 1.3*.
#' Harvard Dataverse. \doi{10.7910/DVN/ON9XND/PTMCCV}
#'
#' Chenoweth, E., & Shay, C. W. (2019). *NAVCO 2.1 Dataset*. Harvard
#' Dataverse. \doi{10.7910/DVN/MHOXDV}
#'
#' Beissinger, M. (2022). *Revolutionary Episodes Dataset*.
#'
#' Ustyuzhanin, V., Korotayev, A., & Semichev, D. (2025). *Revolutions
#' Dataset*. HSE University, Centre for Stability and Risk Analysis.
#'
#' Salehyan, I., Hendrix, C. S., Hamner, J., Case, C., Linebarger, C.,
#' Stull, E., & Williams, J. (2012). Social conflict in Africa: A new
#' database. *International Interactions*, 38(4), 503-511.
#' \doi{10.1080/03050629.2012.697426}
#'
#' Gleditsch, N. P., Wallensteen, P., Eriksson, M., Sollenberg, M., &
#' Strand, H. (2002). Armed conflict 1946-2001: A new dataset. *Journal of
#' Peace Research*, 39(5), 615-637. \doi{10.1177/0022343302039005007}
#'
#' Svensson, I., Schaftenaar, S., & Allansson, M. (2022). Violent political
#' protest: Introducing a new Uppsala Conflict Data Program data set on
#' organized violence, 1989-2019. *Journal of Conflict Resolution*, 66(9),
#' 1703-1730.
#'
#' Clark, D. H., & Regan, P. M. (2016). *Mass Mobilization Protest Data*.
#' Harvard Dataverse. \doi{10.7910/DVN/HTTWYL}
#'
#' Weidmann, N. B., & Rød, E. G. (2019). *The Internet and Political
#' Protest in Autocracies*. Oxford University Press.
#'
#' Chenoweth, E., & Kang, S. (2026). The Major Episodes of Contention (MEC)
#' Data Project: An introduction. *Journal of Peace Research*.
#' \doi{10.1093/jopres/xjaf008}
#'
#' @examples
#' panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
#'   add_conflict(dataset = "navco2.1")
#'
#' panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
#'   add_conflict(dataset = "ucdp_prio")
#'
#' panel <- build_states_panel(2005, 2020, coding_system = "cow") |>
#'   add_conflict(dataset = "mmad")
#'
#' # Raw join for legacy datasets — researcher handles aggregation manually
#' panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
#'   add_conflict(dataset = "navco1.3", aggregate = FALSE)
#'
#' # MEC is episode-level; keep individual episodes with aggregate = FALSE
#' panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
#'   add_conflict(dataset = "mec", aggregate = FALSE)
#'
#' @export
add_conflict <- function(panel, dataset, aggregate = TRUE) {
  check_flag(aggregate, "aggregate")
  coding_system <- detect_coding_system(panel)
  yr <- range(panel$year, na.rm = TRUE)

  conflicts <- conflict_data(
    start_year    = yr[1],
    end_year      = yr[2],
    dataset       = dataset,
    coding_system = coding_system
  )

  id_col <- coding_system

  campaign_dataset <- dataset %in% c(
    "navco1.3", "navco2.1", "beissinger", "csra", "mec"
  )

  if (aggregate && campaign_dataset) {
    has_dupes <- conflicts |>
      dplyr::count(.data[[id_col]], .data$year) |>
      dplyr::filter(.data$n > 1) |>
      nrow() > 0

    if (has_dupes) {
      message(
        "Multiple campaigns or episodes per country-year detected in '",
        dataset, "'. ",
        "Aggregating to country-year using max() for numeric columns. ",
        "Use `aggregate = FALSE` or `conflict_data()` for record-level data."
      )
    }

    conflicts <- conflicts |>
      dplyr::group_by(.data[[id_col]], .data$year) |>
      dplyr::mutate(n_campaigns = dplyr::n()) |>
      dplyr::summarise(
        dplyr::across(dplyr::where(is.numeric), safe_max),
        .groups = "drop"
      )
  }

  dplyr::left_join(panel, conflicts, by = c(id_col, "year"))
}


#' Add leader data to a state panel
#'
#' @description
#' Joins country-year leader data onto an existing state panel. The coding
#' system and year range are detected automatically from the panel.
#'
#' Each country-year is assigned the leader who held power at the end of that
#' year (i.e., the leader with the latest start date when multiple leaders
#' served in the same year).
#'
#' @param panel A data frame produced by `build_states_panel()`.
#' @param dataset Dataset to use: `"archigos"` (default) or `"reign"`.
#'   See `load_leader_data()` for details.
#'
#' @return The input panel with leader columns added via left join.
#'
#' @references
#' Goemans, H. E., Gleditsch, K. S., & Chiozza, G. (2009). Introducing
#' Archigos: A dataset of political leaders. *Journal of Peace Research*,
#' 46(2), 269-283.
#'
#' Bell, C., Besaw, C., & Frank, M. (2021). *The Rulers, Elections, and
#' Irregular Governance (REIGN) Dataset*.
#'
#' @examples
#' panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
#'   add_leader_data(dataset = "archigos")
#'
#' panel <- build_states_panel(1990, 2010, coding_system = "cow") |>
#'   add_leader_data(dataset = "reign")
#'
#' @export
add_leader_data <- function(panel, dataset = c("archigos", "reign")) {
  dataset       <- match.arg(dataset)
  coding_system <- detect_coding_system(panel)
  yr            <- range(panel$year, na.rm = TRUE)

  leaders <- load_leader_data(
    start_year    = yr[1],
    end_year      = yr[2],
    dataset       = dataset,
    coding_system = coding_system
  )

  dplyr::left_join(panel, leaders, by = c(coding_system, "year"))
}
