#' Check year range
#'
#' @param start_year First year.
#' @param end_year Last year.
#' @param min_year Optional. If given, `start_year` must be at least this.
#' @param max_year Optional. If given, `end_year` must be at most this.
#'
#' @return Invisibly `TRUE` if the range is valid; otherwise an error is
#'   raised.
#'
#' @keywords internal
check_year_range <- function(start_year, end_year, min_year = NULL, max_year = NULL) {
  if (
    !is.numeric(start_year) || length(start_year) != 1L ||
      is.na(start_year) || !is.finite(start_year) || start_year %% 1 != 0
  ) {
    stop("`start_year` must be a single, finite whole year.", call. = FALSE)
  }

  if (
    !is.numeric(end_year) || length(end_year) != 1L ||
      is.na(end_year) || !is.finite(end_year) || end_year %% 1 != 0
  ) {
    stop("`end_year` must be a single, finite whole year.", call. = FALSE)
  }

  if (start_year > end_year) {
    stop("`start_year` must be less than or equal to `end_year`.", call. = FALSE)
  }

  if (!is.null(min_year) && start_year < min_year) {
    stop("`start_year` must be ", min_year, " or later.", call. = FALSE)
  }

  if (!is.null(max_year) && end_year > max_year) {
    stop("`end_year` must be ", max_year, " or earlier.", call. = FALSE)
  }

  invisible(TRUE)
}


#' Check a logical flag
#'
#' @param value Value to validate.
#' @param name Argument name used in an error message.
#'
#' @return Invisibly `TRUE` if `value` is a single non-missing logical;
#'   otherwise an error is raised.
#'
#' @keywords internal
check_flag <- function(value, name) {
  if (!is.logical(value) || length(value) != 1L || is.na(value)) {
    stop("`", name, "` must be `TRUE` or `FALSE`.", call. = FALSE)
  }

  invisible(TRUE)
}


#' Check that data are uniquely identified by key columns
#'
#' @param data A data frame.
#' @param keys Character vector of key column names.
#'
#' @return Invisibly, `data` unchanged if the keys are unique; otherwise an
#'   error is raised.
#'
#' @keywords internal
check_unique_key <- function(data, keys) {
  missing_keys <- setdiff(keys, names(data))

  if (length(missing_keys) > 0) {
    stop(
      "Missing key columns: ",
      paste(missing_keys, collapse = ", "),
      call. = FALSE
    )
  }

  dupes <- data |>
    dplyr::count(dplyr::across(dplyr::all_of(keys))) |>
    dplyr::filter(.data$n > 1)

  if (nrow(dupes) > 0) {
    stop(
      "Data are not uniquely identified by: ",
      paste(keys, collapse = ", "),
      call. = FALSE
    )
  }

  invisible(data)
}


#' Return a typed missing value for an all-missing maximum
#'
#' @param x A vector.
#'
#' @return A length-one vector of the same type as `x`: the maximum of the
#'   non-missing values, or `NA` if there are none.
#'
#' @keywords internal
safe_max <- function(x) {
  if (length(x) == 0L || all(is.na(x))) {
    return(x[NA_integer_][1L])
  }

  max(x, na.rm = TRUE)
}


#' Sum a vector while preserving all-missing groups
#'
#' @param x A numeric vector.
#'
#' @return A length-one numeric: the sum of the non-missing values, or
#'   `NA_real_` if there are none.
#'
#' @keywords internal
safe_sum <- function(x) {
  if (length(x) == 0L || all(is.na(x))) {
    return(NA_real_)
  }

  sum(x, na.rm = TRUE)
}


#' Average a vector while preserving all-missing groups
#'
#' @param x A numeric vector.
#'
#' @return A length-one numeric: the mean of the non-missing values, or
#'   `NA_real_` if there are none.
#'
#' @keywords internal
safe_mean <- function(x) {
  if (length(x) == 0L || all(is.na(x))) {
    return(NA_real_)
  }

  mean(x, na.rm = TRUE)
}

#' Detect coding system from a panel data frame
#'
#' @param panel A data frame produced by `build_states_panel()`.
#'
#' @return `"cow"` or `"gw"`.
#'
#' @keywords internal
detect_coding_system <- function(panel) {
  if (!is.data.frame(panel)) {
    stop("`panel` must be a data frame.", call. = FALSE)
  }

  coding_columns <- intersect(c("cow", "gw"), names(panel))
  if (length(coding_columns) != 1L) {
    stop(
      "`panel` must contain exactly one country-code column: 'cow' or 'gw'.",
      call. = FALSE
    )
  }
  if (!"year" %in% names(panel)) {
    stop("`panel` must contain a 'year' column.", call. = FALSE)
  }
  if (nrow(panel) == 0L || all(is.na(panel$year))) {
    stop("`panel` must contain at least one non-missing year.", call. = FALSE)
  }
  if (!is.numeric(panel$year) || any(!is.finite(panel$year), na.rm = TRUE)) {
    stop("`panel$year` must contain finite numeric years.", call. = FALSE)
  }

  coding_columns
}


#' Load an RData file from package extdata
#'
#' @param filename Character. Name of the `.RData` file located in
#'   `inst/extdata`.
#'
#' @return The single object stored in the `.RData` file.
#'
#' @keywords internal
read_rdata_from_extdata <- function(filename) {
  path <- system.file(
    "extdata",
    filename,
    package = "contentiousR"
  )
  if (path == "") {
    stop(
      "Could not find `", filename, "` in package extdata.",
      call. = FALSE
    )
  }
  env <- new.env(parent = emptyenv())
  obj_names <- suppressWarnings(load(path, envir = env))
  if (length(obj_names) != 1) {
    stop(
      "`", filename, "` must contain exactly one object, but contains: ",
      paste(obj_names, collapse = ", "),
      call. = FALSE
    )
  }
  env[[obj_names]]
}


#' Mark every character column of a data frame as UTF-8
#'
#' @param data A data frame.
#'
#' @return `data`, with `Encoding()` set to `"UTF-8"` on every element of
#'   every character column.
#'
#' @details
#' Several bundled sources (NAVCO 1.3/2.1, Beissinger, RAQED, OMG) contain
#' genuinely UTF-8-encoded text (e.g. curly apostrophes in campaign names
#' like "Student's Anti-Chun Protest") that R leaves tagged as
#' `Encoding() == "unknown"` after loading, whether from an `.RData` file
#' or `readr::read_csv()` without an explicit `locale`. An "unknown"
#' encoding is treated as the platform's native encoding wherever it's
#' next converted -- harmless on macOS/Linux, where native is already
#' UTF-8, but on Windows this silently corrupts the string (observed as
#' an embedded `nul` byte, which makes `R CMD check`'s vignette rebuild
#' fail outright). Explicitly tagging the bytes as UTF-8, which they
#' already are, avoids that native-encoding guess entirely.
#'
#' @keywords internal
mark_utf8 <- function(data) {
  char_cols <- names(data)[vapply(data, is.character, logical(1))]
  for (col in char_cols) {
    Encoding(data[[col]]) <- "UTF-8"
  }
  data
}

#' Detect the time unit of a panel
#'
#' A panel from `build_states_panel(unit = "day")` has `year`, `month`,
#' `day`, and `date` columns; one from `unit = "month"` has `year` and
#' `month`; one from `unit = "quarter"` has `year` and `quarter`; a
#' country-year panel has `year` only.
#'
#' @param panel A data frame produced by `build_states_panel()`.
#'
#' @return `"year"`, `"quarter"`, `"month"`, or `"day"`.
#'
#' @keywords internal
detect_panel_unit <- function(panel) {
  if (all(c("month", "day") %in% names(panel))) {
    return("day")
  }
  if ("month" %in% names(panel)) {
    return("month")
  }
  if ("quarter" %in% names(panel)) {
    return("quarter")
  }
  "year"
}

# Time units supported by panels, from coarsest to finest.
panel_units <- c("year", "quarter", "month", "day")

#' Time key columns for a panel unit
#'
#' @param unit `"year"`, `"quarter"`, `"month"`, or `"day"`.
#'
#' @return A character vector of the time columns that, with the country
#'   code, identify one panel row.
#'
#' @keywords internal
time_keys <- function(unit) {
  switch(unit,
    year    = "year",
    quarter = c("year", "quarter"),
    month   = c("year", "month"),
    day     = c("year", "month", "day")
  )
}

#' Sequential period index of a panel row
#'
#' Consecutive periods differ by exactly one: years for a country-year
#' panel, quarters (`4 * year + quarter`) for a country-quarter panel,
#' months (`12 * year + month`) for a country-month panel, and days for a
#' country-day panel.
#'
#' @param panel A data frame produced by `build_states_panel()`.
#' @param unit `"year"`, `"quarter"`, `"month"`, or `"day"`.
#'
#' @return A numeric vector, one value per row.
#'
#' @keywords internal
period_index <- function(panel, unit = detect_panel_unit(panel)) {
  switch(unit,
    year    = panel$year,
    quarter = as.integer(4L * panel$year + panel$quarter),
    month   = as.integer(12L * panel$year + panel$month),
    day     = as.integer(as.Date(sprintf(
      "%04d-%02d-%02d", as.integer(panel$year), as.integer(panel$month),
      as.integer(panel$day)
    )))
  )
}

#' Stop unless a panel is country-year
#'
#' @param panel A data frame produced by `build_states_panel()`.
#' @param fun Name of the calling function, used in the error message.
#'
#' @return `NULL`, invisibly; called for its error.
#'
#' @keywords internal
check_yearly_panel <- function(panel, fun) {
  unit <- detect_panel_unit(panel)
  if (unit != "year") {
    stop(
      "`", fun, "()` requires a country-year panel, but `panel` is ",
      "country-", unit, ". Build one with `build_states_panel(unit = \"year\")`.",
      call. = FALSE
    )
  }
  invisible(NULL)
}

#' Parse NAVCO 3.0 count strings into lower and upper bounds
#'
#' NAVCO 3.0 records fatalities, injuries, and participants either as a
#' number ("11") or as a range ("500 - 3000", "100-300"); "." marks a
#' missing value.
#'
#' @param x Character vector.
#'
#' @return A list with numeric vectors `low` and `high`.
#'
#' @keywords internal
parse_count_range <- function(x) {
  x <- trimws(as.character(x))
  parts <- strsplit(x, "\\s*-\\s*")
  low <- suppressWarnings(as.numeric(vapply(
    parts, function(p) if (length(p) >= 1L) p[[1L]] else NA_character_,
    character(1)
  )))
  high <- suppressWarnings(as.numeric(vapply(
    parts, function(p) if (length(p) >= 1L) p[[length(p)]] else NA_character_,
    character(1)
  )))
  bad <- is.na(low) | is.na(high) | vapply(parts, length, integer(1)) > 2L
  low[bad] <- NA_real_
  high[bad] <- NA_real_
  list(low = low, high = high)
}

#' Drop records whose date is less precise than the requested unit
#'
#' @param data A data frame with `year` and, for sub-annual units, `month`
#'   and `day` columns (`NA` where the source does not report them). For a
#'   quarterly unit, `quarter` is derived from `month`.
#' @param keys Time key columns, from [time_keys()].
#' @param dataset Dataset name, used in the message.
#' @param quiet Logical. Suppress the message.
#'
#' @return `data` without rows that have a missing time key.
#'
#' @keywords internal
drop_imprecise_dates <- function(data, keys, dataset, quiet = FALSE) {
  if ("quarter" %in% keys) {
    data$quarter <- (as.integer(data$month) - 1L) %/% 3L + 1L
  }
  missing <- !stats::complete.cases(data[, keys, drop = FALSE])
  if (any(missing) && !quiet && length(keys) > 1L) {
    message(
      sum(missing), " '", dataset, "' record(s) without a ",
      if ("day" %in% keys) "day" else "month",
      "-precise start date were dropped."
    )
  }
  data[!missing, , drop = FALSE]
}

#' Parse the start dates of the Beissinger Revolutionary Episodes Dataset
#'
#' The source's `startdatetxt` gives a full date ("June 2, 1899"), a month
#' ("August 1899"), or a year ("1964").
#'
#' @param x Character vector of `startdatetxt` values.
#'
#' @return A list with `date` (a `Date`, with placeholder day or month where
#'   the source gives none) and `precision` (`"day"`, `"month"`, or
#'   `"year"`).
#'
#' @keywords internal
parse_beissinger_start <- function(x) {
  x <- trimws(x)
  lc <- Sys.getlocale("LC_TIME")
  on.exit(Sys.setlocale("LC_TIME", lc), add = TRUE)
  Sys.setlocale("LC_TIME", "C")
  day   <- as.Date(x, format = "%B %d, %Y")
  month <- as.Date(paste("1", x), format = "%d %B %Y")
  year  <- as.Date(paste0(x, "-01-01"), format = "%Y-%m-%d")
  date <- day
  date[is.na(date)] <- month[is.na(date)]
  date[is.na(date)] <- year[is.na(date)]
  precision <- ifelse(!is.na(day), "day",
                      ifelse(!is.na(month), "month",
                             ifelse(!is.na(year), "year", NA_character_)))
  list(date = date, precision = precision)
}

#' Convert country codes between COW and Gleditsch-Ward, by year
#'
#' `countrycode` maps codes one to one, without regard to the year, and
#' has no equivalent for several states. This function handles the cases
#' where the two systems differ:
#' \itemize{
#'   \item Germany: COW 255 is GW 255 up to 1945 and GW 260 from 1946; COW
#'     260 (German Federal Republic) is GW 260.
#'   \item Serbia and Yugoslavia: COW 345 throughout; GW 340 (Serbia) up to
#'     1915 and from June 2006, 345 (Yugoslavia) in between.
#'   \item Czechoslovakia and the Czech Republic: GW 315 up to 1992, 316 from
#'     1993.
#'   \item Yemen: COW 678 (Yemen Arab Republic) up to 1990 and 679 (Yemen)
#'     from 1991; GW 678 throughout.
#'   \item Vietnam: 816 in both systems (`countrycode` gives GW 815, a
#'     19th-century state).
#'   \item Microstates numbered differently: Kiribati (COW 946, GW 970),
#'     Nauru (970, 971), Tonga (955, 972), Tuvalu (947, 973).
#' }
#' Other codes that exist in both systems' state lists keep their number;
#' the rest go through `countrycode`.
#'
#' The COW codes returned follow the package's COW panels, which code West
#' Germany as 255 and Czechoslovakia as 316 (see [standardize_cow()]).
#'
#' @param code Integer vector of codes.
#' @param year Integer vector of years, recycled to `code`.
#' @param from,to `"cow"` or `"gw"`.
#' @param month Optional integer vector of months, used for the 2006 split
#'   of Serbia and Montenegro (GW 340 from June 2006). Without it, all of
#'   2006 is GW 340.
#'
#' @return An integer vector of codes in `to`; `NA` where there is no
#'   equivalent.
#'
#' @keywords internal
convert_state_code <- function(code, year, from, to, month = NULL) {
  code <- as.integer(code)
  year <- rep_len(as.integer(year), length(code))
  if (from == to) {
    return(if (to == "cow") standardize_cow(code, year) else code)
  }
  micro_cow <- c(946L, 970L, 955L, 947L)
  micro_gw  <- c(970L, 971L, 972L, 973L)

  if (from == "cow") {
    out <- ifelse(
      code %in% states::gwstates$gwcode,
      code,
      suppressWarnings(as.integer(countrycode::countrycode(code, "cown", "gwn")))
    )
    out[code %in% micro_cow] <- micro_gw[match(code[code %in% micro_cow], micro_cow)]
    out[code %in% c(678L, 679L)] <- 678L
    out[code %in% 816L] <- 816L
    out[code %in% 260L] <- 260L
    out[code %in% 255L] <- ifelse(year[code %in% 255L] <= 1945L, 255L, 260L)
    out[code %in% c(315L, 316L)] <- ifelse(year[code %in% c(315L, 316L)] <= 1992L, 315L, 316L)
    yugo <- code %in% 345L
    serbia <- year < 1916L | year > 2006L
    if (!is.null(month)) {
      month <- rep_len(as.integer(month), length(code))
      serbia <- serbia | (year == 2006L & !is.na(month) & month >= 6L)
    } else {
      serbia <- serbia | year == 2006L
    }
    out[yugo] <- ifelse(serbia[yugo], 340L, 345L)
    return(as.integer(out))
  }

  out <- ifelse(
    code %in% states::cowstates$cowcode,
    code,
    suppressWarnings(as.integer(countrycode::countrycode(code, "gwn", "cown")))
  )
  out[code %in% micro_gw] <- micro_cow[match(code[code %in% micro_gw], micro_gw)]
  out[code %in% 815L] <- NA_integer_
  out[code %in% 816L] <- 816L
  out[code %in% c(340L, 345L)] <- 345L
  yemen <- code %in% 678L
  out[yemen] <- ifelse(year[yemen] >= 1991L, 679L, 678L)
  standardize_cow(as.integer(out), year)
}

#' Apply the package's COW panel conventions to COW codes
#'
#' The package's COW panels code the German Federal Republic (COW 260,
#' 1955-1990) as 255 and Czechoslovakia (COW 315, up to 1992) as 316, so
#' that each state has one code over time. Data joined to these panels must
#' use the same codes.
#'
#' With `year`, Yemen is also coded by period: 678 (Yemen Arab Republic) up
#' to 1990 and 679 (Yemen) from 1991, as some sources use one code
#' throughout.
#'
#' @param code Integer vector of COW codes.
#' @param year Optional integer vector of years.
#'
#' @return `code` with 260 recoded to 255 and 315 to 316.
#'
#' @keywords internal
standardize_cow <- function(code, year = NULL) {
  code <- as.integer(code)
  code[code %in% 260L] <- 255L
  code[code %in% 315L] <- 316L
  if (!is.null(year)) {
    year <- rep_len(as.integer(year), length(code))
    code[code %in% 678L & year >= 1991L] <- 679L
    code[code %in% 679L & year <= 1989L] <- 678L
  }
  code
}

#' Country names for state codes
#'
#' Uses `countrycode`, and the `states` package's names where `countrycode`
#' has none (for example GW 816, Vietnam, and several microstates).
#'
#' @param code Integer vector of codes.
#' @param coding_system `"cow"` or `"gw"`.
#'
#' @return A character vector.
#'
#' @keywords internal
state_names <- function(code, coding_system) {
  origin <- if (coding_system == "cow") "cown" else "gwn"
  name <- suppressWarnings(countrycode::countrycode(code, origin, "country.name"))
  table <- if (coding_system == "cow") states::cowstates else states::gwstates
  code_col <- if (coding_system == "cow") "cowcode" else "gwcode"
  fallback <- table$country_name[match(code, table[[code_col]])]
  name[is.na(name)] <- fallback[is.na(name)]
  if (coding_system == "gw") name[code %in% 816L] <- "Vietnam"
  name
}

#' Replace a data frame's COW code with the GW code
#'
#' @param data A data frame with `cow` and `year` (and optionally `month`).
#'
#' @return `data` with `gw` in place of `cow`, rows without a GW equivalent
#'   dropped, and `gw` as the first column.
#'
#' @keywords internal
cow_to_gw_column <- function(data) {
  month <- if ("month" %in% names(data)) data$month else NULL
  data$gw <- convert_state_code(data$cow, data$year, "cow", "gw", month)
  data <- data[!is.na(data$gw), setdiff(names(data), "cow"), drop = FALSE]
  data[c("gw", setdiff(names(data), "gw"))]
}

#' COW codes of the Mass Mobilization data
#'
#' The Mass Mobilization data use several codes that differ from COW: 341
#' for Kosovo (COW 347; COW 341 is Montenegro), 347 for Yugoslavia and
#' Serbia and Montenegro in 1992-2006 (COW 345), 342 for Serbia from 2006
#' (COW 345), 348 for Montenegro (COW 341), 364 for the USSR (COW 365), 525
#' for South Sudan (COW 626), 529 for Ethiopia from 2016 (COW 530), and 678
#' for Yemen from 2016 (COW 679). This maps them to COW and applies
#' [standardize_cow()].
#'
#' @param code Integer vector of Mass Mobilization `ccode` values.
#' @param year Integer vector of years.
#'
#' @return An integer vector of COW codes.
#'
#' @keywords internal
mm_cow_code <- function(code, year) {
  code <- as.integer(code)
  map <- c("341" = 347L, "347" = 345L, "342" = 345L, "348" = 341L,
           "364" = 365L, "525" = 626L, "529" = 530L)
  hit <- as.character(code) %in% names(map)
  code[hit] <- map[as.character(code[hit])]
  standardize_cow(code, year)
}

#' Convert the country-code column of a country-period data frame
#'
#' Applies [convert_state_code()] to `data[[code_col]]` and stores the
#' result in a column named `to`. Rows without an equivalent are dropped.
#' Where two source codes map to the same code and period (for example COW
#' 255 and 260 in 1990, which the package's COW panels both code 255), the
#' row whose source code equals the new code is kept.
#'
#' @param data A data frame with `year` and a code column.
#' @param code_col Name of the code column.
#' @param from,to `"cow"` or `"gw"`.
#'
#' @return `data` with the code column `to` first.
#'
#' @keywords internal
convert_code_column <- function(data, code_col, from, to) {
  month <- if ("month" %in% names(data)) data$month else NULL
  source_code <- as.integer(data[[code_col]])
  new <- convert_state_code(source_code, data$year, from, to, month)
  keep <- !is.na(new)
  data <- data[keep, setdiff(names(data), code_col), drop = FALSE]
  data[[to]] <- new[keep]
  exact <- (source_code == new)[keep]
  data <- data[order(!exact), , drop = FALSE]
  keys <- c(to, intersect(c("year", "quarter", "month", "day"), names(data)))
  data <- data[!duplicated(data[keys]), , drop = FALSE]
  data <- data[do.call(order, unname(as.list(data[keys]))), , drop = FALSE]
  data[c(to, setdiff(names(data), to))]
}
