#' Cite a bundled data source
#'
#' Looks up the bundled bibliography (`cn_bib`) by keyword or BibTeX key and
#' prints the matching entries as BibTeX text, ready to paste into your own
#' `.bib` file.
#'
#' @param x A search string. Matched against the `keywords` field by default
#'   (function names such as `"add_conflict()"` or `"load_gdp_data()"`, and
#'   `dataset =` values such as `"archigos"` or `"mec"`), or against BibTeX
#'   keys when `column = "bibtexkey"`. The match is a fixed substring match,
#'   not a regular expression.
#' @param column Which field to search: `"keywords"` (default) or
#'   `"bibtexkey"`.
#'
#' @return Invisibly returns the matching `bibentry` objects. Called for the
#'   side effect of printing BibTeX text.
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

  keys <- names(cn_bib)
  if (column == "bibtexkey") {
    matched <- grepl(x, keys, fixed = TRUE)
  } else {
    keywords <- vapply(seq_along(cn_bib), function(i) {
      value <- unclass(cn_bib[[i]])[[1]]$keywords
      if (is.null(value)) "" else value
    }, character(1))
    matched <- grepl(x, keywords, fixed = TRUE)
  }

  if (!any(matched)) {
    stop("No bundled citation matches \"", x, "\".", call. = FALSE)
  }

  cat(format(toBibtex(cn_bib[matched])), sep = "\n")
  invisible(cn_bib[matched])
}
