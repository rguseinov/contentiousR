#' Load conflict and mobilisation data
#'
#' @description
#' Loads one of ten conflict, protest, or revolutionary episode datasets
#' bundled with the package. `scad`, `ucdp_prio`, `ucdp_vpp`, `mm`, and `mmad`
#' are returned at the country-year level; their event- or conflict-level
#' source rows are aggregated inside this function.
#'
#' `navco1.3`, `beissinger`, `csra`, and `mec` return campaign or episode
#' records; `navco2.1` returns campaign-year rows. These sources can contain
#' multiple rows for one country-year. Use `add_conflict(aggregate = TRUE)`
#' (the default) to collapse them to country-year.
#'
#' @param start_year First year to include.
#' @param end_year Last year to include.
#' @param dataset Dataset to load. One of:
#'   \describe{
#'     \item{`"navco1.3"`}{NAVCO 1.3 campaign onsets. Coverage: 1900-2019.}
#'     \item{`"navco2.1"`}{NAVCO 2.1 campaign-years. Coverage: 1945-2013.}
#'     \item{`"beissinger"`}{Beissinger revolutionary episode onsets. Coverage: 1900-2014.}
#'     \item{`"csra"`}{HSE CSRA revolutionary episodes. Coverage: 2000-2024.}
#'     \item{`"scad"`}{SCAD 2018 social conflict events, Africa and Latin America.
#'       Recorded event starts: 1989-2017 (the 1989 event continues into the
#'       source's 1990 coverage period). Prefix: `scad_`.}
#'     \item{`"ucdp_prio"`}{UCDP/PRIO Armed Conflict Dataset v26.1.
#'       Coverage: 1946-2025. Prefix: `ucdp_prio_`.}
#'     \item{`"ucdp_vpp"`}{UCDP Violent Political Protest Dataset v26.1.
#'       Coverage: 1989-2025. Prefix: `ucdp_vpp_`. Requires the `readxl` package.}
#'     \item{`"mm"`}{Mass Mobilization Project v4 (Clark and Regan).
#'       Coverage: 1990-2020. Prefix: `mm_`.}
#'     \item{`"mmad"`}{Mass Mobilization in Autocracies Database.
#'       Coverage: 2003-2022. Prefix: `mmad_`.}
#'     \item{`"mec"`}{Major Episodes of Contention. Global coverage:
#'       1955-2018. Episode records; prefix: `mec_`. Requires the `haven`
#'       package.}
#'   }
#' @param coding_system Country coding system: `"cow"` or `"gw"`.
#'   `ucdp_prio` and `ucdp_vpp` use GW codes natively; when
#'   `coding_system = "cow"` they are converted via `countrycode` and
#'   countries without a COW equivalent are dropped.
#'
#' @return A data frame. `navco1.3`, `beissinger`, `csra`, and `mec` contain
#'   one row per campaign or episode record; `navco2.1` contains campaign-year
#'   rows. The other datasets contain one row per country-year.
#'
#' @details
#' All outputs use the requested `cow` or `gw` key and `year`. Dataset-specific
#' columns have a stable source prefix. A missing country-year row is not
#' created by this loader; after [add_conflict()], an unmatched year is `NA`,
#' not an assumed zero.
#'
#' SCAD is deduplicated to one row per event before country-year aggregation.
#' Its UCDP placeholder rows are excluded, and documented negative codes for
#' unknown death counts are treated as missing.
#'
#' For UCDP/PRIO, `ucdp_prio_incidence` identifies any active conflict-year and
#' `ucdp_prio_onset` identifies a new episode using the source's `start_date2`.
#' The VPP source does not include an episode-start variable;
#' `ucdp_vpp_incidence` should be preferred. The legacy
#' `ucdp_vpp_onset` column is retained as an incidence alias for compatibility.
#'
#' The Mass Mobilization source mixes exact participant counts with text such
#' as ranges and inequalities. `mm_participants` is the maximum among genuinely
#' numeric values; `mm_participants_reported` preserves the source strings.
#'
#' MEC is kept at its published episode level. Its source `byear` becomes
#' `year`, `ccode` becomes `cow`, and all other source columns receive the
#' `mec_` prefix. `mec_episode` equals one for every returned episode record.
#' Fourteen left-censored records have an actual `mec_bdate` before 1955 while
#' their source `byear` is 1955. With GW coding, COW 679 (Yemen) maps to GW 678
#' and COW 817 (South Vietnam) maps to GW 817; Tonga has no GW state equivalent
#' and is omitted.
#'
#' @examples
#' navco <- conflict_data(1990, 2010, dataset = "navco2.1", coding_system = "cow")
#'
#' scad  <- conflict_data(1995, 2015, dataset = "scad",      coding_system = "cow")
#'
#' ucdp  <- conflict_data(1990, 2020, dataset = "ucdp_prio", coding_system = "gw")
#'
#' if (requireNamespace("haven", quietly = TRUE)) {
#'   mec <- conflict_data(1990, 2010, dataset = "mec", coding_system = "cow")
#' }
#'
#' @source
#' NAVCO 2.1: \doi{10.7910/DVN/MHOXDV}.
#'
#' Beissinger Revolutionary Episodes:
#' \url{https://mbeissinger.scholar.princeton.edu/revolutionary-episodes-dataset}.
#'
#' HSE Revolutions Dataset:
#' \url{https://social.hse.ru/en/mr/rev_bd}.
#'
#' SCAD: \url{https://www.strausscenter.org/ccaps-research-areas/social-conflict/database/}.
#'
#' UCDP: \url{https://ucdp.uu.se/downloads/replication_data.html}.
#'
#' MMAD: \url{https://mmadatabase.org/}.
#'
#' MEC: Chenoweth and Kang (2026), \doi{10.1093/jopres/xjaf008}; data release
#' \doi{10.7910/DVN/JQWQNW}.
#'
#' @export
conflict_data <- function(
    start_year    = 1945,
    end_year      = 2013,
    dataset       = c("navco1.3", "navco2.1", "beissinger", "csra",
                      "scad", "ucdp_prio", "ucdp_vpp", "mm", "mmad", "mec"),
    coding_system = c("cow", "gw")
) {
  check_year_range(start_year, end_year)
  dataset       <- match.arg(dataset)
  coding_system <- match.arg(coding_system)

  # ── Legacy datasets: load once, then process in per-dataset blocks ────────
  legacy_datasets <- c("navco1.3", "navco2.1", "beissinger", "csra")
  campaign_datasets <- c(legacy_datasets, "mec")

  if (dataset %in% legacy_datasets) {
    file_name <- dplyr::case_when(
      dataset == "navco1.3"   ~ "NAVCO_1.3.RData",
      dataset == "navco2.1"   ~ "NAVCO_2.1.RData",
      dataset == "beissinger" ~ "revolutionary_episodes_beissinger.csv.gz",
      dataset == "csra"       ~ "revolutionary_episodes_csra.csv.gz"
    )
    path <- system.file("extdata", file_name, package = "contentiousR")
    if (path == "") {
      stop("Could not find `", file_name, "` in package extdata.", call. = FALSE)
    }
    if (grepl("\\.RData$", file_name)) {
      data <- read_rdata_from_extdata(file_name)
    } else {
      # suppressMessages: Beissinger CSV has a duplicate "ongoing" column;
      # readr renames them to ongoing...14 / ongoing...77 and prints a message
      data <- suppressMessages(readr::read_csv(path, show_col_types = FALSE))
    }
  }

  # ═══════════════════════════════════════════════════════════════════════════
  # SCAD 2018 - Social Conflict in Africa / Latin America
  # Event-level -> aggregated to country-year inside this function
  # ═══════════════════════════════════════════════════════════════════════════
  if (dataset == "scad") {
    path_africa <- system.file(
      "extdata", "SCAD2018Africa_Final.csv.gz", package = "contentiousR"
    )
    path_latam <- system.file(
      "extdata", "SCAD2018LatinAmerica_Final.csv.gz", package = "contentiousR"
    )
    if (path_africa == "" || path_latam == "") {
      stop("Could not find SCAD CSV files in package extdata.", call. = FALSE)
    }

    africa <- readr::read_csv(path_africa, show_col_types = FALSE,
                              locale = readr::locale(encoding = "latin1"))
    latam  <- readr::read_csv(path_latam,  show_col_types = FALSE,
                              locale = readr::locale(encoding = "latin1"))

    # Africa uses typo "lgtbq_issue"; LatAm uses correct "lgbtq_issue" - harmonise
    if ("lgtbq_issue" %in% names(africa)) {
      africa <- dplyr::rename(africa, lgbtq_issue = "lgtbq_issue")
    }

    raw <- dplyr::bind_rows(africa, latam)

    # SCAD 3.x repeats events that occur in multiple locations. The codebook
    # directs country-level users to retain one row per event. Negative event
    # IDs are UCDP placeholder rows rather than SCAD events.
    keep_scad <- c(
      "eventid", "ccode", "styr", "etype", "escalation", "npart", "ndeath",
      "repress", "cgovtarget", "rgovtarget", "female_event", "lgbtq_issue"
    )

    data <- raw |>
      dplyr::select(dplyr::all_of(keep_scad)) |>
      dplyr::filter(.data$eventid > 0) |>
      dplyr::distinct(.data$eventid, .keep_all = TRUE) |>
      dplyr::mutate(
        dplyr::across(
          -dplyr::all_of(c("eventid", "ccode", "styr", "ndeath")),
          ~ suppressWarnings(as.integer(
            ifelse(. %in% c(-9L, -99L, "-9", "-99", ""), NA_integer_, as.integer(.))
          ))
        ),
        # SCAD uses these negative values for unknown death counts.
        ndeath = dplyr::if_else(
          .data$ndeath %in% c(-99, -88, -77),
          NA_real_,
          as.numeric(.data$ndeath)
        )
      ) |>
      dplyr::filter(.data$styr >= start_year & .data$styr <= end_year) |>
      dplyr::mutate(cow = as.integer(.data$ccode)) |>
      dplyr::rename(year = "styr") |>
      dplyr::group_by(.data$cow, .data$year) |>
      dplyr::summarise(
        scad_onset          = 1L,
        scad_n_events       = dplyr::n(),
        scad_ndeath_total   = safe_sum(.data$ndeath),
        scad_npart_max      = as.integer(safe_max(.data$npart)),
        scad_escalation_max = as.integer(safe_max(.data$escalation)),
        scad_repress_max    = as.integer(safe_max(.data$repress)),
        scad_cgovtarget     = as.integer(safe_max(.data$cgovtarget)),
        scad_rgovtarget     = as.integer(safe_max(.data$rgovtarget)),
        scad_female_event   = as.integer(safe_max(.data$female_event)),
        scad_lgbtq_issue    = as.integer(safe_max(.data$lgbtq_issue)),
        .groups = "drop"
      )

    if (coding_system == "gw") {
      data <- data |>
        dplyr::mutate(gw = suppressWarnings(
          countrycode::countrycode(.data$cow, "cown", "gwn")
        )) |>
        tidyr::drop_na("gw") |>
        dplyr::select(-"cow") |>
        dplyr::select("gw", "year", dplyr::everything())
    } else {
      data <- dplyr::select(data, "cow", "year", dplyr::everything())
    }
  }

  # ═══════════════════════════════════════════════════════════════════════════
  # UCDP/PRIO Armed Conflict Dataset v26.1
  # Conflict-year; gwno_loc can be comma-separated for multi-country conflicts
  # -> expanded and aggregated to country-year
  # ═══════════════════════════════════════════════════════════════════════════
  if (dataset == "ucdp_prio") {
    path <- system.file(
      "extdata", "UcdpPrioConflict_v26_1.csv.gz", package = "contentiousR"
    )
    if (path == "") {
      stop(
        "Could not find `UcdpPrioConflict_v26_1.csv.gz` in package extdata.",
        call. = FALSE
      )
    }

    raw <- readr::read_csv(
      path,
      col_types = readr::cols(
        .default = readr::col_guess(),
        gwno_a = readr::col_character(),
        gwno_a_2nd = readr::col_character(),
        gwno_b = readr::col_character(),
        gwno_b_2nd = readr::col_character(),
        gwno_loc = readr::col_character()
      ),
      show_col_types = FALSE
    )

    # Drop: free-text party/location names, date strings, version string
    # region excluded: source has comma-separated values like "1, 3" for multi-region
    # conflicts; as.integer() would introduce NA. Region is not analytically useful
    # at country-year level after gwno_loc expansion.
    keep_ucdp <- c(
      "conflict_id", "gwno_loc", "year", "incompatibility",
      "intensity_level", "cumulative_intensity", "type_of_conflict",
      "start_date2", "ep_end"
    )

    data <- raw |>
      dplyr::select(dplyr::all_of(keep_ucdp)) |>
      dplyr::filter(.data$year >= start_year & .data$year <= end_year) |>
      # Expand comma-separated GW codes (159 multi-country conflicts in v26.1)
      dplyr::mutate(gwno_loc = strsplit(.data$gwno_loc, ",\\s*")) |>
      tidyr::unnest("gwno_loc") |>
      dplyr::mutate(
        gwno_loc             = as.integer(trimws(.data$gwno_loc)),
        incompatibility      = as.integer(.data$incompatibility),
        intensity_level      = as.integer(.data$intensity_level),
        cumulative_intensity = as.integer(.data$cumulative_intensity),
        type_of_conflict     = as.integer(.data$type_of_conflict),
        episode_onset        = as.integer(
          substr(as.character(.data$start_date2), 1L, 4L) ==
            as.character(.data$year)
        ),
        ep_end               = as.integer(.data$ep_end)
      ) |>
      dplyr::group_by(.data$gwno_loc, .data$year) |>
      dplyr::summarise(
        ucdp_prio_incidence            = 1L,
        ucdp_prio_onset                = as.integer(
          any(.data$episode_onset == 1L, na.rm = TRUE)
        ),
        ucdp_prio_n_conflicts          = dplyr::n_distinct(.data$conflict_id),
        ucdp_prio_intensity_max        = as.integer(safe_max(.data$intensity_level)),
        ucdp_prio_war                  = as.integer(safe_max(.data$intensity_level) == 2),
        ucdp_prio_cumulative_intensity = as.integer(safe_max(.data$cumulative_intensity)),
        ucdp_prio_type_max             = as.integer(safe_max(.data$type_of_conflict)),
        ucdp_prio_intrastate           = as.integer(
          any(.data$type_of_conflict %in% c(3L, 4L), na.rm = TRUE)
        ),
        ucdp_prio_interstate           = as.integer(
          any(.data$type_of_conflict == 2L, na.rm = TRUE)
        ),
        ucdp_prio_incompatibility_max  = as.integer(safe_max(.data$incompatibility)),
        ucdp_prio_ep_end               = as.integer(safe_max(.data$ep_end)),
        .groups = "drop"
      )

    if (coding_system == "cow") {
      data <- data |>
        dplyr::mutate(
          cow = suppressWarnings(
            as.integer(countrycode::countrycode(.data$gwno_loc, "gwn", "cown"))
          )
        ) |>
        tidyr::drop_na("cow") |>
        dplyr::select(-"gwno_loc") |>
        dplyr::select("cow", "year", dplyr::everything())
    } else {
      data <- data |>
        dplyr::rename(gw = "gwno_loc") |>
        dplyr::select("gw", "year", dplyr::everything())
    }
  }

  # ═══════════════════════════════════════════════════════════════════════════
  # UCDP Violent Political Protest Dataset v26.1
  # Dyad-year -> aggregated to country-year
  # NOTE: "Terrority" is a spelling error in the source data (should be "Territory")
  # Requires: readxl
  # ═══════════════════════════════════════════════════════════════════════════
  if (dataset == "ucdp_vpp") {
    if (!requireNamespace("readxl", quietly = TRUE)) {
      stop(
        "Package 'readxl' is required to load UCDP VPP data. ",
        "Install it with: install.packages('readxl')",
        call. = FALSE
      )
    }
    path <- system.file("extdata", "UCDP_VPP_Dataset_v26_1.xlsx", package = "contentiousR")
    if (path == "") {
      stop("Could not find `UCDP_VPP_Dataset_v26_1.xlsx` in package extdata.", call. = FALSE)
    }

    raw <- readxl::read_xlsx(path)

    # Drop: dyad/side/location/region text, outcome text, version string
    data <- raw |>
      dplyr::select(
        gwno_loc        = "GWNOLoc",
        year            = "Year",
        region_id       = "Region ID",
        incompatibility = "Incompatibility",
        intensity       = "Intensity"
      ) |>
      dplyr::mutate(
        gwno_loc  = as.integer(.data$gwno_loc),
        year      = as.integer(.data$year),
        region_id = as.integer(.data$region_id),
        intensity = as.integer(.data$intensity),
        # Convert text incompatibility to numeric (typo "Terrority" preserved as-is from source)
        incompatibility_num = dplyr::case_when(
          .data$incompatibility == "Government" ~ 1L,
          .data$incompatibility == "Terrority"  ~ 2L,
          TRUE                                  ~ NA_integer_
        )
      ) |>
      dplyr::filter(.data$year >= start_year & .data$year <= end_year) |>
      dplyr::group_by(.data$gwno_loc, .data$year) |>
      dplyr::summarise(
        ucdp_vpp_incidence          = 1L,
        # Kept for compatibility with contentiousR 0.0.2. The source has no
        # episode-start field, so this legacy column denotes incidence too.
        ucdp_vpp_onset              = 1L,
        ucdp_vpp_n_dyads            = dplyr::n(),
        ucdp_vpp_intensity_max      = as.integer(safe_max(.data$intensity)),
        ucdp_vpp_region_id          = as.integer(safe_max(.data$region_id)),
        ucdp_vpp_gov_conflict       = as.integer(
          any(.data$incompatibility_num == 1L, na.rm = TRUE)
        ),
        ucdp_vpp_territory_conflict = as.integer(
          any(.data$incompatibility_num == 2L, na.rm = TRUE)
        ),
        .groups = "drop"
      )

    if (coding_system == "cow") {
      data <- data |>
        dplyr::mutate(
          cow = suppressWarnings(
            as.integer(countrycode::countrycode(.data$gwno_loc, "gwn", "cown"))
          )
        ) |>
        tidyr::drop_na("cow") |>
        dplyr::select(-"gwno_loc") |>
        dplyr::select("cow", "year", dplyr::everything())
    } else {
      data <- data |>
        dplyr::rename(gw = "gwno_loc") |>
        dplyr::select("gw", "year", dplyr::everything())
    }
  }

  # ═══════════════════════════════════════════════════════════════════════════
  # Mass Mobilization Project v4 (Clark & Regan 2016)
  # Event-level -> aggregated to country-year
  # Column list decoded from binary RData:
  #   id, country, ccode, year, region, protest, protestnumber,
  #   startday/month/year, endday/month/year, protesterviolence, location,
  #   participants_category, participants, protesteridentity,
  #   protesterdemand1-4, stateresponse1-7, sources, notes
  # ═══════════════════════════════════════════════════════════════════════════
  if (dataset == "mm") {
    raw <- read_rdata_from_extdata("mmALL_073120.RData")

    # Drop: free-text identifiers, date detail, and redundant/uninformative columns
    drop_mm <- c("id", "country", "location", "sources", "notes",
                 "startday", "startmonth", "startyear",
                 "endday",   "endmonth",   "endyear",
                 "protest",               # always 1; redundant with mm_onset
                 "protestnumber",         # sequential event ID; max == mm_n_protests
                 "region",               # text label ("Africa" / "Latin America")
                 "participants_category") # text size category; use mm_participants instead

    # Numeric columns: aggregate with max() across events in country-year
    num_mm <- c("protesterviolence", "participants")

    # Text-coded categorical columns: collapse unique non-NA values with "; "
    # (these are stored as character/factor with text labels in the RData, NOT integer codes)
    text_mm <- c("participants_reported", "protesteridentity",
                 "protesterdemand1", "protesterdemand2", "protesterdemand3", "protesterdemand4",
                 "stateresponse1", "stateresponse2", "stateresponse3",
                 "stateresponse4", "stateresponse5", "stateresponse6", "stateresponse7")

    data <- raw |>
      dplyr::select(-dplyr::any_of(drop_mm)) |>
      # Factors -> character first to preserve text labels (old-style R factor storage)
      dplyr::mutate(dplyr::across(dplyr::where(is.factor), as.character)) |>
      # Coerce only the genuinely numeric columns
      dplyr::mutate(
        ccode             = suppressWarnings(as.integer(.data$ccode)),
        year              = suppressWarnings(as.integer(.data$year)),
        protesterviolence = suppressWarnings(as.integer(.data$protesterviolence)),
        participants_reported = as.character(.data$participants),
        participants      = suppressWarnings(
          as.numeric(.data$participants_reported)
        )
      ) |>
      dplyr::filter(.data$year >= start_year & .data$year <= end_year) |>
      dplyr::mutate(cow = .data$ccode) |>
      dplyr::group_by(.data$cow, .data$year) |>
      dplyr::summarise(
        mm_onset      = 1L,
        mm_n_protests = dplyr::n(),
        dplyr::across(
          dplyr::all_of(num_mm),
          safe_max,
          .names = "mm_{.col}"
        ),
        dplyr::across(
          dplyr::all_of(text_mm),
          ~ {
            values <- sort(unique(stats::na.omit(.)))
            if (length(values) == 0L) {
              NA_character_
            } else {
              paste(values, collapse = "; ")
            }
          },
          .names = "mm_{.col}"
        ),
        .groups = "drop"
      )

    if (coding_system == "gw") {
      data <- data |>
        dplyr::mutate(gw = suppressWarnings(
          countrycode::countrycode(.data$cow, "cown", "gwn")
        )) |>
        tidyr::drop_na("gw") |>
        dplyr::select(-"cow") |>
        dplyr::select("gw", "year", dplyr::everything())
    } else {
      data <- dplyr::select(data, "cow", "year", dplyr::everything())
    }
  }

  # ═══════════════════════════════════════════════════════════════════════════
  # Mass Mobilization in Autocracies Database (MMAD)
  # Event-level -> aggregated to country-year
  # side: 0 = pro-government, 1 = anti-government, 3 = other/unknown
  # ═══════════════════════════════════════════════════════════════════════════
  if (dataset == "mmad") {
    path <- system.file("extdata", "mmad_events.csv.gz", package = "contentiousR")
    if (path == "") {
      stop("Could not find `mmad_events.csv.gz` in package extdata.", call. = FALSE)
    }

    raw <- readr::read_csv(path, show_col_types = FALSE)

    # Drop: geographic detail (GeoNames location ID, place name, coordinates)
    data <- raw |>
      dplyr::select(dplyr::all_of(c(
        "cowcode", "event_date", "side", "numreports", "max_scope",
        "max_partviolence", "max_secengagement", "mean_avg_numparticipants"
      ))) |>
      dplyr::mutate(
        year = as.integer(substr(.data$event_date, 1L, 4L)),
        cow  = as.integer(.data$cowcode),
        side = as.integer(.data$side),
        # Source data stores missing values as the string "NA"
        numreports               = suppressWarnings(as.numeric(.data$numreports)),
        max_scope                = suppressWarnings(as.numeric(.data$max_scope)),
        max_partviolence         = suppressWarnings(as.numeric(.data$max_partviolence)),
        max_secengagement        = suppressWarnings(as.numeric(.data$max_secengagement)),
        mean_avg_numparticipants = suppressWarnings(as.numeric(.data$mean_avg_numparticipants))
      ) |>
      dplyr::filter(.data$year >= start_year & .data$year <= end_year) |>
      dplyr::group_by(.data$cow, .data$year) |>
      dplyr::summarise(
        mmad_onset             = 1L,
        mmad_n_events          = dplyr::n(),
        mmad_n_anti_gov        = sum(.data$side == 1L, na.rm = TRUE),
        mmad_numreports_total  = safe_sum(.data$numreports),
        mmad_max_scope         = as.integer(safe_max(.data$max_scope)),
        mmad_max_partviolence  = as.integer(safe_max(.data$max_partviolence)),
        mmad_max_secengagement = as.integer(safe_max(.data$max_secengagement)),
        mmad_mean_participants = safe_mean(.data$mean_avg_numparticipants),
        .groups = "drop"
      )

    if (coding_system == "gw") {
      data <- data |>
        dplyr::mutate(gw = suppressWarnings(
          countrycode::countrycode(.data$cow, "cown", "gwn")
        )) |>
        tidyr::drop_na("gw") |>
        dplyr::select(-"cow") |>
        dplyr::select("gw", "year", dplyr::everything())
    } else {
      data <- dplyr::select(data, "cow", "year", dplyr::everything())
    }
  }

  # ════════════════════════════════════════════════════════════════════════════
  # Major Episodes of Contention (MEC)
  # Published episode-level data; multiple episodes may share a country-year
  # ═════════════════════════════════════════════════════════════════════════════
  if (dataset == "mec") {
    if (!requireNamespace("haven", quietly = TRUE)) {
      stop(
        "Package 'haven' is required to load MEC data. ",
        "Install it with: install.packages('haven')",
        call. = FALSE
      )
    }

    path <- system.file("extdata", "MEC.dta", package = "contentiousR")
    if (path == "") {
      stop("Could not find `MEC.dta` in package extdata.", call. = FALSE)
    }

    data <- haven::read_dta(path) |>
      dplyr::mutate(
        cow = as.integer(.data$ccode),
        year = as.integer(.data$byear)
      ) |>
      dplyr::select(
        "cow", "year", dplyr::everything(),
        -dplyr::all_of(c("ccode", "byear"))
      ) |>
      dplyr::rename_with(
        ~ paste0("mec_", .),
        .cols = -dplyr::all_of(c("cow", "year"))
      ) |>
      dplyr::mutate(mec_episode = 1L, .after = "year")

    if (coding_system == "gw") {
      data <- data |>
        dplyr::mutate(
          gw = suppressWarnings(
            countrycode::countrycode(.data$cow, "cown", "gwn")
          ),
          # Historical codes not converted by countrycode 1.6.1.
          gw = dplyr::case_when(
            .data$cow == 679L ~ 678L, # Republic of Yemen
            .data$cow == 817L ~ 817L, # Republic of Vietnam
            TRUE ~ as.integer(.data$gw)
          )
        ) |>
        tidyr::drop_na("gw") |>
        dplyr::select(-"cow") |>
        dplyr::select("gw", "year", dplyr::everything())
    } else {
      data <- dplyr::select(data, "cow", "year", dplyr::everything())
    }
  }

  # ═══════════════════════════════════════════════════════════════════════════
  # Legacy datasets
  # ═══════════════════════════════════════════════════════════════════════════
  if (dataset == "navco1.3") {
    if (coding_system == "cow") {
      data <- data |>
        dplyr::rename_with(~ paste0("nvc1.3_", .), .cols = 7:ncol(data)) |>
        dplyr::rename_with(~ paste0("nvc1.3_", .), .cols = "CAMPAIGN") |>
        dplyr::mutate(
          nvc1.3_ONSET = 1L,
          cow = suppressWarnings(countrycode::countrycode(.data$LOCATION, "country.name", "cown")),
          cow = ifelse(.data$LOCATION == "Serbia", 345L, .data$cow)
        ) |>
        dplyr::rename(year = "BYEAR") |>
        dplyr::select("cow", "year", dplyr::starts_with("nvc1.3_"))
    }
    if (coding_system == "gw") {
      data <- data |>
        dplyr::rename_with(~ paste0("nvc1.3_", .), .cols = 7:ncol(data)) |>
        dplyr::rename_with(~ paste0("nvc1.3_", .), .cols = "CAMPAIGN") |>
        dplyr::mutate(
          nvc1.3_ONSET = 1L,
          gw = suppressWarnings(countrycode::countrycode(.data$LOCATION, "country.name", "gwn")),
          gw = ifelse(.data$LOCATION == "Serbia", 340L, .data$gw)
        ) |>
        dplyr::rename(year = "BYEAR") |>
        dplyr::select("gw", "year", dplyr::starts_with("nvc1.3_"))
    }
  }

  if (dataset == "navco2.1") {
    if (coding_system == "cow") {
      data <- data |>
        dplyr::rename_with(~ paste0("nvc2.1_", .), .cols = 18:ncol(data)) |>
        dplyr::rename_with(~ paste0("nvc2.1_", .), .cols = "camp_name") |>
        dplyr::group_by(.data$id) |>
        dplyr::mutate(
          nvc2.1_ONSET = dplyr::if_else(
            .data$year == min(.data$year, na.rm = TRUE), 1L, 0L
          )
        ) |>
        dplyr::ungroup() |>
        dplyr::rename(cow = "loc_cow") |>
        dplyr::mutate(cow = ifelse(.data$location == "Serbia", 345L, .data$cow)) |>
        dplyr::select("cow", "year", dplyr::starts_with("nvc2.1_"))
    }
    if (coding_system == "gw") {
      data <- data |>
        dplyr::rename_with(~ paste0("nvc2.1_", .), .cols = 18:ncol(data)) |>
        dplyr::rename_with(~ paste0("nvc2.1_", .), .cols = "camp_name") |>
        dplyr::group_by(.data$id) |>
        dplyr::mutate(
          nvc2.1_ONSET = dplyr::if_else(
            .data$year == min(.data$year, na.rm = TRUE), 1L, 0L
          )
        ) |>
        dplyr::ungroup() |>
        dplyr::mutate(gw = suppressWarnings(
          countrycode::countrycode(.data$loc_cow, "cown", "gwn")
        )) |>
        dplyr::mutate(gw = ifelse(.data$location == "Serbia", 340L, .data$gw)) |>
        dplyr::select("gw", "year", dplyr::starts_with("nvc2.1_"))
    }
  }

  if (dataset == "beissinger") {
    if (coding_system == "cow") {
      data <- data |>
        dplyr::mutate(
          cow = suppressWarnings(countrycode::countrycode(.data$cowcode, "cown", "cown")),
          cow = ifelse(.data$location == "Serbia", 345L, .data$cow)
        ) |>
        dplyr::rename(
          year = "startyear",
          beissinger_endyear = "endyear"
        ) |>
        dplyr::rename_with(~ paste0("beissinger_", .), .cols = 11:ncol(data)) |>
        dplyr::rename_with(~ paste0("beissinger_", .), .cols = "nameofrevolution") |>
        dplyr::mutate(beissinger_onset = 1L) |>
        dplyr::select("cow", "year", dplyr::starts_with("beissinger_"))
    }
    if (coding_system == "gw") {
      data <- data |>
        dplyr::mutate(
          gw = suppressWarnings(countrycode::countrycode(.data$cowcode, "cown", "gwn")),
          gw = ifelse(.data$location == "Serbia", 340L, .data$gw)
        ) |>
        dplyr::rename(
          year = "startyear",
          beissinger_endyear = "endyear"
        ) |>
        dplyr::rename_with(~ paste0("beissinger_", .), .cols = 11:ncol(data)) |>
        dplyr::rename_with(~ paste0("beissinger_", .), .cols = "nameofrevolution") |>
        dplyr::mutate(beissinger_onset = 1L) |>
        dplyr::select("gw", "year", dplyr::starts_with("beissinger_"))
    }
  }

  if (dataset == "csra") {
    if (coding_system == "cow") {
      data <- data |>
        dplyr::rename(onset = "all") |>
        dplyr::rename_with(~ paste0("csra_", .), .cols = 10:ncol(data)) |>
        dplyr::rename_with(~ paste0("csra_", .), .cols = "name") |>
        dplyr::mutate(cow = suppressWarnings(
          countrycode::countrycode(.data$country, "country.name", "cown")
        )) |>
        dplyr::mutate(cow = ifelse(.data$country == "Serbia", 345L, .data$cow)) |>
        dplyr::rename(year = "start_year") |>
        dplyr::select("cow", "year", "end_year", dplyr::starts_with("csra_"))
    }
    if (coding_system == "gw") {
      data <- data |>
        dplyr::rename(onset = "all") |>
        dplyr::rename_with(~ paste0("csra_", .), .cols = 10:ncol(data)) |>
        dplyr::rename_with(~ paste0("csra_", .), .cols = "name") |>
        dplyr::mutate(gw = suppressWarnings(
          countrycode::countrycode(.data$country, "country.name", "gwn")
        )) |>
        dplyr::mutate(gw = ifelse(.data$country == "Serbia", 340L, .data$gw)) |>
        dplyr::rename(year = "start_year") |>
        dplyr::select("gw", "year", "end_year", dplyr::starts_with("csra_"))
    }
  }

  data <- data |>
    dplyr::filter(
      .data$year >= .env$start_year & .data$year <= .env$end_year
    ) |>
    tidyr::drop_na(dplyr::all_of(c(coding_system, "year"))) |>
    dplyr::arrange(.data[[coding_system]], .data$year)

  if (!dataset %in% campaign_datasets) {
    check_unique_key(data, c(coding_system, "year"))
  }

  return(data)
}
