#' Load GDP data
#'
#' @description
#' Loads GDP data from one of two sources included with the package and
#' returns a country-year dataset using either COW or Gleditsch-Ward country
#' codes.
#'
#' @param start_year Integer. First year to include.
#' @param end_year Integer. Last year to include.
#' @param dataset Character. Dataset to load:
#'   \describe{
#'     \item{`"gapminder"`}{Gapminder GDP per capita (v32). Coverage:
#'       1945-2019 by default (full source coverage is wider).}
#'     \item{`"fariss"`}{Latent GDP and GDP per capita estimates (Fariss,
#'       Anders, Markowitz & Barnum 2022), combined from their `fariss_gdp`
#'       and `fariss_gdppc` replication files. Coverage: 1500-2019.}
#'   }
#' @param coding_system Character. Country coding system to use.
#'   Either `"cow"` for Correlates of War codes or `"gw"` for
#'   Gleditsch-Ward codes.
#'
#' @return A data frame with country-year GDP indicators. If
#'   `coding_system = "cow"`, the data frame contains a `cow` column.
#'   If `coding_system = "gw"`, it contains a `gw` column. Columns differ by
#'   dataset:
#'
#'   **gapminder:** `year`, `gdp_pcap`, `log_gdp_pcap`, `gdp_growth`.
#'
#'   **fariss:** `year`, `fariss_gdp`, `fariss_gdppc`.
#'
#' @details
#' `gdp_growth` (gapminder only) is `NA` unless the preceding row is
#' genuinely one year earlier for the same country, the same gap-safety
#' check `add_lag()` uses, so a missing year never silently produces a
#' growth rate computed against the wrong base year.
#'
#' `fariss_gdp` and `fariss_gdppc` are the model's own latent-scale
#' estimates, taken directly from the `"latent_gdp"`/`"latent_gdppc"` rows of
#' the replication files (as opposed to the underlying raw indicator series
#' also present in those files). Their absolute units are not independently
#' verified here; consult Fariss et al. (2022) before using them outside of
#' relative/comparative analysis.
#'
#' @source
#' **Gapminder:** GDP per capita data from Gapminder. Gapminder data are
#' distributed under CC BY 4.0; please cite Gapminder and the original data
#' providers.
#'
#' **Fariss:** Fariss, C.J., Anders, T., Markowitz, J.N., & Barnum, M.
#' (2022). New estimates of over 500 years of historic GDP and population
#' data. *Journal of Conflict Resolution*, 66(3), 553-591.
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
#' gdp_cow <- load_gdp_data(coding_system = "cow")
#'
#' gdp_gw <- load_gdp_data(coding_system = "gw")
#'
#' fariss_gdp <- load_gdp_data(1900, 2015, dataset = "fariss", coding_system = "cow")
#'
#' @export
load_gdp_data <- function(
    start_year = 1945,
    end_year = 2019,
    dataset = c("gapminder", "fariss"),
    coding_system = c("cow", "gw")
) {
  check_year_range(start_year, end_year)
  dataset       <- match.arg(dataset)
  coding_system <- match.arg(coding_system)

  if (dataset == "fariss") {
    gdp_path    <- system.file("extdata", "fariss_gdp.rds", package = "contentiousR")
    gdppc_path  <- system.file("extdata", "fariss_gdppc.rds", package = "contentiousR")
    if (gdp_path == "" || gdppc_path == "") {
      stop("Could not find Fariss GDP files in package extdata.", call. = FALSE)
    }

    gdp_level <- readRDS(gdp_path) |>
      dplyr::filter(.data$indicator == "latent_gdp") |>
      dplyr::select(gwno = "gwno", "year", fariss_gdp = "mean")

    gdp_pcap <- readRDS(gdppc_path) |>
      dplyr::filter(.data$indicator == "latent_gdppc") |>
      dplyr::select(gwno = "gwno", "year", fariss_gdppc = "mean")

    gdp_data <- dplyr::inner_join(gdp_level, gdp_pcap, by = c("gwno", "year"))

    if (coding_system == "cow") {
      gdp_data <- gdp_data |>
        dplyr::mutate(
          cow = suppressWarnings(countrycode::countrycode(.data$gwno, "gwn", "cown"))
        ) |>
        tidyr::drop_na("cow") |>
        dplyr::select(-"gwno") |>
        dplyr::select("cow", "year", dplyr::everything())
    } else {
      gdp_data <- gdp_data |>
        dplyr::rename(gw = "gwno") |>
        dplyr::select("gw", "year", dplyr::everything())
    }

    gdp_data <- gdp_data |>
      dplyr::filter(.data$year >= start_year & .data$year <= end_year) |>
      dplyr::arrange(.data[[coding_system]], .data$year)

    check_unique_key(gdp_data, c(coding_system, "year"))

    return(gdp_data)
  }

  path <- system.file(
    "extdata",
    "gdp_gapminder_v32.csv.xz",
    package = "contentiousR"
  )

  if (path == "") {
    stop(
      "Could not find `gdp_gapminder_v32.csv.xz` in package extdata.",
      call. = FALSE
    )
  }

  gdp_source <- readr::read_csv(path, show_col_types = FALSE)

  if (coding_system == "cow") {
    gdp_data <- gdp_source |>
      dplyr::mutate(
        cow = suppressWarnings(countrycode::countrycode(
          .data$name,
          origin = "country.name",
          destination = "cown"
        )),
        cow = dplyr::case_when(
          .data$name == "Serbia" ~ 345,
          .data$name == "China" ~ 710,
          TRUE ~ .data$cow
        )
      ) |>
      tidyr::drop_na("cow") |>
      dplyr::arrange(.data$cow, .data$year) |>
      dplyr::group_by(.data$cow) |>
      dplyr::mutate(
        gdp_pcap_l1 = lag_with_year_gap_check(.data$gdp_pcap, .data$year, 1),
        gdp_growth  = (.data$gdp_pcap - .data$gdp_pcap_l1) / .data$gdp_pcap_l1 * 100,
        log_gdp_pcap = log(.data$gdp_pcap)
      ) |>
      dplyr::ungroup() |>
      dplyr::filter(.data$year >= start_year & .data$year <= end_year) |>
      dplyr::select(
        "cow", "year", "gdp_pcap", "log_gdp_pcap", "gdp_growth"
      )
  }

  if (coding_system == "gw") {
    gdp_data <- gdp_source |>
      dplyr::mutate(
        gw = suppressWarnings(countrycode::countrycode(
          .data$name,
          origin = "country.name",
          destination = "gwn"
        )),
        gw = dplyr::case_when(
          .data$name == "Serbia" ~ 340,
          .data$name == "China" ~ 710,
          TRUE ~ .data$gw
        )
      ) |>
      tidyr::drop_na("gw") |>
      dplyr::arrange(.data$gw, .data$year) |>
      dplyr::group_by(.data$gw) |>
      dplyr::mutate(
        gdp_pcap_l1 = lag_with_year_gap_check(.data$gdp_pcap, .data$year, 1),
        gdp_growth  = (.data$gdp_pcap - .data$gdp_pcap_l1) / .data$gdp_pcap_l1 * 100,
        log_gdp_pcap = log(.data$gdp_pcap)
      ) |>
      dplyr::ungroup() |>
      dplyr::filter(.data$year >= start_year & .data$year <= end_year) |>
      dplyr::select(
        "gw", "year", "gdp_pcap", "log_gdp_pcap", "gdp_growth"
      )
  }

  check_unique_key(gdp_data, c(coding_system, "year"))

  return(gdp_data)
}
