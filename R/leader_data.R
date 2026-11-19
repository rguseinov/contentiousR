#' Load leader data
#'
#' @description
#' Loads leader data from one of two datasets included with the package, by
#' country-year or, with `unit`, by country-quarter, country-month, or
#' country-day. Each row holds the leader in power at the end of the period:
#' when several leaders served in the same period (a leadership transition),
#' the one who took office last is kept. Periods are assigned from the
#' leaders' dates of entry and exit, so a leader who left office in February
#' is no longer listed from March on.
#'
#' @param start_year Integer. First year to include.
#' @param end_year Integer. Last year to include.
#' @param dataset Character. Dataset to load:
#'   \describe{
#'     \item{`"archigos"`}{Archigos 4.1 (Goemans, Gleditsch & Chiozza). Leader
#'       spells with entry/exit mode coding. Coverage: 1875–2015.}
#'     \item{`"reign"`}{REIGN Leader List (Bell 2021). Leader spells with
#'       military background coding. Coverage: 1921–2021.}
#'   }
#' @param coding_system Character. Country coding system: `"cow"` or `"gw"`.
#' @param unit Time unit: `"year"` (default), `"quarter"`, `"month"`, or
#'   `"day"`. `"reign"` supports up to `"month"`, as it does not record the
#'   day a leader left office.
#'
#' @return A data frame with one row per country and period. Columns differ
#'   by dataset:
#'
#'   **archigos:** `cow`/`gw`, `year`, `leader`, `entry`, `exit`,
#'   `irregular_entry`, `irregular_exit`, `female_leader`, `yrborn`,
#'   `posttenurefate`, `leader_tenure`.
#'
#'   **reign:** `cow`/`gw`, `year`, `leader`, `female_leader`,
#'   `military_bg`, `birthyear`, `leader_tenure`.
#'
#'   `leader_tenure` counts the calendar years in office, including the
#'   current one, at every unit. Finer units add the time keys (`quarter`,
#'   or `month` and `day`) and `leader_tenure_quarters`,
#'   `leader_tenure_months`, or `leader_tenure_days`: the periods in office,
#'   including the current one.
#'
#' @details
#' REIGN gives the year and month (not the day) a leader left office; a
#' REIGN spell is taken to run to the last day of its exit month. Leaders
#' still in office when the REIGN data end (August 2021) have no exit date
#' in the source and are kept in office through that month.
#'
#' @source
#' **Archigos:** Goemans, H.E., Gleditsch, K.S., & Chiozza, G. (2009).
#' Introducing Archigos: A Dataset of Political Leaders.
#' *Journal of Peace Research*, 46(2), 269–283.
#' \url{https://web.archive.org/web/20241206095059/http://ksgleditsch.com/archigos.html}
#'
#' **REIGN:** Bell, C. (2021). REIGN: Rulers, Elections, and Irregular
#' Governance Dataset. One Earth Future Foundation.
#' \url{https://oefdatascience.github.io/REIGN.github.io/}
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
#' arch <- load_leader_data(1990, 2010, dataset = "archigos", coding_system = "cow")
#'
#' reign <- load_leader_data(1990, 2010, dataset = "reign", coding_system = "gw")
#'
#' # Leaders by month: Egypt, 2011
#' monthly <- load_leader_data(2011, 2011, coding_system = "cow", unit = "month")
#' monthly[monthly$cow == 651, c("year", "month", "leader")]
#'
#' @export
load_leader_data <- function(
    start_year    = 1945,
    end_year      = 2015,
    dataset       = c("archigos", "reign"),
    coding_system = c("cow", "gw"),
    unit          = c("year", "quarter", "month", "day")
) {
  check_year_range(start_year, end_year)
  dataset       <- match.arg(dataset)
  coding_system <- match.arg(coding_system)
  unit          <- match.arg(unit)
  keys          <- c(coding_system, time_keys(unit))

  spells <- leader_spells(dataset)
  if (dataset == "reign" && unit == "day") {
    stop(
      'REIGN records the month, not the day, on which a leader left office; ',
      'use `unit = "month"` or `dataset = "archigos"` for a country-day panel.',
      call. = FALSE
    )
  }

  # Every period each leader held office for any part of, within the
  # requested years.
  window_start <- as.Date(sprintf("%04d-01-01", as.integer(start_year)))
  window_end   <- as.Date(sprintf("%04d-12-31", as.integer(end_year)))
  clipped <- data.frame(
    code  = spells$ccode,
    id    = seq_len(nrow(spells)),
    start = pmax(spells$start, window_start),
    end   = pmin(spells$end, window_end)
  )
  clipped <- clipped[!is.na(clipped$start) & !is.na(clipped$end) &
                       clipped$start <= clipped$end, ]
  periods <- expand_spells(clipped, unit)
  periods <- periods[!duplicated(periods[c("code", "id", time_keys(unit))]), ]
  # The package's COW conventions: West Germany as 255, Czechoslovakia as
  # 316, Yemen as 678 or 679 by year.
  periods$code <- standardize_cow(periods$code, periods$year)
  if (coding_system == "gw") {
    month <- if ("month" %in% names(periods)) periods$month else NULL
    periods$code <- convert_state_code(periods$code, periods$year, "cow", "gw",
                                       month)
    periods <- periods[!is.na(periods$code), ]
  }

  # Several leaders in one period: keep the one who took office last, i.e.
  # the leader in office at the end of the period.
  periods$start_order <- spells$start_order[periods$id]
  periods <- periods |>
    dplyr::group_by(dplyr::across(dplyr::all_of(c("code", time_keys(unit))))) |>
    dplyr::slice_max(.data$start_order, n = 1, with_ties = FALSE) |>
    dplyr::ungroup()

  leader <- spells[periods$id, , drop = FALSE]
  data <- data.frame(code = as.integer(periods$code))
  names(data) <- coding_system
  for (k in time_keys(unit)) data[[k]] <- as.integer(periods[[k]])
  data <- cbind(data, leader[, spells_columns(dataset), drop = FALSE])
  data$leader_tenure <- as.integer(data$year - leader$start_yr + 1L)
  if (unit != "year") {
    data[[paste0("leader_tenure_", unit, "s")]] <- as.integer(
      period_index(data, unit) -
        period_index(leader_start_period(leader, unit), unit) + 1L
    )
  }
  data <- dplyr::as_tibble(data)

  data <- dplyr::arrange(data, dplyr::across(dplyr::all_of(keys)))

  check_unique_key(data, keys)

  return(data)
}

# Leader columns returned by load_leader_data(), after the keys.
spells_columns <- function(dataset) {
  switch(dataset,
    archigos = c("leader", "entry", "exit", "irregular_entry",
                 "irregular_exit", "female_leader", "yrborn",
                 "posttenurefate"),
    reign = c("leader", "female_leader", "military_bg", "birthyear")
  )
}

#' The period in which each leader took office
#'
#' @param leader Rows of [leader_spells()].
#' @param unit `"quarter"`, `"month"`, or `"day"`.
#'
#' @return A data frame with the time keys of `unit`.
#'
#' @keywords internal
leader_start_period <- function(leader, unit) {
  out <- data.frame(year = as.integer(format(leader$start, "%Y")))
  month <- as.integer(format(leader$start, "%m"))
  if (unit == "quarter") out$quarter <- (month - 1L) %/% 3L + 1L
  if (unit %in% c("month", "day")) out$month <- month
  if (unit == "day") out$day <- as.integer(format(leader$start, "%d"))
  out
}

#' Leader spells with start and end dates
#'
#' One row per leader spell, with `ccode` (COW), `start` and `end` (`Date`),
#' `start_yr`, a sort key `start_order`, and the leader attributes.
#'
#' Archigos gives exact dates. REIGN gives the year and month of entry and
#' exit (and the day of entry): a REIGN spell runs from the first day of its
#' entry month to the last day of its exit month. Leaders still in office at
#' the end of the REIGN data have no exit date; they are kept in office
#' through the last month the source covers.
#'
#' @param dataset `"archigos"` or `"reign"`.
#'
#' @return A data frame.
#'
#' @keywords internal
leader_spells <- function(dataset) {
  if (dataset == "archigos") {
    path <- system.file("extdata", "archigos_4.1.txt.xz", package = "contentiousR")
    if (path == "") {
      stop("Could not find `archigos_4.1.txt.xz` in package extdata.", call. = FALSE)
    }

    raw <- readr::read_tsv(
      path,
      show_col_types = FALSE,
      locale = readr::locale(encoding = "latin1")
    )

    spells <- raw |>
      dplyr::mutate(
        start           = as.Date(.data$startdate),
        end             = as.Date(.data$enddate),
        start_yr        = as.integer(format(.data$start, "%Y")),
        start_order     = as.numeric(.data$start),
        irregular_entry = as.integer(.data$entry %in% c("Irregular", "Foreign Imposition")),
        irregular_exit  = as.integer(.data$exit  %in% c("Irregular", "Foreign", "Suicide")),
        female_leader   = as.integer(.data$gender == "F"),
        ccode           = as.integer(.data$ccode)
      )
  }

  if (dataset == "reign") {
    path <- system.file("extdata", "reign_leader_list.csv.xz", package = "contentiousR")
    if (path == "") {
      stop("Could not find `reign_leader_list.csv.xz` in package extdata.", call. = FALSE)
    }

    # suppressMessages: readr renames empty trailing column headers to ...15/...16
    raw <- suppressMessages(
      readr::read_csv(path, show_col_types = FALSE,
                      locale = readr::locale(encoding = "latin1"))
    ) |>
      dplyr::select(dplyr::where(~ !all(is.na(.))))

    # Leaders in office when the data end have no exit year or month.
    last_month <- max(raw$eyear * 12 + raw$emonth, na.rm = TRUE)
    first_of <- function(year, month) {
      as.Date(sprintf("%04d-%02d-01", as.integer(year), as.integer(month)))
    }
    last_of <- function(year, month) {
      index <- 12L * as.integer(year) + as.integer(month)
      first_of(index %/% 12L, index %% 12L + 1L) - 1L
    }

    spells <- raw |>
      dplyr::filter(!is.na(.data$syear), !is.na(.data$smonth)) |>
      dplyr::mutate(
        open          = is.na(.data$eyear),
        eyear         = dplyr::if_else(.data$open, (last_month - 1) %/% 12, .data$eyear),
        emonth        = dplyr::if_else(.data$open, (last_month - 1) %% 12 + 1, .data$emonth),
        start         = first_of(.data$syear, .data$smonth),
        end           = last_of(.data$eyear, .data$emonth),
        start_yr      = as.integer(.data$syear),
        gender_int    = suppressWarnings(as.integer(.data$gender)),
        # In REIGN: 1 = male, 0 = female, -99 = unknown
        female_leader = dplyr::case_when(
          .data$gender_int == 0L  ~ 1L,
          .data$gender_int == 1L  ~ 0L,
          TRUE                    ~ NA_integer_
        ),
        military_bg   = as.integer(.data$militarycareer),
        ccode         = as.integer(.data$ccode),
        # Sort key: entry month, then entry day where given.
        start_order   = as.numeric(.data$syear) * 12 + .data$smonth +
          dplyr::coalesce(as.numeric(.data$sdate), 0) / 100
      )
  }

  as.data.frame(spells)
}
