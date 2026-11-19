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
#' state panel. The panel's coding system and time unit (year, month, or day;
#' see [build_states_panel()]) are detected automatically, and the data are
#' aggregated to that unit.
#'
#' **Event and conflict-year datasets** (`"scad"`, `"ucdp_prio"`,
#' `"ucdp_vpp"`, `"mm"`, `"mmad"`, `"arc"`, `"navco3.0"`) are already
#' aggregated to the panel's unit when loaded, so the `aggregate` argument
#' has no effect for them.
#'
#' **Campaign and episode datasets** (`"navco1.3"`, `"navco2.1"`,
#' `"beissinger"`, `"raqed"`, `"mec"`, and `"omg"`)
#' can have multiple rows per country-period.
#' With `aggregate = TRUE` (the default) these are collapsed to the panel's
#' unit by taking the maximum of all numeric columns, and an `n_campaigns` count
#' column is added. Set `aggregate = FALSE` to keep campaign-level rows (may
#' produce duplicates). Onset columns mark the period in which an episode
#' started; for all of these datasets, `<prefix>incidence`
#' and `<prefix>n_active` also mark every period in which an episode was in
#' progress, from its start to its end date (see Details).
#'
#' @param panel A data frame produced by `build_states_panel()`.
#' @param dataset Dataset to load. One of:
#'   \describe{
#'     \item{`"navco1.3"`}{NAVCO 1.3 campaign onsets (1900-2019).}
#'     \item{`"navco2.1"`}{NAVCO 2.1 campaign-years (1945-2013).}
#'     \item{`"beissinger"`}{Beissinger revolutionary episode onsets (1900-2014).}
#'     \item{`"raqed"`}{RAQED v1.4 revolutionary and quasi-revolutionary
#'       episodes (2000-2026). Prefix: `raqed_`.}
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
#'     \item{`"omg"`}{Opposition Movements and Groups v1, campaign phases
#'       (1789-2019). `omg_onset` marks a campaign's first phase. Prefix:
#'       `omg_`.}
#'     \item{`"arc"`}{Anatomy of Resistance Campaigns 2.0 events with
#'       participating organizations, Africa, Latin America and the Caribbean
#'       (1990-2018). Prefix: `arc_`.}
#'     \item{`"navco3.0"`}{NAVCO 3.0 events on 26 countries (1990-2012):
#'       actions by anti-government campaigns, states, and others, with
#'       tactics, goals, and state responses. Prefix: `nvc3.0_`.}
#'   }
#' @param aggregate Logical. If `TRUE` (default), aggregates to the panel's unit
#'   before joining (relevant for campaign and episode datasets only). If
#'   `FALSE`, performs a raw left join.
#' @param fill_zero Logical. If `FALSE` (default), periods without a record
#'   are `NA`. If `TRUE`, event indicators and counts (onset, incidence,
#'   and count columns) are set to 0 in periods the dataset covers but in
#'   which it records nothing, and stay `NA` outside its coverage. See
#'   Details and [list_datasets()] for how coverage is defined.
#'
#' @return The input panel with conflict/protest columns added via left join.
#'   With `fill_zero = FALSE`, unmatched periods remain `NA`; the function
#'   does not assume that an unobserved event indicator is zero.
#'
#' @references
#' Chenoweth, E., & Shay, C. W. (2020). *List of Campaigns in NAVCO 1.3*.
#' Harvard Dataverse. \doi{10.7910/DVN/ON9XND}
#'
#' Chenoweth, E., & Shay, C. W. (2019). *NAVCO 2.1 Dataset*. Harvard
#' Dataverse. \doi{10.7910/DVN/MHOXDV}
#'
#' Beissinger, M. (2022). *Revolutionary Episodes Dataset*.
#'
#' Ustyuzhanin, V., Semichev, D., Grinin, L., & Korotaev, A. (2026). New
#' possibilities for analysing revolution: Introducing a database of
#' revolutions of the 21st century. *Russian Sociological Review*, 25(1), 9-61.
#' \doi{10.17323/1728-192X-2026-1-9-61}
#'
#' Ustyuzhanin, V., Semichev, D., Grinin, L., & Korotaev, A. (2026).
#' *Revolutionary and Quasi-revolutionary Episodes Dataset (RAQED)
#' (2000-2025)*, Version 1.4. HSE University, Centre for Stability and Risk
#' Analysis. \url{https://social.hse.ru/mr/rev_bd}
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
#' Data Project: An introduction. *Journal of Peace Research*, 63(4), 724-734.
#' \doi{10.1093/jopres/xjaf008}
#'
#' Dahl, M., Dahlum, S., Fjelde, H., Gjerløw, H., Knutsen, C. H.,
#' Strøm-Sedgwick, C., & Wig, T. (2026). Mass mobilization in the modern
#' era: Introducing the Opposition Movements and Groups (OMG) dataset,
#' 1789-2019. *Comparative Political Studies*, 59(10), 2117-2158.
#' \doi{10.1177/00104140251369330}
#'
#' Vüllers, J., Bakken, I. V., Johansen, T., Dworschak, C., Butcher, C., &
#' Braithwaite, J. M. (2026). (Un)organized protest: Introducing the Anatomy
#' of Resistance Campaigns 2.0. *Journal of Peace Research*, 63(3), 484-494.
#' \doi{10.1093/jopres/xjag013}
#'
#' Chenoweth, E., Pinckney, J., & Lewis, O. (2018). Days of rage: Introducing
#' the NAVCO 3.0 dataset. *Journal of Peace Research*, 55(4), 524-534.
#' \doi{10.1177/0022343318759411}
#'
#' @details
#' **Coverage and `fill_zero`.** A missing record can mean that nothing
#' happened or that the source does not cover that country and year. With
#' `fill_zero = TRUE`, a country-year counts as covered by these rules:
#' \itemize{
#'   \item Global datasets (`"navco1.3"`, `"navco2.1"`, `"beissinger"`,
#'     `"raqed"`, `"mec"`, `"omg"`, `"ucdp_prio"`, `"ucdp_vpp"`):
#'     every state in the panel, within the dataset's years.
#'   \item Regional datasets (`"scad"`, `"arc"`, `"navco3.0"`): the
#'     countries with at least one record, within the dataset's years.
#'   \item `"mm"`: the country-years the source lists, including those it
#'     codes as having no protest.
#'   \item `"mmad"`: MMAD covers autocracies, and the package does not
#'     ship its list of autocratic country-years; a country counts as covered
#'     from the first to the last year in which MMAD records an event there.
#'     A 0 inside that span can therefore still be a period the source did
#'     not code (for example, MMAD has no events in Egypt from July to
#'     December 2012).
#' }
#' Only indicators and counts are filled (columns ending in `_onset`,
#' `_incidence`, `_episode`, `_n_*`, or `_total`, `n_campaigns`, the UCDP
#' conflict-type indicators, and NAVCO 3.0 fatalities and injuries).
#' Maxima, means, and descriptive columns stay `NA` in periods without
#' records. Coverage is decided by year, so in finer panels every period of
#' a covered year is covered.
#'
#' **Active episodes.** `<prefix>incidence` is 1 in every period in which at
#' least one episode was in progress and `<prefix>n_active` counts them. An
#' episode is in progress from its start to its end date. Start dates less
#' precise than the panel's unit drop the episode, as for onsets. An end
#' date less precise than the unit is taken to be the last day of the period
#' the source gives: an OMG phase that ended "in 2005" is active through
#' December 2005. Beissinger episodes end at the start date plus the
#' source's duration (in days, or in calendar months for month-precise
#' starts). Episodes the source codes as ongoing run to the end of its
#' coverage. For `"navco2.1"`, every campaign-year counts as active.
#'
#' **Dates.** In a country-quarter, country-month, or country-day panel,
#' each event or episode onset is placed in the period of its start date. Records whose source date is less precise
#' than the panel's unit (for example, an OMG phase dated only to a year in a
#' country-month panel) are dropped with a message. `"navco1.3"`,
#' `"navco2.1"`, `"ucdp_prio"`, and `"ucdp_vpp"` record only years
#' and are available for country-year panels only.
#'
#' @examples
#' # Country-month panel of protest events
#' monthly <- build_states_panel(2010, 2012, coding_system = "cow", unit = "month") |>
#'   add_conflict(dataset = "mmad")
#'
#' # 0 instead of NA where the dataset covers the country but records nothing
#' monthly <- build_states_panel(2010, 2012, coding_system = "cow", unit = "month") |>
#'   add_conflict(dataset = "navco3.0", fill_zero = TRUE)
#'
#' # Episodes in progress, not only their onsets
#' panel <- build_states_panel(2000, 2020, coding_system = "cow") |>
#'   add_conflict(dataset = "raqed")
#' panel[panel$cow == 652, c("year", "raqed_onset", "raqed_incidence")]
#'
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
add_conflict <- function(panel, dataset, aggregate = TRUE, fill_zero = FALSE) {
  check_flag(aggregate, "aggregate")
  check_flag(fill_zero, "fill_zero")
  coding_system <- detect_coding_system(panel)
  unit <- detect_panel_unit(panel)
  keys <- c(coding_system, time_keys(unit))
  yr <- range(panel$year, na.rm = TRUE)

  conflicts <- conflict_data(
    start_year    = yr[1],
    end_year      = yr[2],
    dataset       = dataset,
    coding_system = coding_system,
    unit          = unit
  )

  campaign_dataset <- dataset %in% c(
    "navco1.3", "navco2.1", "beissinger", "raqed", "mec", "omg"
  )

  if (aggregate && campaign_dataset) {
    has_dupes <- conflicts |>
      dplyr::count(dplyr::across(dplyr::all_of(keys))) |>
      dplyr::filter(.data$n > 1) |>
      nrow() > 0

    if (has_dupes) {
      message(
        "Multiple campaigns or episodes per country-", unit, " detected in '",
        dataset, "'. ",
        "Aggregating to country-", unit, " using max() for numeric columns. ",
        "Use `aggregate = FALSE` or `conflict_data()` for record-level data."
      )
    }

    conflicts <- conflicts |>
      dplyr::group_by(dplyr::across(dplyr::all_of(keys))) |>
      dplyr::mutate(n_campaigns = dplyr::n()) |>
      dplyr::summarise(
        dplyr::across(dplyr::where(is.numeric), safe_max),
        .groups = "drop"
      )
  }

  out <- dplyr::left_join(panel, conflicts, by = keys)

  if (dataset %in% spell_datasets) {
    active <- episode_incidence(dataset, coding_system, yr[1], yr[2], unit)
    out <- dplyr::left_join(out, active, by = keys)
  }

  if (fill_zero) {
    fill <- zero_fill_columns(setdiff(names(out), names(panel)))
    covered <- dataset_covers(dataset, coding_system, out[c(coding_system, "year")])
    for (col in fill) {
      zero <- covered & is.na(out[[col]])
      out[[col]][zero] <- 0L
    }
  }

  out
}


#' Add leader data to a state panel
#'
#' @description
#' Joins leader data onto an existing state panel. The coding system, time
#' unit, and year range are detected automatically from the panel.
#'
#' Each period is assigned the leader who held power at the end of it (the
#' leader with the latest start date when several leaders served in the
#' same period). In a country-quarter, country-month, or country-day panel,
#' leaders are placed by their exact dates in office, so a transition in
#' February 2011 shows up in February 2011, not for the whole year.
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
#' # Leader by month
#' monthly <- build_states_panel(2011, 2011, coding_system = "cow", unit = "month") |>
#'   add_leader_data()
#'
#' @export
add_leader_data <- function(panel, dataset = c("archigos", "reign")) {
  dataset       <- match.arg(dataset)
  coding_system <- detect_coding_system(panel)
  unit          <- detect_panel_unit(panel)
  yr            <- range(panel$year, na.rm = TRUE)

  leaders <- load_leader_data(
    start_year    = yr[1],
    end_year      = yr[2],
    dataset       = dataset,
    coding_system = coding_system,
    unit          = unit
  )

  dplyr::left_join(panel, leaders, by = c(coding_system, time_keys(unit)))
}
