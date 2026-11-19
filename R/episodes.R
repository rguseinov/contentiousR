# Datasets with episode or campaign spells.
spell_datasets <- c("navco1.3", "navco2.1", "beissinger", "raqed", "mec",
                    "omg")

#' Active episodes per country-period
#'
#' For campaign and episode datasets, counts the episodes in progress in each
#' country-period, from each episode's start to its end date. Used by
#' [add_conflict()].
#'
#' Start dates less precise than `unit` drop the episode, as for onsets. An
#' end date less precise than `unit` is taken to be the last day of the
#' period the source gives (for example, an episode that ended "in 2005" is
#' active through December 2005). Episodes the source codes as ongoing run to
#' the end of its coverage.
#'
#' @param dataset One of `spell_datasets`.
#' @param coding_system `"cow"` or `"gw"`.
#' @param start_year,end_year Years of the panel.
#' @param unit `"year"`, `"quarter"`, `"month"`, or `"day"`.
#'
#' @return A data frame with the country code, the time keys of `unit`,
#'   `<prefix>incidence` (1 if at least one episode was active), and
#'   `<prefix>n_active` (the number of active episodes).
#'
#' @keywords internal
episode_incidence <- function(dataset, coding_system, start_year, end_year,
                              unit) {
  reg <- dataset_registry()
  info <- reg[reg$dataset == dataset & reg$topic == "conflict", ]
  prefix <- info$prefix
  keys <- c(coding_system, time_keys(unit))
  if (end_year < info$start_year || start_year > info$end_year) {
    out <- as.data.frame(stats::setNames(
      rep(list(integer(0)), length(keys) + 2L),
      c(keys, paste0(prefix, c("incidence", "n_active")))
    ))
    return(out)
  }

  records <- suppressMessages(suppressWarnings(conflict_data(
    start_year = info$start_year, end_year = min(end_year, info$end_year),
    dataset = dataset, coding_system = coding_system, unit = "year"
  )))
  code <- records[[coding_system]]
  coverage_end <- as.Date(sprintf("%04d-12-31", info$end_year))

  if (dataset == "navco2.1") {
    # Campaign-year rows: each row is one campaign active in that year.
    spells <- data.frame(
      code = code,
      start = as.Date(sprintf("%04d-01-01", records$year)),
      end   = as.Date(sprintf("%04d-12-31", records$year)),
      start_precision = "year"
    )
  } else if (dataset == "navco1.3") {
    spells <- data.frame(
      code = code,
      start = as.Date(sprintf("%04d-01-01", records$year)),
      end   = as.Date(sprintf("%04d-12-31", records$nvc1.3_EYEAR)),
      start_precision = "year"
    )
  } else if (dataset == "raqed") {
    spells <- data.frame(
      code = code, start = records$raqed_start_date,
      end = records$raqed_end_date, start_precision = "day"
    )
  } else if (dataset == "mec") {
    end <- records$mec_edate
    end[is.na(end) & records$mec_ongoing %in% 1] <- coverage_end
    spells <- data.frame(
      code = code, start = records$mec_bdate, end = end,
      start_precision = "day"
    )
  } else if (dataset == "omg") {
    spells <- data.frame(
      code = code, start = records$omg_date_start, end = records$omg_date_end,
      start_precision = c("day", "month", "year")[records$omg_start_prec]
    )
  } else if (dataset == "beissinger") {
    start <- parse_beissinger_start(records$beissinger_startdatetxt)
    # End: start plus the source's duration in days (day-precise starts) or
    # in calendar months (month-precise starts); the source's end year
    # where only the year is known.
    end <- start$date + records$beissinger_daysduration - 1
    by_month <- start$precision %in% "month"
    last_month <- 12L * as.integer(format(start$date[by_month], "%Y")) +
      as.integer(format(start$date[by_month], "%m")) - 1L +
      as.integer(records$beissinger_monthsduration[by_month]) - 1L
    end[by_month] <- as.Date(sprintf(
      "%04d-%02d-01", (last_month + 1L) %/% 12L, (last_month + 1L) %% 12L + 1L
    )) - 1L
    by_year <- start$precision %in% "year" |
      (unit == "year" & !is.na(records$beissinger_endyear))
    end[by_year] <- as.Date(sprintf(
      "%04d-12-31", as.integer(records$beissinger_endyear[by_year])
    ))
    spells <- data.frame(
      code = code, start = start$date, end = end,
      start_precision = start$precision
    )
  }

  needed <- switch(unit, year = "year", quarter = , month = "month",
                   day = "day")
  precise <- switch(needed,
    year  = !is.na(spells$start_precision),
    month = spells$start_precision %in% c("day", "month"),
    day   = spells$start_precision %in% "day"
  )
  spells <- spells[precise & !is.na(spells$code) & !is.na(spells$start), ]
  spells$end[is.na(spells$end)] <- spells$start[is.na(spells$end)]
  spells$id <- seq_len(nrow(spells))

  # Clip to the panel window, then expand to periods.
  window_start <- as.Date(sprintf("%04d-01-01", as.integer(start_year)))
  window_end   <- as.Date(sprintf("%04d-12-31", as.integer(end_year)))
  spells$start <- pmax(spells$start, window_start)
  spells$end   <- pmin(spells$end, window_end)
  spells <- spells[spells$start <= spells$end, ]

  periods <- expand_spells(spells, unit)
  names(periods)[names(periods) == "code"] <- coding_system
  periods <- periods[!duplicated(periods[c(keys, "id")]), ]

  out <- periods |>
    dplyr::group_by(dplyr::across(dplyr::all_of(keys))) |>
    dplyr::summarise(n_active = dplyr::n(), .groups = "drop") |>
    dplyr::mutate(incidence = 1L, .before = "n_active")
  names(out)[names(out) %in% c("incidence", "n_active")] <-
    paste0(prefix, c("incidence", "n_active"))
  out
}

#' Expand date spells to the panel periods they overlap
#'
#' @param spells A data frame with `code`, `id`, `start`, and `end` (`Date`).
#' @param unit `"year"`, `"quarter"`, `"month"`, or `"day"`.
#'
#' @return A data frame with `code`, `id`, and the time keys of `unit`.
#'
#' @keywords internal
expand_spells <- function(spells, unit) {
  if (nrow(spells) == 0L) {
    out <- data.frame(code = integer(0), id = integer(0))
    for (k in time_keys(unit)) out[[k]] <- integer(0)
    return(out)
  }
  if (unit == "day") {
    n <- as.integer(spells$end - spells$start) + 1L
    idx <- rep(seq_len(nrow(spells)), n)
    date <- spells$start[idx] + (sequence(n) - 1L)
    return(data.frame(
      code = spells$code[idx], id = spells$id[idx],
      year = as.integer(format(date, "%Y")),
      month = as.integer(format(date, "%m")),
      day = as.integer(format(date, "%d"))
    ))
  }
  month_index <- function(d) {
    12L * as.integer(format(d, "%Y")) + as.integer(format(d, "%m")) - 1L
  }
  if (unit == "year") {
    y0 <- as.integer(format(spells$start, "%Y"))
    n <- as.integer(format(spells$end, "%Y")) - y0 + 1L
    idx <- rep(seq_len(nrow(spells)), n)
    return(data.frame(
      code = spells$code[idx], id = spells$id[idx],
      year = y0[idx] + sequence(n) - 1L
    ))
  }
  m0 <- month_index(spells$start)
  n <- month_index(spells$end) - m0 + 1L
  idx <- rep(seq_len(nrow(spells)), n)
  m <- m0[idx] + sequence(n) - 1L
  out <- data.frame(
    code = spells$code[idx], id = spells$id[idx],
    year = m %/% 12L, month = m %% 12L + 1L
  )
  if (unit == "quarter") {
    out$quarter <- (out$month - 1L) %/% 3L + 1L
    out$month <- NULL
  }
  out
}
