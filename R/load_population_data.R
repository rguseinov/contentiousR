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
#' **WPP and historical states.** WPP reports today's countries, with their
#' population reconstructed back to 1949 within today's borders.
#' `load_population_data(dataset = "wpp")` assigns each WPP country to the
#' state that governed it in each year, and sums them:
#' \itemize{
#'   \item States that later split are the sum of their parts while they
#'     existed: the USSR (365, the fifteen republics until 1991, the Baltic
#'     states from 1940), Yugoslavia and its successor (345: Serbia, Kosovo,
#'     Montenegro, and the other republics until they became states),
#'     Czechoslovakia (316, the panels' code; Czechia and Slovakia until
#'     1992), Ethiopia (with Eritrea, 1952-1992), Pakistan (with Bangladesh
#'     until 1970), Sudan (with South Sudan until 2010), Indonesia (with
#'     Timor-Leste, 1976-2001), Malaysia (with Singapore, 1963-1964), and
#'     Egypt (with Syria, 1959-1960, as the United Arab Republic).
#'   \item Hong Kong is added to China from 1997 and Macao from 1999.
#'   \item States formed by unification cannot be split back into their
#'     parts, so the parts are `NA` before unification: West and East
#'     Germany before 1990 (Germany has data from 1990), North and South
#'     Yemen before 1990 (Yemen, COW 679, from 1990), North and South Vietnam
#'     before 1976, and Tanganyika and Zanzibar before 1964.
#' }
#' In the year a state split, each successor that is a state that year has
#' its own value, and the predecessor covers the territory it kept. Only
#' the years in which a state is in the COW or GW state system are
#' returned.
#' Territories WPP lists separately that were not part of a COW state (for
#' example Puerto Rico, Greenland, Western Sahara, and French overseas
#' departments) are not added to any state. Smaller border changes within
#' a state (such as the incorporation of Goa, Sikkim, or Sabah and Sarawak)
#' are not adjusted: WPP's figures follow today's borders.
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
    path <- system.file("extdata", "wpp2024_pop.rds", package = "contentiousR")
    if (path == "") {
      stop("Could not find `wpp2024_pop.rds` in package extdata.", call. = FALSE)
    }
    data <- wpp_to_states(readRDS(path), coding_system)
  }

  if (dataset == "nmc") {
    path <- system.file("extdata", "NMC-70-abridged.rds", package = "contentiousR")
    if (path == "") {
      stop("Could not find `NMC-70-abridged.rds` in package extdata.", call. = FALSE)
    }

    data <- readRDS(path) |>
      dplyr::mutate(
        cow      = as.integer(.data$ccode),
        nmc_tpop = dplyr::na_if(.data$tpop, -9),
        nmc_upop = dplyr::na_if(.data$upop, -9)
      ) |>
      dplyr::select("cow", "year", "nmc_tpop", "nmc_upop")

    data <- convert_code_column(data, "cow", "cow", coding_system)
  }

  if (dataset == "fariss") {
    path <- system.file("extdata", "fariss_pop.rds", package = "contentiousR")
    if (path == "") {
      stop("Could not find `fariss_pop.rds` in package extdata.", call. = FALSE)
    }

    data <- readRDS(path) |>
      dplyr::filter(.data$indicator == "latent_pop") |>
      dplyr::select(gwno = "gwno", "year", fariss_pop = "mean")

    data <- convert_code_column(data, "gwno", "gw", coding_system)
  }

  data <- data |>
    dplyr::filter(.data$year >= start_year & .data$year <= end_year) |>
    dplyr::arrange(.data[[coding_system]], .data$year)

  check_unique_key(data, c(coding_system, "year"))

  return(data)
}

#' Assign WPP countries to COW or GW states by year
#'
#' See the WPP section of [load_population_data()] for the rules. Each WPP
#' country counts as its own state in the years that state is in the
#' target system's state list; otherwise it is added to the state it
#' belonged to, if any.
#'
#' @param wpp A data frame with `country_code` (UN M49), `year`, and `pop`.
#' @param coding_system `"cow"` or `"gw"`.
#'
#' @return A data frame with the country code, `year`, and `wpp_pop`.
#'
#' @keywords internal
wpp_to_states <- function(wpp, coding_system) {
  un <- as.integer(wpp$country_code)
  year <- as.integer(wpp$year)

  own <- suppressWarnings(as.integer(countrycode::countrycode(un, "un", "cown")))
  own[un == 158L] <- 713L   # Taiwan
  own[un == 688L] <- 345L   # Serbia
  own[un == 412L] <- 347L   # Kosovo

  # Unified states whose parts WPP does not report separately: only from
  # unification.
  unified_from <- c("255" = 1990L, "679" = 1990L, "816" = 1976L, "510" = 1964L)
  late <- as.character(own) %in% names(unified_from)
  own[late & year < unified_from[as.character(own)]] <- NA_integer_

  # The state each territory belonged to when it was not a state itself.
  parent_rules <- data.frame(
    un = c(
      # Soviet republics (Baltic states from 1940)
      804L, 112L, 498L, 268L, 51L, 31L, 398L, 860L, 795L, 417L, 762L,
      233L, 428L, 440L,
      # Yugoslav republics and Kosovo
      705L, 191L, 70L, 807L, 499L, 412L,
      # Slovakia, Eritrea, Bangladesh, South Sudan, Timor-Leste, Singapore,
      # Syria, Hong Kong, Macao
      703L, 232L, 50L, 728L, 626L, 702L, 760L, 344L, 446L
    ),
    parent = c(rep(365L, 14), rep(345L, 6),
               316L, 530L, 770L, 625L, 850L, 820L, 651L, 710L, 710L),
    from = c(rep(1900L, 11), rep(1940L, 3), rep(1900L, 6),
             1900L, 1952L, 1900L, 1900L, 1976L, 1963L, 1958L, 1997L, 1999L),
    to = c(rep(9999L, 20),
           9999L, 9999L, 9999L, 9999L, 2001L, 1965L, 1961L, 9999L, 9999L)
  )
  parent <- rep(NA_integer_, length(un))
  for (i in seq_len(nrow(parent_rules))) {
    r <- parent_rules[i, ]
    hit <- un == r$un & year >= r$from & year <= r$to
    parent[hit] <- r$parent
  }

  # Codes in the target system, by year.
  own <- convert_state_code(own, year, "cow", coding_system)
  parent <- convert_state_code(parent, year, "cow", coding_system)
  parent[!state_exists(parent, year, coding_system)] <- NA_integer_
  code <- ifelse(state_exists(own, year, coding_system), own, parent)

  keep <- !is.na(code)
  out <- stats::aggregate(
    list(wpp_pop = wpp$pop[keep]),
    by = list(code = code[keep], year = year[keep]),
    FUN = sum
  )

  # GW splits 2006 between Serbia and Montenegro (345, to June) and Serbia
  # (340): give 345 the population of the three territories as well.
  if (coding_system == "gw") {
    fry <- un %in% c(688L, 499L, 412L) & year == 2006L
    if (any(fry)) {
      out <- rbind(out, data.frame(code = 345L, year = 2006L,
                                   wpp_pop = sum(wpp$pop[fry])))
    }
  }

  names(out)[1] <- coding_system
  out[[coding_system]] <- as.integer(out[[coding_system]])
  out$year <- as.integer(out$year)
  out <- out[order(out[[coding_system]], out$year), ]
  rownames(out) <- NULL
  dplyr::as_tibble(out)
}

#' Whether a state is in the state system in a year
#'
#' Uses the `states` package's COW or GW list; a state counts in every year
#' it existed for any part of, as in [build_states_panel()]. For COW, the
#' panels' codes 255 and 316 also cover the years of 260 and 315.
#'
#' @param code Integer vector of codes.
#' @param year Integer vector of years.
#' @param coding_system `"cow"` or `"gw"`.
#'
#' @return A logical vector.
#'
#' @keywords internal
state_exists <- function(code, year, coding_system) {
  table <- if (coding_system == "cow") states::cowstates else states::gwstates
  table_code <- if (coding_system == "cow") {
    standardize_cow(table$cowcode)
  } else {
    as.integer(table$gwcode)
  }
  start <- as.integer(format(table$start, "%Y"))
  end <- as.integer(format(table$end, "%Y"))
  out <- logical(length(code))
  for (i in which(!is.na(code))) {
    out[i] <- any(table_code == code[i] & start <= year[i] & end >= year[i])
  }
  out
}
