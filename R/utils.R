#' Check year range
#'
#' @param start_year First year.
#' @param end_year Last year.
#'
#' @keywords internal
check_year_range <- function(start_year, end_year) {
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
