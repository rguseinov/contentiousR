## Build cn_bib: the bundled bibliography used by cn_cite().
##
## Source: data-raw/contentiousR_bib.bib -- edit that file, then re-run this
## script and devtools::document() to refresh data/cn_bib.rda.

cn_bib <- bibtex::read.bib("data-raw/contentiousR_bib.bib")

usethis::use_data(cn_bib, overwrite = TRUE)
