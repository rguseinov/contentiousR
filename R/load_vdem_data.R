#' Load V-Dem data
#'
#' @description
#' Loads selected country-year variables from the V-Dem dataset provided by
#' the `vdemdata` package. The returned data can use either COW or
#' Gleditsch-Ward country codes.
#'
#' @param vars Character vector of V-Dem variable names to include. If `NULL`,
#'   a default set of civil society, repression, civil liberties, democracy,
#'   corruption, and rule-of-law indicators is returned.
#' @param start_year Integer. First year to include.
#' @param end_year Integer. Last year to include.
#' @param coding_system Character. Country coding system to use.
#'   Either `"cow"` for Correlates of War codes or `"gw"` for
#'   Gleditsch-Ward codes.
#'
#' @return A data frame with country-year V-Dem indicators. If
#'   `coding_system = "cow"`, the data frame contains a `cow` column.
#'   If `coding_system = "gw"`, it contains a `gw` column.
#'
#' @details
#' This function requires the `vdemdata` package. If it is not installed,
#' install it with:
#'
#' `remotes::install_github("vdeminstitute/vdemdata")`. Because `vdemdata`
#' is not distributed through CRAN, it is always checked conditionally.
#'
#' For `coding_system = "gw"`, V-Dem COW codes are converted to
#' Gleditsch-Ward codes using `countrycode::countrycode()`.
#'
#' @source
#' Varieties of Democracy (V-Dem) Project. Please cite V-Dem when using
#' these data.
#'
#' @references
#' Coppedge, M., Gerring, J., Knutsen, C. H., Lindberg, S. I., Teorell, J.,
#' Altman, D., Bernhard, M., Fish, M. S., Glynn, A., Hicken, A., et al.
#' (2025). *V-Dem \[Country-Year/Country-Date\] Dataset v15*. Varieties of
#' Democracy.
#'
#' @examples
#' if (requireNamespace("vdemdata", quietly = TRUE)) {
#' vdem_cow <- load_vdem_data(coding_system = "cow")
#'
#' vdem_selected <- load_vdem_data(
#'   vars = c("v2x_polyarchy", "v2x_libdem", "v2x_rule"),
#'   coding_system = "cow"
#' )
#'
#' vdem_gw <- load_vdem_data(
#'   vars = c("v2x_polyarchy", "v2x_libdem"),
#'   coding_system = "gw"
#' )
#' }
#'
#' @export
load_vdem_data <- function(
    vars = NULL,
    start_year = 1945,
    end_year = 2019,
    coding_system = c("cow", "gw")
) {
  check_year_range(start_year, end_year)

  if (!requireNamespace("vdemdata", quietly = TRUE)) {
    stop(
      "Package 'vdemdata' is required to use V-Dem data. ",
      "Install it with remotes::install_github('vdeminstitute/vdemdata').",
      call. = FALSE
    )
  }

  coding_system <- match.arg(coding_system)
  vdem <- vdemdata::vdem

  default_vars <- c(
    "v2cseeorgs",
    "v2csreprss",
    "v2cscnsult",
    "v2csprtcpt",
    "v2csgender",
    "v2csantimv",
    "v2xcs_ccsi",
    "v2x_freexp",
    "v2x_freexp_altinf",
    "v2clacfree",
    "v2meslfcen",
    "v2csrlgrep",
    "v2mecenefm",
    "v2mecenefi",
    "v2meharjrn",
    "v2x_civlib",
    "v2x_clphy",
    "v2x_clpriv",
    "v2x_clpol",
    "v2x_polyarchy",
    "v2x_libdem",
    "v2x_regime",
    "v2x_corr",
    "v2x_rule"
  )

  if (is.null(vars)) {
    vars <- default_vars
  }

  if (!is.character(vars)) {
    stop("`vars` must be a character vector of V-Dem variable names.", call. = FALSE)
  }

  required_cols <- c("COWcode", "year")
  missing_required <- setdiff(required_cols, names(vdem))

  if (length(missing_required) > 0) {
    stop(
      "The V-Dem dataset is missing required columns: ",
      paste(missing_required, collapse = ", "),
      call. = FALSE
    )
  }

  missing_vars <- setdiff(vars, names(vdem))

  if (length(missing_vars) > 0) {
    stop(
      "These V-Dem variables were not found: ",
      paste(missing_vars, collapse = ", "),
      call. = FALSE
    )
  }

  vdem_dataset <- vdem |>
    dplyr::rename(cow = "COWcode") |>
    tidyr::drop_na("cow") |>
    dplyr::select("cow", "year", dplyr::all_of(vars)) |>
    dplyr::filter(.data$year >= start_year & .data$year <= end_year)
  vdem_dataset <- convert_code_column(vdem_dataset, "cow", "cow", coding_system)

  check_unique_key(vdem_dataset, c(coding_system, "year"))

  return(vdem_dataset)
}
