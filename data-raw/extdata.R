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
## Requires 'readr', 'readxl', 'haven', and 'wpp2024'. 'haven' and
## 'wpp2024' are needed only here, not by the package. 'wpp2024' is not on
## CRAN: remotes::install_github("PPgp/wpp2024").
##
## What this does, to keep the package below CRAN's 5 MB guideline:
##   * every text file is stored xz-compressed, and every .rds/.RData file
##     is re-saved with xz compression;
##   * Stata files (MEC, NMC) are stored as the object haven::read_dta()
##     returns, saved as .rds;
##   * the Mass Mobilization, SCAD and Gapminder files keep only the columns
##     the package reads (all rows, values unchanged as text);
##   * SIPRI keeps only the "Constant (2024) US$" and "Share of GDP" sheets,
##     reshaped to one long country-year table saved as .rds;
##   * RAQED keeps only the "Event table" sheet, stored as CSV;
##   * OMG drops its free-text note, source, and coder columns;
##   * ARC 2.0 events drop the country name and abbreviation columns;
##   * NAVCO 3.0 keeps only the columns conflict_data("navco3.0") reads;
##   * UN WPP 2024 population estimates are taken from the 'wpp2024'
##     package: total population of the 237 countries and areas, without
##     regional aggregates, keyed by UN country code.
## The column lists below must match the loaders in R/conflict_data.R and
## R/load_gdp_data.R. If a source release renames or adds columns that a
## loader needs, update both places.

# Parse one wide SIPRI military expenditure sheet into long format
#
# @param path Path to the SIPRI xlsx file.
# @param sheet Sheet name.
#
# @return A data frame with `country`, `year`, `value`.
#
read_sipri_sheet <- function(path, sheet) {
  # suppressMessages: readxl renames the untitled header columns (...1, ...2, ...)
  raw <- suppressMessages(readxl::read_xlsx(path, sheet = sheet, col_names = FALSE))

  header_row <- which(vapply(seq_len(nrow(raw)), function(i) {
    any(as.character(unlist(raw[i, ])) == "Country", na.rm = TRUE)
  }, logical(1)))[1]

  header      <- as.character(unlist(raw[header_row, ]))
  country_col <- which(header == "Country")
  year_cols   <- which(grepl("^(19|20)[0-9]{2}$", header))
  years       <- as.integer(header[year_cols])

  body <- raw[(header_row + 1):nrow(raw), ]

  long <- lapply(seq_along(year_cols), function(i) {
    data.frame(
      country = as.character(unlist(body[, country_col])),
      year    = years[i],
      value   = suppressWarnings(as.numeric(unlist(body[, year_cols[i]]))),
      stringsAsFactors = FALSE
    )
  })

  dplyr::bind_rows(long) |>
    tidyr::drop_na("country") |>
    dplyr::filter(!is.na(.data$value))
}


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
                 "revolutionary_episodes_beissinger.csv")) {
    write_xz(read_raw(src(name)), out(paste0(name, ".xz")))
  }

  # R data files: re-saved with xz compression.
  for (name in c("fariss_gdp.rds", "fariss_gdppc.rds", "fariss_pop.rds",
                 "estimates_milburden_20250429.rds",
                 "estimates_milex_con_20250429.rds")) {
    saveRDS(readRDS(src(name)), out(name), compress = "xz")
  }
  for (name in c("NAVCO_1.3.RData", "NAVCO_2.1.RData")) {
    resave_rdata(src(name), out(name))
  }

  # Spreadsheets: copied unchanged (.xlsx is already compressed).
  file.copy(src("UCDP_VPP_Dataset_v26_1.xlsx"),
            out("UCDP_VPP_Dataset_v26_1.xlsx"), overwrite = TRUE)

  # SIPRI: the two sheets load_military_expenditure_data("sipri") uses,
  # reshaped to one long country-year table and saved as .rds (the full
  # workbook has ten sheets and is about 0.9 MB).
  sipri_path <- src("SIPRI-Milex-data-1949-2025_v1.2.xlsx")
  sipri <- dplyr::full_join(
    dplyr::rename(read_sipri_sheet(sipri_path, "Constant (2024) US$"),
                  sipri_milex = "value"),
    dplyr::rename(read_sipri_sheet(sipri_path, "Share of GDP"),
                  sipri_milburden = "value"),
    by = c("country", "year")
  )
  saveRDS(sipri, out("sipri_milex_v1.2.rds"), compress = "xz")

  # Stata files: stored as .rds.
  dta_to_rds(src("MEC.dta"), out("MEC.rds"))
  dta_to_rds(src("NMC-70-abridged.dta"), out("NMC-70-abridged.rds"))

  # Mass Mobilization: drop the columns conflict_data("mm") never reads.
  env <- new.env(parent = emptyenv())
  obj <- load(src("mmALL_073120.RData"), envir = env)
  stopifnot(length(obj) == 1L)
  # `protest` is kept: 0 marks a country-year coded as having no protest.
  # `startday` and `startmonth` are kept for country-month and country-day
  # panels.
  mm_drop <- c("id", "country", "location", "sources", "notes",
               "startyear", "endday", "endmonth", "endyear",
               "protestnumber", "region", "participants_category")
  env[[obj]] <- env[[obj]][, setdiff(names(env[[obj]]), mm_drop)]
  save(list = obj, envir = env, file = out("mmALL_073120.RData"),
       compress = "xz")

  # SCAD: the columns conflict_data("scad") reads. The Africa file spells
  # the LGBTQ column "lgtbq_issue"; the loader renames it.
  scad_keep <- c("eventid", "ccode", "styr", "stmo", "stday", "etype",
                 "escalation", "npart",
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

  # RAQED: the "Event table" sheet of the source workbook, all columns,
  # stored as text CSV with dates written as YYYY-MM-DD.
  raqed <- readxl::read_xlsx(src("RAQED V1.4.xlsx"), sheet = "Event table")
  raqed$start_date <- as.Date(raqed$start_date)
  raqed$end_date <- as.Date(raqed$end_date)
  con <- xzfile(out("raqed_v1.4.csv.xz"), "wb", compression = 9)
  readr::write_csv(raqed, con, na = "")
  close(con)

  # OMG: the campaign-phase file (omg.rds), without the free-text coder
  # notes, source lists, and coder names, which the package does not read.
  omg <- readRDS(src("omg.rds"))
  omg_drop <- c("notes", "sources", "coder", "coding_note",
                "demand_change_note", "demand_demand_note",
                "socialgroup_change_note", "socialgroup_check")
  stopifnot(all(omg_drop %in% names(omg)))
  saveRDS(omg[, setdiff(names(omg), omg_drop)], out("omg.rds"),
          compress = "xz")

  # ARC 2.0: the events file, without the country name and abbreviation
  # columns (ccode identifies the country).
  arc <- readRDS(src("ARC_2_0_Events.rds"))
  arc_keep <- c("ccode", "eventid", "data_source", "event_startdate",
                "event_enddate", "org_id", "maximalist", "nonviolent_scad")
  stopifnot(all(arc_keep %in% names(arc)))
  saveRDS(arc[, arc_keep], out("ARC_2_0_Events.rds"), compress = "xz")

  # NAVCO 3.0: the event-level workbook (about 20 MB), reduced to the
  # columns conflict_data("navco3.0") reads; the event descriptions, source
  # titles, actor names, and coder notes are dropped. Count fields
  # (fatalities, injuries, participants) stay as the original text.
  navco3 <- readxl::read_xlsx(src("navco3-0full.xlsx"), guess_max = 200000)
  navco3_keep <- c("cowcode", "date", "actor_id", "camp_goals",
                   "tactical_choice", "st_posture", "fatal_casu", "injuries",
                   "num_partic_event")
  stopifnot(all(navco3_keep %in% names(navco3)))
  navco3 <- as.data.frame(navco3[, navco3_keep])
  navco3$date <- as.Date(navco3$date)
  saveRDS(navco3, out("navco3.0_events.rds"), compress = "xz")

  # UN World Population Prospects 2024: total population (thousands),
  # 1949-2023, for countries and areas (location_type 4) only. Mapping to
  # COW and GW states, including historical states, is done in
  # load_population_data().
  utils::data("pop1dt", "UNlocations", package = "wpp2024", envir = environment())
  countries <- UNlocations[UNlocations$location_type == 4,
                           c("country_code", "name")]
  wpp <- as.data.frame(pop1dt)[, c("country_code", "name", "year", "pop")]
  wpp <- wpp[wpp$country_code %in% countries$country_code, ]
  wpp$country_code <- as.integer(wpp$country_code)
  wpp$year <- as.integer(wpp$year)
  wpp <- wpp[order(wpp$country_code, wpp$year), ]
  rownames(wpp) <- NULL
  saveRDS(wpp, out("wpp2024_pop.rds"), compress = "xz")

  invisible(out_dir)
}

prepare_extdata()
