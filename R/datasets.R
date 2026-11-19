#' List the datasets bundled with the package
#'
#' @description
#' Returns one row per dataset that the package's loaders and `add_*()`
#' functions can use, with its coverage, data type, the panel units it
#' supports, and the prefix of the columns it adds. Use [cn_cite()] with the
#' `dataset` value to get the citation.
#'
#' @param topic Which datasets to list: `"all"` (default), `"conflict"`,
#'   `"gdp"`, `"population"`, `"military"`, `"leaders"`, or `"vdem"`.
#'
#' @return A data frame with columns:
#'   \describe{
#'     \item{`dataset`}{Value to pass as `dataset =`.}
#'     \item{`topic`}{Topic, as in `topic`.}
#'     \item{`name`}{Name of the source.}
#'     \item{`version`}{Bundled version.}
#'     \item{`load_function`, `add_function`}{The loader and the panel
#'       function that use it.}
#'     \item{`record`}{What one source record is: an event, an episode or
#'       campaign, a campaign phase, a conflict-year, or a country-year.}
#'     \item{`start_year`, `end_year`}{Years covered.}
#'     \item{`countries`}{Which countries the source covers.}
#'     \item{`units`}{Panel units at which the data vary: annual data are
#'       repeated across the periods of a year in finer panels.}
#'     \item{`prefix`}{Prefix of the columns added to a panel.}
#'     \item{`zero_fill`}{For conflict datasets, how
#'       `add_conflict(fill_zero = TRUE)` decides which country-years the
#'       source covers (see [add_conflict()]).}
#'   }
#'
#' @examples
#' list_datasets()
#' list_datasets("conflict")[, c("dataset", "start_year", "end_year", "units")]
#'
#' @export
list_datasets <- function(topic = c("all", "conflict", "gdp", "population",
                                    "military", "leaders", "vdem")) {
  topic <- match.arg(topic)
  out <- dataset_registry()
  if (topic != "all") {
    out <- out[out$topic == topic, , drop = FALSE]
  }
  rules <- c(
    global        = "All states in the panel, within start_year-end_year",
    countries     = "Countries with at least one record, within start_year-end_year",
    country_span  = "Each country from its first to its last year with a record",
    country_years = "Country-years listed in the source, including those coded as having no event",
    none          = NA_character_
  )
  out$zero_fill <- unname(rules[out$coverage_rule])
  out$coverage_rule <- NULL
  rownames(out) <- NULL
  out
}

#' Registry of bundled datasets
#'
#' One row per dataset. `coverage_rule` says how [add_conflict()] decides
#' which country-years a conflict dataset covers when `fill_zero = TRUE`:
#' `"global"` (every state in the panel), `"countries"` (countries with at
#' least one record), `"country_span"` (each country from its first to its
#' last year with a record), or `"country_years"` (the country-years listed
#' in the source).
#'
#' @return A data frame.
#'
#' @keywords internal
dataset_registry <- function() {
  all_units <- "year, quarter, month, day"
  annual <- "year (repeated in finer panels)"
  row <- function(dataset, topic, name, version, load_function, add_function,
                  record, start_year, end_year, countries, units, prefix,
                  coverage_rule = "none") {
    data.frame(
      dataset = dataset, topic = topic, name = name, version = version,
      load_function = load_function, add_function = add_function,
      record = record, start_year = as.integer(start_year),
      end_year = as.integer(end_year), countries = countries, units = units,
      prefix = prefix, coverage_rule = coverage_rule,
      stringsAsFactors = FALSE
    )
  }
  conflict <- function(dataset, name, version, record, start_year, end_year,
                       countries, units, prefix, coverage_rule) {
    row(dataset, "conflict", name, version, "conflict_data()", "add_conflict()",
        record, start_year, end_year, countries, units, prefix, coverage_rule)
  }

  rbind(
    conflict("navco1.3", "NAVCO 1.3", "1.3", "campaign", 1900, 2019,
             "Global", "year", "nvc1.3_", "global"),
    conflict("navco2.1", "NAVCO 2.1", "2.1", "campaign-year", 1945, 2013,
             "Global", "year", "nvc2.1_", "global"),
    conflict("navco3.0", "NAVCO 3.0", "3.0", "event", 1990, 2012,
             "26 countries", all_units, "nvc3.0_", "countries"),
    conflict("beissinger", "Revolutionary Episodes Dataset (Beissinger)",
             "2022", "episode", 1900, 2014, "Global", all_units,
             "beissinger_", "global"),
    conflict("raqed",
             "Revolutionary and Quasi-revolutionary Episodes Dataset (RAQED)",
             "1.4", "episode", 2000, 2026, "Global", all_units, "raqed_",
             "global"),
    conflict("mec", "Major Episodes of Contention (MEC)", "1.0", "episode",
             1955, 2018, "Global", all_units, "mec_", "global"),
    conflict("omg", "Opposition Movements and Groups (OMG)", "1",
             "campaign phase", 1789, 2019, "Global", all_units, "omg_",
             "global"),
    conflict("scad", "Social Conflict Analysis Database (SCAD)", "3.3",
             "event", 1990, 2017, "Africa and Latin America", all_units,
             "scad_", "countries"),
    conflict("arc", "Anatomy of Resistance Campaigns (ARC)", "2.0", "event",
             1990, 2018, "Africa, Latin America and the Caribbean",
             all_units, "arc_", "countries"),
    conflict("mm", "Mass Mobilization Project", "4", "event", 1990, 2020,
             "Most countries; the source lists the country-years it codes",
             all_units, "mm_", "country_years"),
    conflict("mmad", "Mass Mobilization in Autocracies Database (MMAD)",
             "5.0", "event", 2003, 2022, "Autocracies", all_units, "mmad_",
             "country_span"),
    conflict("ucdp_prio", "UCDP/PRIO Armed Conflict Dataset", "26.1",
             "conflict-year", 1946, 2025, "Global", "year", "ucdp_prio_",
             "global"),
    conflict("ucdp_vpp", "UCDP Violent Political Protest Dataset", "26.1",
             "dyad-year", 1989, 2025, "Global", "year", "ucdp_vpp_",
             "global"),
    row("gapminder", "gdp", "Gapminder GDP per capita", "32",
        "load_gdp_data()", "add_gdp()", "country-year", 1800, 2025,
        "Global", annual, "gdp_"),
    row("fariss", "gdp", "Latent GDP estimates (Fariss et al. 2022)", "2022",
        "load_gdp_data()", "add_gdp()", "country-year", 1500, 2019, "Global",
        annual, "fariss_"),
    row("wpp", "population", "UN World Population Prospects", "2024",
        "load_population_data()", "add_population()", "country-year", 1949,
        2023, "Global", annual, "wpp_"),
    row("nmc", "population", "COW National Material Capabilities", "7.0",
        "load_population_data()", "add_population()", "country-year", 1816,
        2022, "Global", annual, "nmc_"),
    row("fariss", "population", "Latent population estimates (Fariss et al. 2022)",
        "2022", "load_population_data()", "add_population()", "country-year",
        1500, 2019, "Global", annual, "fariss_"),
    row("sipri", "military", "SIPRI Military Expenditure Database", "1.2",
        "load_military_expenditure_data()", "add_military_expenditure()",
        "country-year", 1949, 2025, "Global", annual, "sipri_"),
    row("nmc", "military", "COW National Material Capabilities", "7.0",
        "load_military_expenditure_data()", "add_military_expenditure()",
        "country-year", 1816, 2022, "Global", annual, "nmc_"),
    row("barnum", "military", "Military spending estimates (Barnum et al. 2025)",
        "2025-04-29", "load_military_expenditure_data()",
        "add_military_expenditure()", "country-year", 1816, 2023, "Global",
        annual, "barnum_"),
    row("archigos", "leaders", "Archigos", "4.1", "load_leader_data()",
        "add_leader_data()", "leader spell", 1875, 2015, "Global",
        all_units, "leader"),
    row("reign", "leaders", "Rulers, Elections, and Irregular Governance (REIGN)",
        "2021", "load_leader_data()", "add_leader_data()", "leader spell",
        1921, 2021, "Global", "year, quarter, month", "leader"),
    row("vdem", "vdem", "Varieties of Democracy (via the vdemdata package)",
        "vdemdata", "load_vdem_data()", "add_vdem()", "country-year", 1789,
        NA, "Global", annual, "v2")
  )
}

#' Country-years a conflict dataset covers
#'
#' Used by `add_conflict(fill_zero = TRUE)`. See [dataset_registry()] for
#' the rules.
#'
#' @param dataset Dataset name.
#' @param coding_system `"cow"` or `"gw"`.
#' @param panel_keys A data frame with the country code and `year` of the
#'   panel rows.
#'
#' @return A logical vector, one value per row of `panel_keys`: `TRUE` if the
#'   dataset covers that country-year.
#'
#' @keywords internal
dataset_covers <- function(dataset, coding_system, panel_keys) {
  reg <- dataset_registry()
  info <- reg[reg$dataset == dataset & reg$topic == "conflict", ]
  year <- panel_keys$year
  code <- panel_keys[[coding_system]]
  in_years <- !is.na(year) & year >= info$start_year & year <= info$end_year

  if (info$coverage_rule == "global") {
    return(in_years)
  }

  records <- suppressMessages(suppressWarnings(conflict_data(
    start_year = info$start_year, end_year = info$end_year,
    dataset = dataset, coding_system = coding_system, unit = "year"
  )))
  rec_code <- records[[coding_system]]

  switch(info$coverage_rule,
    countries = in_years & code %in% rec_code,
    country_span = {
      first <- tapply(records$year, rec_code, min)
      last  <- tapply(records$year, rec_code, max)
      key <- as.character(code)
      in_years & !is.na(first[key]) & year >= first[key] & year <= last[key]
    },
    country_years = in_years &
      paste(code, year) %in% paste(rec_code, records$year)
  )
}

#' Columns that `fill_zero` sets to 0
#'
#' Event indicators and counts: `*_onset`, `*_incidence`, `*_episode`,
#' counts (`*_n_*`, `n_campaigns`), UCDP conflict-type indicators, and
#' summed totals (`*_total`; NAVCO 3.0 fatalities and injuries). Maxima, means, and descriptive columns stay
#' `NA` in periods without records.
#'
#' @param cols Column names.
#'
#' @return The subset of `cols` to fill.
#'
#' @keywords internal
zero_fill_columns <- function(cols) {
  pattern <- paste0(
    "(_onset|_ONSET|_incidence|_episode|_n_[A-Za-z_]+|_total|_war|",
    "_intrastate|_interstate|_gov_conflict|_territory_conflict)$|",
    "^nvc3\\.0_(fatalities|injuries)_(low|high)$|^n_campaigns$"
  )
  cols[grepl(pattern, cols)]
}
