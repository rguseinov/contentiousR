#' Load population data
#'
#' @description
#' Loads country-year population data from one of three sources included
#' with the package.
#'
#' @param start_year Integer. First year to include.
#' @param end_year Integer. Last year to include.
#' @param dataset Character. Dataset to load:
#'   \describe{
#'     \item{`"wpp"`}{UN World Population Prospects, total population in
#'       thousands. Coverage: 1949-2023.}
#'     \item{`"nmc"`}{Correlates of War National Material Capabilities v7.0
#'       (abridged): total population (`nmc_tpop`) and urban population
#'       (`nmc_upop`), both in thousands. Coverage: 1816-2022.}
#'     \item{`"fariss"`}{Latent population estimates (Fariss, Anders,
#'       Markowitz & Barnum 2022). Coverage: 1500-2019.}
#'   }
#' @param coding_system Character. Country coding system: `"cow"` or `"gw"`.
#'
#' @return A country-year data frame. Columns differ by dataset, each
#'   prefixed with the source's `dataset` key:
#'
#'   **wpp:** `cow`/`gw`, `year`, `wpp_pop`.
#'
#'   **nmc:** `cow`/`gw`, `year`, `nmc_tpop`, `nmc_upop`.
#'
#'   **fariss:** `cow`/`gw`, `year`, `fariss_pop`.
#'
#' @details
#' The bundled UN WPP extract has three rows for some China country-years:
#' a combined mainland+Hong Kong+Macao+Taiwan figure, a mainland-only
#' figure, and a Hong Kong-only figure, all of which matched COW code 710
#' during country-name conversion upstream. The mainland-only figure is
#' consistently the median of the three, so `wpp_pop` is computed as the
#' median `pop` value within each `cow`-`year` group; for every other
#' country-year (a single row) this is a no-op.
#'
#' NMC's `-9` missing-data sentinel is recoded to `NA` in `nmc_tpop` and
#' `nmc_upop`.
#'
#' `fariss_pop` is the model's own latent-scale estimate, taken directly
#' from the `"latent_pop"` rows of the replication file. Its absolute units
#' are not independently verified here; consult Fariss et al. (2022) before
#' using it outside of relative/comparative analysis.
#'
#' @source
#' **UN WPP:** United Nations, Department of Economic and Social Affairs,
#' Population Division (2024). World Population Prospects 2024.
#' \url{https://population.un.org/wpp/}
#'
#' **NMC:** Singer, J. David, Bremer, Stuart & Stuckey, John (1972).
#' Capability Distribution, Uncertainty, and Major Power War, 1820-1965.
#' National Material Capabilities v7.0.
#' \url{https://correlatesofwar.org/data-sets/national-material-capabilities/}
#'
#' **Fariss:** Fariss, C.J., Anders, T., Markowitz, J.N., & Barnum, M.
#' (2022). New estimates of over 500 years of historic GDP and population
#' data. *Journal of Conflict Resolution*, 66(3), 553-591.
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
#' pop_wpp <- load_population_data(1990, 2015, dataset = "wpp", coding_system = "cow")
#'
#' pop_nmc <- load_population_data(1900, 2015, dataset = "nmc", coding_system = "cow")
#'
#' @importFrom stats median
#' @export
load_population_data <- function(
    start_year    = 1945,
    end_year      = 2019,
    dataset       = c("wpp", "nmc", "fariss"),
    coding_system = c("cow", "gw")
) {
  check_year_range(start_year, end_year)
  dataset       <- match.arg(dataset)
  coding_system <- match.arg(coding_system)

  if (dataset == "wpp") {
    raw <- read_rdata_from_extdata("un_population.RData")

    data <- raw |>
      dplyr::group_by(.data$cow, .data$year) |>
      dplyr::summarise(wpp_pop = stats::median(.data$pop), .groups = "drop")

    if (coding_system == "gw") {
      data <- data |>
        dplyr::mutate(
          gw = suppressWarnings(countrycode::countrycode(.data$cow, "cown", "gwn"))
        ) |>
        tidyr::drop_na("gw") |>
        dplyr::select(-"cow") |>
        dplyr::select("gw", "year", dplyr::everything())
    }
  }

  if (dataset == "nmc") {
    if (!requireNamespace("haven", quietly = TRUE)) {
      stop(
        "Package 'haven' is required to load NMC data. ",
        "Install it with: install.packages('haven')",
        call. = FALSE
      )
    }

    path <- system.file("extdata", "NMC-70-abridged.dta", package = "contentiousR")
    if (path == "") {
      stop("Could not find `NMC-70-abridged.dta` in package extdata.", call. = FALSE)
    }

    data <- haven::read_dta(path) |>
      dplyr::mutate(
        cow      = as.integer(.data$ccode),
        nmc_tpop = dplyr::na_if(.data$tpop, -9),
        nmc_upop = dplyr::na_if(.data$upop, -9)
      ) |>
      dplyr::select("cow", "year", "nmc_tpop", "nmc_upop")

    if (coding_system == "gw") {
      data <- data |>
        dplyr::mutate(
          gw = suppressWarnings(countrycode::countrycode(.data$cow, "cown", "gwn"))
        ) |>
        tidyr::drop_na("gw") |>
        dplyr::select(-"cow") |>
        dplyr::select("gw", "year", dplyr::everything())
    }
  }

  if (dataset == "fariss") {
    path <- system.file("extdata", "fariss_pop.rds", package = "contentiousR")
    if (path == "") {
      stop("Could not find `fariss_pop.rds` in package extdata.", call. = FALSE)
    }

    data <- readRDS(path) |>
      dplyr::filter(.data$indicator == "latent_pop") |>
      dplyr::select(gwno = "gwno", "year", fariss_pop = "mean")

    if (coding_system == "cow") {
      data <- data |>
        dplyr::mutate(
          cow = suppressWarnings(countrycode::countrycode(.data$gwno, "gwn", "cown"))
        ) |>
        tidyr::drop_na("cow") |>
        dplyr::select(-"gwno") |>
        dplyr::select("cow", "year", dplyr::everything())
    } else {
      data <- data |>
        dplyr::rename(gw = "gwno") |>
        dplyr::select("gw", "year", dplyr::everything())
    }
  }

  data <- data |>
    dplyr::filter(.data$year >= start_year & .data$year <= end_year) |>
    dplyr::arrange(.data[[coding_system]], .data$year)

  check_unique_key(data, c(coding_system, "year"))

  return(data)
}
