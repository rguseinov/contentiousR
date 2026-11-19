#' Load military expenditure data
#'
#' @description
#' Loads country-year military expenditure data from one of the sources
#' included with the package.
#'
#' @param start_year Integer. First year to include.
#' @param end_year Integer. Last year to include.
#' @param dataset Character. Dataset to load:
#'   \describe{
#'     \item{`"sipri"`}{SIPRI Military Expenditure Database v1.2: spending in
#'       constant (2024) USD millions (`sipri_milex`) and military burden as
#'       a share of GDP (`sipri_milburden`, a fraction, not a percentage).
#'       Coverage: 1949-2025.}
#'     \item{`"nmc"`}{Correlates of War National Material Capabilities v7.0
#'       (abridged): military expenditure in thousands of current USD
#'       (`nmc_milex`). Coverage: 1816-2022.}
#'     \item{`"barnum"`}{Global Military Spending Dataset (Barnum, Fariss,
#'       Markowitz & Morales 2025): military burden (`barnum_milburden`, a
#'       fraction of GDP) plus latent-model expenditure estimates on two
#'       unit bases (`barnum_sipri`, `barnum_nmc`; see Details). Coverage:
#'       1816-2023 (`barnum_milburden` to 2019).}
#'   }
#' @param coding_system Character. Country coding system: `"cow"` or `"gw"`.
#'
#' @return A country-year data frame. Columns differ by dataset:
#'
#'   **sipri:** `cow`/`gw`, `year`, `sipri_milex`, `sipri_milburden`.
#'
#'   **nmc:** `cow`/`gw`, `year`, `nmc_milex`.
#'
#'   **barnum:** `cow`/`gw`, `year`, `barnum_milburden`, `barnum_sipri`,
#'   `barnum_nmc`.
#'
#' @details
#' NMC's `-9` missing-data sentinel is recoded to `NA` in `nmc_milex`.
#'
#' The SIPRI workbook lists a small number of rows (e.g. "Africa", "NATO")
#' that are regional or organizational aggregates rather than countries;
#' these have no matching COW/Gleditsch-Ward code and are dropped when
#' `countrycode::countrycode()` returns `NA`.
#'
#' Barnum et al.'s replication files contain one row per country-year for
#' each of 24 underlying source indicators (SIPRI, WMEAT, NCD, IISS, and
#' others), each already reported in its own original currency/unit. Unlike
#' Fariss et al. (2022)'s GDP and population estimates, the paper does not
#' publish a single combined "latent" value on a real monetary scale: "the
#' average by itself does not have a real or direct monetary unit" (p. 550).
#' Instead, `barnum_sipri` and `barnum_nmc` are the model's posterior
#' estimate of two specific indicators (the `"milex_con_2022_sipri"` and
#' `"milex_con_2017_nmc"` series respectively), which extends each one's
#' coverage back to 1816 using information from all 24 sources, still
#' expressed in that indicator's own original units. `barnum_milburden` is
#' `milexgdp` from Barnum et al.'s separate military-burden estimates file,
#' which is unit-free and so is published directly.
#'
#' Both `"_con_"` indicators are in constant (inflation-adjusted) dollars,
#' unlike `nmc_milex` from `dataset = "nmc"`, which NMC documents in
#' current-year dollars. `barnum_nmc` is therefore not directly comparable
#' to `nmc_milex`: their ratio varies smoothly over time (e.g. around 2.4
#' for the United States in 1990, falling toward 1 by the mid-2010s), which
#' reflects cumulative inflation adjustment rather than disagreement between
#' the two sources.
#'
#' @source
#' **SIPRI:** Stockholm International Peace Research Institute (2025).
#' SIPRI Military Expenditure Database.
#' \url{https://www.sipri.org/databases/milex}
#'
#' **NMC:** Singer, J. David, Bremer, Stuart & Stuckey, John (1972).
#' Capability Distribution, Uncertainty, and Major Power War, 1820-1965.
#' National Material Capabilities v7.0.
#' \url{https://correlatesofwar.org/data-sets/national-material-capabilities/}
#'
#' **Barnum:** Barnum, M., Fariss, C.J., Markowitz, J.N., & Morales, G.
#' (2025). Measuring Arms: Introducing the Global Military Spending
#' Dataset. *Journal of Conflict Resolution*, 69(2-3), 540-567.
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
#' milex_sipri <- load_military_expenditure_data(1990, 2015, dataset = "sipri", coding_system = "cow")
#'
#' milex_nmc <- load_military_expenditure_data(1900, 2015, dataset = "nmc", coding_system = "cow")
#'
#' @export
load_military_expenditure_data <- function(
    start_year    = 1945,
    end_year      = 2019,
    dataset       = c("sipri", "nmc", "barnum"),
    coding_system = c("cow", "gw")
) {
  check_year_range(start_year, end_year)
  dataset       <- match.arg(dataset)
  coding_system <- match.arg(coding_system)

  if (dataset == "sipri") {
    path <- system.file("extdata", "sipri_milex_v1.2.rds", package = "contentiousR")
    if (path == "") {
      stop("Could not find `sipri_milex_v1.2.rds` in package extdata.", call. = FALSE)
    }

    # Built by data-raw/extdata.R from the "Constant (2024) US$" and
    # "Share of GDP" sheets of SIPRI-Milex-data-1949-2025_v1.2.xlsx.
    joined <- readRDS(path)

    data <- joined |>
      dplyr::mutate(
        cow = suppressWarnings(as.integer(countrycode::countrycode(
          .data$country,
          origin = "country.name",
          destination = "cown"
        ))),
        cow = dplyr::case_when(
          .data$country == "Serbia" ~ 345L,
          TRUE ~ .data$cow
        )
      ) |>
      dplyr::select(-"country")
    data <- convert_code_column(data, "cow", "cow", coding_system)
  }

  if (dataset == "nmc") {
    path <- system.file("extdata", "NMC-70-abridged.rds", package = "contentiousR")
    if (path == "") {
      stop("Could not find `NMC-70-abridged.rds` in package extdata.", call. = FALSE)
    }

    data <- readRDS(path) |>
      dplyr::mutate(
        cow       = as.integer(.data$ccode),
        nmc_milex = dplyr::na_if(.data$milex, -9)
      ) |>
      dplyr::select("cow", "year", "nmc_milex")

    data <- convert_code_column(data, "cow", "cow", coding_system)
  }

  if (dataset == "barnum") {
    milburden_path <- system.file(
      "extdata", "estimates_milburden_20250429.rds", package = "contentiousR"
    )
    milex_path <- system.file(
      "extdata", "estimates_milex_con_20250429.rds", package = "contentiousR"
    )
    if (milburden_path == "" || milex_path == "") {
      stop("Could not find the Barnum military spending files in package extdata.", call. = FALSE)
    }

    milburden <- readRDS(milburden_path) |>
      dplyr::select(gwno = "gwno", "year", barnum_milburden = "milexgdp")

    milex_raw <- readRDS(milex_path)

    barnum_sipri <- milex_raw |>
      dplyr::filter(.data$indicator == "milex_con_2022_sipri") |>
      dplyr::select(gwno = "gwno", "year", barnum_sipri = "mean")

    barnum_nmc <- milex_raw |>
      dplyr::filter(.data$indicator == "milex_con_2017_nmc") |>
      dplyr::select(gwno = "gwno", "year", barnum_nmc = "mean")

    data <- milburden |>
      dplyr::full_join(barnum_sipri, by = c("gwno", "year")) |>
      dplyr::full_join(barnum_nmc, by = c("gwno", "year"))

    data <- convert_code_column(data, "gwno", "gw", coding_system)
  }

  data <- data |>
    dplyr::filter(.data$year >= start_year & .data$year <= end_year) |>
    dplyr::arrange(.data[[coding_system]], .data$year)

  check_unique_key(data, c(coding_system, "year"))

  return(data)
}
