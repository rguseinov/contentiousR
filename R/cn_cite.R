#' Cite a bundled data source
#'
#' Looks up the bundled bibliography (`cn_bib`) by keyword or BibTeX key and
#' returns the matching entries. Printing the result (e.g. at the console)
#' shows them as BibTeX text, ready to paste into your own `.bib` file.
#'
#' @param x A search string. Matched against the `keywords` field by default
#'   (function names such as `"add_conflict()"` or `"load_gdp_data()"`, and
#'   `dataset =` values such as `"archigos"` or `"mec"`) as an exact match
#'   against one comma-separated keyword, or against BibTeX keys as a fixed
#'   substring match when `column = "bibtexkey"`. Neither is a regular
#'   expression.
#' @param column Which field to search: `"keywords"` (default) or
#'   `"bibtexkey"`.
#'
#' @return A `bibentry` object (with the additional class `cn_citation`)
#'   holding the matching entries. Its `print()` method displays them as
#'   BibTeX; all other `bibentry` methods, such as `format()` and
#'   `toBibtex()`, work as usual.
#'
#' @examples
#' cn_cite("archigos")
#' cn_cite("add_conflict()")
#' cn_cite("gleditschArmedConflict194620012002", column = "bibtexkey")
#'
#' @importFrom utils toBibtex
#' @export
cn_cite <- function(x, column = c("keywords", "bibtexkey")) {
  column <- match.arg(column)

  if (!is.character(x) || length(x) != 1L || is.na(x)) {
    stop("`x` must be a single, non-missing string.", call. = FALSE)
  }

  keys <- names(cn_bib)
  if (column == "bibtexkey") {
    matched <- grepl(x, keys, fixed = TRUE)
  } else {
    keywords <- lapply(seq_along(cn_bib), function(i) {
      value <- unclass(cn_bib[[i]])[[1]]$keywords
      if (is.null(value)) character(0) else trimws(strsplit(value, ",")[[1]])
    })
    matched <- vapply(keywords, function(k) x %in% k, logical(1))
  }

  if (!any(matched)) {
    stop("No bundled citation matches \"", x, "\".", call. = FALSE)
  }

  out <- cn_bib[matched]
  class(out) <- c("cn_citation", class(out))
  out
}

#' @export
#' @noRd
print.cn_citation <- function(x, ...) {
  writeLines(format(toBibtex(x)))
  invisible(x)
}
