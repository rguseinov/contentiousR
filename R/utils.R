#' Check year range
#'
#' @param start_year First year.
#' @param end_year Last year.
#' @param min_year Optional. If given, `start_year` must be at least this.
#' @param max_year Optional. If given, `end_year` must be at most this.
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
#' Several bundled sources (NAVCO 1.3/2.1, Beissinger, CSRA) contain
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
