## Build the data files in inst/extdata from the original source downloads.
##
## Usage, from the package root:
##   1. Put the source files in data-raw/source/ under the names listed below.
##      They may be uncompressed or gzip/bzip2/xz-compressed (e.g. both
##      "mmad_events.csv" and "mmad_events.csv.gz" are accepted). This folder
##      is git-ignored; data-raw/ as a whole is excluded from the package
##      build.
##   2. source("data-raw/extdata.R")
##   3. Run the tests and R CMD check.
##
## Requires 'readr' and 'haven'. 'haven' is needed only here, not by the
## package.
##
## What this does, to keep the package below CRAN's 5 MB guideline:
##   * every text file is stored xz-compressed, and every .rds/.RData file
##     is re-saved with xz compression;
##   * Stata files (MEC, NMC) are stored as the object haven::read_dta()
##     returns, saved as .rds;
##   * the Mass Mobilization, SCAD and Gapminder files keep only the columns
##     the package reads (all rows, values unchanged as text).
## The column lists below must match the loaders in R/conflict_data.R and
## R/load_gdp_data.R. If a source release renames or adds columns that a
## loader needs, update both places.

prepare_extdata <- function(source_dir = "data-raw/source",
                            out_dir = "inst/extdata") {
  dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

  src <- function(name) {
    candidates <- file.path(source_dir, paste0(name, c("", ".gz", ".bz2", ".xz")))
    hit <- candidates[file.exists(candidates)]
    if (length(hit) == 0L) {
      stop("Source file not found in ", source_dir, ": ", name, call. = FALSE)
    }
    hit[[1L]]
  }
  out <- function(name) file.path(out_dir, name)

  # gzfile() reads uncompressed, gzip, bzip2 and xz files alike.
  read_raw <- function(path) {
    con <- gzfile(path, "rb")
    on.exit(close(con))
    bytes <- list()
    repeat {
      chunk <- readBin(con, "raw", n = 1e7)
      if (length(chunk) == 0L) break
      bytes[[length(bytes) + 1L]] <- chunk
    }
    do.call(c, bytes)
  }

  write_xz <- function(bytes, path) {
    con <- xzfile(path, "wb", compression = 9)
    on.exit(close(con))
    writeBin(bytes, con)
  }

  resave_rdata <- function(from, to) {
    env <- new.env(parent = emptyenv())
    objs <- load(from, envir = env)
    save(list = objs, envir = env, file = to, compress = "xz")
  }

  # Keep only `keep` columns, every row, values as the original text.
  trim_csv <- function(from, to, keep, encoding = "UTF-8") {
    data <- readr::read_csv(
      from,
      col_types = readr::cols(.default = "c"),
      locale = readr::locale(encoding = encoding),
      na = character(),
      trim_ws = FALSE
    )
    missing <- setdiff(keep, names(data))
    if (length(missing) > 0L) {
      stop(basename(from), " lacks columns: ", paste(missing, collapse = ", "),
           call. = FALSE)
    }
    con <- xzfile(to, "wb", compression = 9)
    on.exit(close(con))
    readr::write_csv(data[, keep], con, na = "")
  }

  dta_to_rds <- function(from, to) {
    data <- haven::read_dta(from)
    if (any(vapply(data, inherits, logical(1), "haven_labelled"))) {
      stop(basename(from), " has labelled columns; convert them first.",
           call. = FALSE)
    }
    saveRDS(data, to, compress = "xz")
  }

  # Text files: stored as-is, xz-compressed.
  for (name in c("archigos_4.1.txt", "reign_leader_list.csv",
                 "mmad_events.csv", "UcdpPrioConflict_v26_1.csv",
                 "revolutionary_episodes_beissinger.csv",
                 "revolutionary_episodes_csra.csv")) {
    write_xz(read_raw(src(name)), out(paste0(name, ".xz")))
  }

  # R data files: re-saved with xz compression.
  for (name in c("fariss_gdp.rds", "fariss_gdppc.rds", "fariss_pop.rds",
                 "estimates_milburden_20250429.rds",
                 "estimates_milex_con_20250429.rds")) {
    saveRDS(readRDS(src(name)), out(name), compress = "xz")
  }
  for (name in c("NAVCO_1.3.RData", "NAVCO_2.1.RData", "un_population.RData")) {
    resave_rdata(src(name), out(name))
  }

  # Spreadsheets: copied unchanged (.xlsx is already compressed).
  for (name in c("SIPRI-Milex-data-1949-2025_v1.2.xlsx",
                 "UCDP_VPP_Dataset_v26_1.xlsx")) {
    file.copy(src(name), out(name), overwrite = TRUE)
  }

  # Stata files: stored as .rds.
  dta_to_rds(src("MEC.dta"), out("MEC.rds"))
  dta_to_rds(src("NMC-70-abridged.dta"), out("NMC-70-abridged.rds"))

  # Mass Mobilization: drop the columns conflict_data("mm") never reads.
  env <- new.env(parent = emptyenv())
  obj <- load(src("mmALL_073120.RData"), envir = env)
  stopifnot(length(obj) == 1L)
  mm_drop <- c("id", "country", "location", "sources", "notes",
               "startday", "startmonth", "startyear",
               "endday", "endmonth", "endyear",
               "protest", "protestnumber", "region", "participants_category")
  env[[obj]] <- env[[obj]][, setdiff(names(env[[obj]]), mm_drop)]
  save(list = obj, envir = env, file = out("mmALL_073120.RData"),
       compress = "xz")

  # SCAD: the columns conflict_data("scad") reads. The Africa file spells
  # the LGBTQ column "lgtbq_issue"; the loader renames it.
  scad_keep <- c("eventid", "ccode", "styr", "etype", "escalation", "npart",
                 "ndeath", "repress", "cgovtarget", "rgovtarget",
                 "female_event")
  trim_csv(src("SCAD2018Africa_Final.csv"), out("SCAD2018Africa_Final.csv.xz"),
           c(scad_keep, "lgtbq_issue"), encoding = "latin1")
  trim_csv(src("SCAD2018LatinAmerica_Final.csv"),
           out("SCAD2018LatinAmerica_Final.csv.xz"),
           c(scad_keep, "lgbtq_issue"), encoding = "latin1")

  # Gapminder: the columns load_gdp_data("gapminder") reads.
  trim_csv(src("gdp_gapminder_v32.csv"), out("gdp_gapminder_v32.csv.xz"),
           c("name", "year", "gdp_pcap"))

  invisible(out_dir)
}

prepare_extdata()
