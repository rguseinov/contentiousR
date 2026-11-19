#' Aggregate a panel to a coarser time unit
#'
#' @description
#' Collapses a country-day, country-month, or country-quarter panel to a
#' coarser unit (`"month"`, `"quarter"`, or `"year"`), for example to check
#' monthly results against annual ones or to combine sources at different
#' units.
#'
#' Columns are combined by these default rules:
#' \itemize{
#'   \item Conflict counts and totals (columns from [add_conflict()] such
#'     as `*_n_events`, `*_total`, `n_campaigns`, and NAVCO 3.0 fatalities
#'     and injuries): summed.
#'   \item Other numeric conflict columns, including onset and incidence
#'     indicators and maxima: maximum. Counts of distinct units
#'     (`*_n_active`, `arc_n_orgs`) also take the maximum, a lower bound:
#'     the same episode or organization can appear in several periods, so
#'     their sum would double-count.
#'   \item Conflict means and shares (`*_mean_*`, `*_share_*`): mean of the
#'     period values. This is not the mean over the underlying events.
#'   \item Character conflict columns: the distinct values, joined by "; ".
#'   \item All other columns (country names, annual data such as GDP,
#'     leaders): the value in the last period, i.e. at the end of the new
#'     period.
#' }
#' Sums and maxima of all-`NA` values are `NA`. Lags (`*_l`) and spell
#' counters (`*_spell`) are dropped: recompute them on the aggregated panel
#' with [add_lag()] and [add_spell_duration()].
#'
#' @param panel A panel from [build_states_panel()] with `unit = "day"`,
#'   `"month"`, or `"quarter"`, with any added data.
#' @param to Target unit: `"year"` (default), `"quarter"`, or `"month"`. Must
#'   be coarser than the panel's unit.
#' @param sum,max,mean,last Optional character vectors of column names that
#'   override the default rule for those columns.
#'
#' @return A panel at the unit `to`, with one row per country and period and
#'   the same columns as `panel` except the finer time keys, `date`, lags,
#'   and spell counters.
#'
#' @examples
#' monthly <- build_states_panel(2010, 2012, coding_system = "cow", unit = "month") |>
#'   add_gdp() |>
#'   add_conflict("mmad", fill_zero = TRUE)
#'
#' yearly <- aggregate_panel(monthly, to = "year")
#' yearly[yearly$cow == 651, c("year", "gdp_pcap", "mmad_onset", "mmad_n_events")]
#'
#' @export
aggregate_panel <- function(panel, to = c("year", "quarter", "month"),
                            sum = NULL, max = NULL, mean = NULL,
                            last = NULL) {
  to <- match.arg(to)
  from <- detect_panel_unit(panel)
  if (match(to, panel_units) >= match(from, panel_units)) {
    stop(
      "`panel` is country-", from, "; `to` must be a coarser unit than '",
      from, "'.", call. = FALSE
    )
  }
  if (to == "quarter" && !"month" %in% names(panel)) {
    stop("A country-quarter panel can only be built from a monthly or daily panel.",
         call. = FALSE)
  }
  coding_system <- detect_coding_system(panel)
  keys <- c(coding_system, time_keys(to))
  overrides <- list(sum = sum, max = max, mean = mean, last = last)
  for (rule in names(overrides)) {
    unknown <- setdiff(overrides[[rule]], names(panel))
    if (length(unknown) > 0L) {
      stop("`", rule, "` names columns not in `panel`: ",
           paste(unknown, collapse = ", "), call. = FALSE)
    }
  }

  data <- as.data.frame(panel)
  if (to == "quarter") {
    data$quarter <- (as.integer(data$month) - 1L) %/% 3L + 1L
  }
  data$.period <- period_index(panel, from)
  finer <- setdiff(c(time_keys(from), "date"), keys)
  dropped <- grep("(_l|_spell)$", names(data), value = TRUE)
  value_cols <- setdiff(names(data), c(keys, finer, dropped, ".period"))

  conflict_prefixes <- dataset_registry()$prefix[dataset_registry()$topic == "conflict"]
  is_conflict <- vapply(value_cols, function(col) {
    col == "n_campaigns" || any(startsWith(col, conflict_prefixes))
  }, logical(1))
  is_num <- vapply(data[value_cols], is.numeric, logical(1))

  rule <- stats::setNames(rep("last", length(value_cols)), value_cols)
  conflict_cols <- value_cols[is_conflict]
  rule[conflict_cols[!is_num[conflict_cols]]] <- "collapse"
  num_conflict <- conflict_cols[is_num[conflict_cols]]
  rule[num_conflict] <- "max"
  counts <- grepl(
    "(_n_[A-Za-z_]+|_total|^nvc3\\.0_(fatalities|injuries)_(low|high))$|^n_campaigns$",
    num_conflict
  ) & !grepl("_n_(active|orgs)$", num_conflict)
  rule[num_conflict[counts]] <- "sum"
  rule[num_conflict[grepl("_(mean|share)_", num_conflict)]] <- "mean"
  for (r in names(overrides)) rule[intersect(overrides[[r]], value_cols)] <- r

  fns <- list(
    sum = function(x) if (all(is.na(x))) x[NA_integer_][1] else base::sum(x, na.rm = TRUE),
    max = function(x) if (all(is.na(x))) x[NA_integer_][1] else base::max(x, na.rm = TRUE),
    mean = function(x) if (all(is.na(x))) NA_real_ else base::mean(x, na.rm = TRUE),
    last = function(x) x[length(x)],
    collapse = function(x) {
      values <- sort(unique(stats::na.omit(unlist(strsplit(as.character(x), "; ",
                                                           fixed = TRUE)))))
      if (length(values) == 0L) NA_character_ else paste(values, collapse = "; ")
    }
  )

  data <- data[order(data[[coding_system]], data$.period), , drop = FALSE]
  out <- data |>
    dplyr::group_by(dplyr::across(dplyr::all_of(keys))) |>
    dplyr::summarise(
      dplyr::across(dplyr::all_of(names(rule)[rule == "sum"]), fns$sum),
      dplyr::across(dplyr::all_of(names(rule)[rule == "max"]), fns$max),
      dplyr::across(dplyr::all_of(names(rule)[rule == "mean"]), fns$mean),
      dplyr::across(dplyr::all_of(names(rule)[rule == "last"]), fns$last),
      dplyr::across(dplyr::all_of(names(rule)[rule == "collapse"]), fns$collapse),
      .groups = "drop"
    )
  out <- out[, c(keys, value_cols), drop = FALSE]
  if (inherits(panel, "tbl_df")) {
    out <- dplyr::as_tibble(out)
  } else {
    out <- as.data.frame(out)
  }

  summed <- names(rule)[rule == "sum"]
  averaged <- names(rule)[rule == "mean"]
  message(
    "Aggregated country-", from, " to country-", to, ". ",
    if (length(summed)) paste0("Summed: ", paste(summed, collapse = ", "), ". "),
    if (length(averaged)) paste0("Mean of period values: ",
                                 paste(averaged, collapse = ", "), ". "),
    if (base::sum(rule == "max")) paste0("Maximum: ", base::sum(rule == "max"),
                                   " other conflict column(s). "),
    "Other columns take the value of the last ", from, ".",
    if (length(dropped)) paste0(
      " Dropped (recompute on the new panel): ",
      paste(dropped, collapse = ", "), "."
    )
  )

  out
}
