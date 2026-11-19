#' Load conflict and mobilization data
#'
#' @description
#' Loads one of thirteen conflict, protest, or revolutionary episode datasets
#' bundled with the package. `scad`, `ucdp_prio`, `ucdp_vpp`, `mm`, `mmad`,
#' `arc`, and `navco3.0` are returned at the country-year level; their event- or conflict-level
#' source rows are aggregated inside this function.
#'
#' `navco1.3`, `beissinger`, `raqed`, and `mec` return campaign or episode
#' records, and `omg` returns campaign-phase records; `navco2.1` returns campaign-year rows. These sources can contain
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
#'     \item{`"raqed"`}{Revolutionary and Quasi-revolutionary Episodes
#'       Dataset (RAQED) v1.4, HSE University. Episode records. Coverage:
#'       2000-2026. Prefix: `raqed_`.}
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
#'       1955-2018. Episode records; prefix: `mec_`.}
#'     \item{`"omg"`}{Opposition Movements and Groups (OMG) v1.
#'       Campaign-phase records. Coverage: 1789-2019, for the countries
#'       coded so far. Prefix: `omg_`.}
#'     \item{`"arc"`}{Anatomy of Resistance Campaigns (ARC) 2.0: protest
#'       and armed-conflict events from SCAD and UCDP GED with the formal
#'       organizations that took part, Africa, Latin America and the
#'       Caribbean. Coverage: 1990-2018. Prefix: `arc_`.}
#'     \item{`"navco3.0"`}{NAVCO 3.0 events on 26 countries (1990-2012):
#'       actions by anti-government campaigns, states, and others, with
#'       tactics, goals, and state responses. Prefix: `nvc3.0_`.}
#'   }
#' @param unit Time unit of the returned data: `"year"` (default),
#'   `"quarter"`, `"month"`, or `"day"`. Event datasets are aggregated to this
#'   unit, and campaign and episode records are placed in the period of their
#'   start date. Records whose source date is less precise than `unit` (a
#'   quarter needs a month-precise date) are dropped with a message.
#'   `"navco1.3"`, `"navco2.1"`, `"ucdp_prio"`, and `"ucdp_vpp"` support
#'   `"year"` only.
#' @param coding_system Country coding system: `"cow"` or `"gw"`.
#'   `ucdp_prio` and `ucdp_vpp` use GW codes natively; when
#'   `coding_system = "cow"` they are converted via `countrycode` and
#'   countries without a COW equivalent are dropped.
#'
#' @return A data frame. `navco1.3`, `beissinger`, `raqed`, and
#'   `mec` contain one row per campaign or episode record; `omg` contains one
#'   row per campaign phase; `navco2.1` contains campaign-year rows. The other datasets contain one row per country-year.
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
#' **Country codes.** COW codes follow the package's COW panels: the German
#' Federal Republic is 255 and Czechoslovakia 316 (see
#' [build_states_panel()]), and Yemen is 678 up to 1990 and 679 from 1991.
#' GW codes are derived from COW by year: Germany is GW 255 up to 1945 and
#' 260 after; Serbia is GW 340 up to 1915 and from June 2006, and 345
#' (Yugoslavia) in between; Czechoslovakia is GW 315 and the Czech Republic
#' 316; Yemen is GW 678; Vietnam is 816 in both systems. The Mass
#' Mobilization data's non-COW codes (for example 341 for Kosovo and 525 for
#' South Sudan) are mapped to COW first.
#'
#' MEC is kept at its published episode level. Its source `byear` becomes
#' `year`, `ccode` becomes `cow`, and all other source columns receive the
#' `mec_` prefix. `mec_episode` equals one for every returned episode record.
#' Fourteen left-censored records have an actual `mec_bdate` before 1955 while
#' their source `byear` is 1955.
#'
#' RAQED is kept at its published episode level. `year` is the episode's
#' `start_year`; all other source columns receive the `raqed_` prefix.
#' `raqed_onset` equals one for every episode, and `raqed_type_re`,
#' `raqed_type_re_q`, and `raqed_type_qre` are dummies for the source `type`
#' (revolutionary episode, questionable revolutionary episode, and
#' quasi-revolutionary episode). Abkhazia, Hong Kong, Palestine, Puerto
#' Rico, and Western Sahara have no COW code and are omitted.
#'
#' OMG is kept at its published campaign-phase level. `year` is the phase's
#' `start_year`. `omg_phase_onset` equals one for every phase and `omg_onset`
#' equals one only for the first phase of a campaign (`omg_campaign_id`), so
#' later phases of an ongoing campaign are not counted as new onsets. The
#' source identifies countries by V-Dem `country_id`; these are converted
#' with `countrycode`. Serbia is mapped to COW 345 / GW 340, Yemen to COW 678
#' before 1990 and 679 from 1990 (GW 678), and Piedmont-Sardinia to 325.
#' Hong Kong, Palestine, and Western Sahara are omitted. OMG covers only the
#' countries coded so far, so a missing country-year is not evidence that no
#' campaign occurred.
#'
#' NAVCO 3.0 records individual actions by anti-government campaigns
#' (`actor_id` 2), states (1), and international, non-aligned, and local state
#' actors. `nvc3.0_onset` is one when at least one campaign action occurred
#' in the period and zero when only actions by other actors did.
#' `nvc3.0_n_nonviolent`, `nvc3.0_n_violent`, and `nvc3.0_n_mixed` count
#' campaign actions by `tactical_choice`; `nvc3.0_n_regime_change` counts
#' campaign actions with regime-change goals; `nvc3.0_n_concessions`
#' (`st_posture` 1-3), `nvc3.0_n_repression` (5-7), and
#' `nvc3.0_n_lethal_repression` (7) count state responses. The source records
#' fatalities, injuries, and participants as numbers or ranges ("100-300");
#' the `_low` and `_high` columns sum (fatalities, injuries) or take the
#' maximum (participants in campaign actions) of the range bounds.
#'
#' Mass Mobilization codes country-years in which no protest occurred as a
#' row with `protest = 0`; these give `mm_onset = 0` and `mm_n_protests = 0`.
#' They have no date, so they are absent from country-month and country-day
#' data.
#'
#' ARC 2.0 lists one row per event, with the participating ARC organization
#' IDs in a comma-separated `org_id` (missing when no formal organization was
#' identified). Events are assigned to the year in which they start and
#' aggregated to country-year: `arc_n_events` (split into
#' `arc_n_events_scad` and `arc_n_events_ged`), `arc_n_maximalist` and
#' `arc_n_nonmaximalist` (by the source's `maximalist` flag; every GED event
#' is maximalist), `arc_n_nonviolent_scad`, `arc_n_events_org` and
#' `arc_share_events_org` (events with at least one identified organization),
#' and `arc_n_orgs` (distinct organizations active in that country-year).
#'
#' @examples
#' navco <- conflict_data(1990, 2010, dataset = "navco2.1", coding_system = "cow")
#'
#' scad  <- conflict_data(1995, 2015, dataset = "scad",      coding_system = "cow")
#'
#' ucdp  <- conflict_data(1990, 2020, dataset = "ucdp_prio", coding_system = "gw")
#'
#' mec   <- conflict_data(1990, 2010, dataset = "mec",       coding_system = "cow")
#'
#' raqed <- conflict_data(2000, 2025, dataset = "raqed",     coding_system = "cow")
#'
#' omg   <- conflict_data(1900, 2019, dataset = "omg",       coding_system = "gw")
#'
#' arc   <- conflict_data(1990, 2018, dataset = "arc",       coding_system = "cow")
#'
#' navco3 <- conflict_data(2011, 2012, dataset = "navco3.0", coding_system = "cow",
#'                         unit = "month")
#'
#' @source
#' NAVCO 2.1: \doi{10.7910/DVN/MHOXDV}.
#'
#' Beissinger Revolutionary Episodes:
#' \url{https://web.archive.org/web/20250331220952/https://mbeissinger.scholar.princeton.edu/revolutionary-episodes-dataset}.
#'
#' RAQED: \url{https://social.hse.ru/mr/rev_bd}.
#'
#' OMG: \url{https://www.prio.org/data/39}.
#'
#' ARC 2.0: \doi{10.7910/DVN/C0PUHP}.
#'
#' NAVCO 3.0: \doi{10.7910/DVN/INNYEO}.
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
#' @references
#' Chenoweth, E., & Shay, C. W. (2020). *List of Campaigns in NAVCO 1.3*.
#' Harvard Dataverse. \doi{10.7910/DVN/ON9XND}
#'
#' Chenoweth, E., & Shay, C. W. (2019). *NAVCO 2.1 Dataset*. Harvard
#' Dataverse. \doi{10.7910/DVN/MHOXDV}
#'
#' Beissinger, M. (2022). *Revolutionary Episodes Dataset*.
#'
#' Ustyuzhanin, V., Semichev, D., Grinin, L., & Korotaev, A. (2026). New
#' possibilities for analysing revolution: Introducing a database of
#' revolutions of the 21st century. *Russian Sociological Review*, 25(1), 9-61.
#' \doi{10.17323/1728-192X-2026-1-9-61}
#'
#' Ustyuzhanin, V., Semichev, D., Grinin, L., & Korotaev, A. (2026).
#' *Revolutionary and Quasi-revolutionary Episodes Dataset (RAQED)
#' (2000-2025)*, Version 1.4. HSE University, Centre for Stability and Risk
#' Analysis. \url{https://social.hse.ru/mr/rev_bd}
#'
#' Salehyan, I., Hendrix, C. S., Hamner, J., Case, C., Linebarger, C.,
#' Stull, E., & Williams, J. (2012). Social conflict in Africa: A new
#' database. *International Interactions*, 38(4), 503-511.
#' \doi{10.1080/03050629.2012.697426}
#'
#' Gleditsch, N. P., Wallensteen, P., Eriksson, M., Sollenberg, M., &
#' Strand, H. (2002). Armed conflict 1946-2001: A new dataset. *Journal of
#' Peace Research*, 39(5), 615-637. \doi{10.1177/0022343302039005007}
#'
#' Svensson, I., Schaftenaar, S., & Allansson, M. (2022). Violent political
#' protest: Introducing a new Uppsala Conflict Data Program data set on
#' organized violence, 1989-2019. *Journal of Conflict Resolution*, 66(9),
#' 1703-1730.
#'
#' Clark, D. H., & Regan, P. M. (2016). *Mass Mobilization Protest Data*.
#' Harvard Dataverse. \doi{10.7910/DVN/HTTWYL}
#'
#' Weidmann, N. B., & Rød, E. G. (2019). *The Internet and Political
#' Protest in Autocracies*. Oxford University Press.
#'
#' Chenoweth, E., & Kang, S. (2026). The Major Episodes of Contention (MEC)
#' Data Project: An introduction. *Journal of Peace Research*, 63(4), 724-734.
#' \doi{10.1093/jopres/xjaf008}
#'
#' Dahl, M., Dahlum, S., Fjelde, H., Gjerløw, H., Knutsen, C. H.,
#' Strøm-Sedgwick, C., & Wig, T. (2026). Mass mobilization in the modern
#' era: Introducing the Opposition Movements and Groups (OMG) dataset,
#' 1789-2019. *Comparative Political Studies*, 59(10), 2117-2158.
#' \doi{10.1177/00104140251369330}
#'
#' Vüllers, J., Bakken, I. V., Johansen, T., Dworschak, C., Butcher, C., &
#' Braithwaite, J. M. (2026). (Un)organized protest: Introducing the Anatomy
#' of Resistance Campaigns 2.0. *Journal of Peace Research*, 63(3), 484-494.
#' \doi{10.1093/jopres/xjag013}
#'
#' Chenoweth, E., Pinckney, J., & Lewis, O. (2018). Days of rage: Introducing
#' the NAVCO 3.0 dataset. *Journal of Peace Research*, 55(4), 524-534.
#' \doi{10.1177/0022343318759411}
#'
#' @export
conflict_data <- function(
    start_year    = 1945,
    end_year      = 2013,
    dataset       = c("navco1.3", "navco2.1", "beissinger", "raqed",
                      "scad", "ucdp_prio", "ucdp_vpp", "mm", "mmad", "mec",
                      "omg", "arc", "navco3.0"),
    coding_system = c("cow", "gw"),
    unit          = c("year", "quarter", "month", "day")
) {
  check_year_range(start_year, end_year)
  if (identical(dataset, "csra")) {
    stop(
      '`dataset = "csra"` was removed in contentiousR 0.2.0: the CSRA ',
      'Revolutionary Database has been renamed RAQED. Use ',
      '`dataset = "raqed"` (version 1.4).',
      call. = FALSE
    )
  }
  dataset       <- match.arg(dataset)
  coding_system <- match.arg(coding_system)
  unit          <- match.arg(unit)
  tk            <- time_keys(unit)
  group_keys    <- c(if (coding_system == "gw" &&
                         dataset %in% c("ucdp_prio", "ucdp_vpp")) "gwno_loc" else "cow",
                     tk)

  yearly_only <- c("navco1.3", "navco2.1", "ucdp_prio", "ucdp_vpp")
  if (unit != "year" && dataset %in% yearly_only) {
    stop(
      '`dataset = "', dataset, '"` is available only with `unit = "year"`: ',
      "the source does not record the exact start date of each event or ",
      "spell. Datasets with country-quarter, country-month, and country-day data: ",
      '"scad", "mm", "mmad", "arc", "navco3.0", "beissinger", "raqed", ',
      '"mec", "omg".',
      call. = FALSE
    )
  }


  # ── Legacy datasets: load once, then process in per-dataset blocks ────────
  legacy_datasets <- c("navco1.3", "navco2.1", "beissinger")
  campaign_datasets <- c(legacy_datasets, "mec", "raqed", "omg")

  if (dataset %in% legacy_datasets) {
    file_name <- dplyr::case_when(
      dataset == "navco1.3"   ~ "NAVCO_1.3.RData",
      dataset == "navco2.1"   ~ "NAVCO_2.1.RData",
      dataset == "beissinger" ~ "revolutionary_episodes_beissinger.csv.xz"
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
      data <- suppressMessages(readr::read_csv(
        path, show_col_types = FALSE,
        locale = readr::locale(encoding = "UTF-8")
      ))
    }
    # Mark text columns UTF-8 immediately: some later step in this
    # function's own dplyr pipeline (not just the final return value)
    # apparently forces these "unknown"-encoded-but-genuinely-UTF-8 columns
    # through a native-encoding conversion partway through, which is where
    # the Windows-only embedded-nul corruption actually happens -- fixing
    # only the returned data frame at the very end of this function was not
    # enough.
    data <- mark_utf8(data)
  }

  # ═══════════════════════════════════════════════════════════════════════════
  # SCAD 2018 - Social Conflict in Africa / Latin America
  # Event-level -> aggregated to country-year inside this function
  # ═══════════════════════════════════════════════════════════════════════════
  if (dataset == "scad") {
    path_africa <- system.file(
      "extdata", "SCAD2018Africa_Final.csv.xz", package = "contentiousR"
    )
    path_latam <- system.file(
      "extdata", "SCAD2018LatinAmerica_Final.csv.xz", package = "contentiousR"
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
      "eventid", "ccode", "styr", "stmo", "stday", "etype", "escalation",
      "npart", "ndeath", "repress", "cgovtarget", "rgovtarget",
      "female_event", "lgbtq_issue"
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
      dplyr::mutate(
        cow   = standardize_cow(.data$ccode, .data$styr),
        month = as.integer(.data$stmo),
        day   = as.integer(.data$stday)
      ) |>
      dplyr::rename(year = "styr") |>
      drop_imprecise_dates(tk, dataset) |>
      dplyr::group_by(dplyr::across(dplyr::all_of(group_keys))) |>
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
      data <- cow_to_gw_column(data)
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
      "extdata", "UcdpPrioConflict_v26_1.csv.xz", package = "contentiousR"
    )
    if (path == "") {
      stop(
        "Could not find `UcdpPrioConflict_v26_1.csv.xz` in package extdata.",
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
          cow = convert_state_code(.data$gwno_loc, .data$year, "gw", "cow")
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
          cow = convert_state_code(.data$gwno_loc, .data$year, "gw", "cow")
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
      dplyr::select(-dplyr::any_of(setdiff(drop_mm, c("protest", "startday",
                                                      "startmonth")))) |>
      # Factors -> character first to preserve text labels (old-style R factor storage)
      dplyr::mutate(dplyr::across(dplyr::where(is.factor), as.character)) |>
      # Coerce only the genuinely numeric columns
      dplyr::mutate(
        ccode             = suppressWarnings(as.integer(.data$ccode)),
        year              = suppressWarnings(as.integer(.data$year)),
        protesterviolence = suppressWarnings(as.integer(.data$protesterviolence)),
        protest           = suppressWarnings(as.integer(.data$protest)),
        month             = suppressWarnings(as.integer(.data$startmonth)),
        day               = suppressWarnings(as.integer(.data$startday)),
        participants_reported = as.character(.data$participants),
        participants      = suppressWarnings(
          as.numeric(.data$participants_reported)
        )
      ) |>
      dplyr::filter(.data$year >= start_year & .data$year <= end_year) |>
      dplyr::mutate(cow = mm_cow_code(.data$ccode, .data$year)) |>
      # Rows with protest == 0 are country-years the source codes as having
      # no protest; they have no start date.
      drop_imprecise_dates(tk, dataset, quiet = TRUE) |>
      dplyr::group_by(dplyr::across(dplyr::all_of(group_keys))) |>
      dplyr::summarise(
        mm_onset      = as.integer(any(.data$protest == 1L, na.rm = TRUE)),
        mm_n_protests = sum(.data$protest == 1L, na.rm = TRUE),
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
      data <- cow_to_gw_column(data)
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
    path <- system.file("extdata", "mmad_events.csv.xz", package = "contentiousR")
    if (path == "") {
      stop("Could not find `mmad_events.csv.xz` in package extdata.", call. = FALSE)
    }

    raw <- readr::read_csv(path, show_col_types = FALSE)

    # Drop: geographic detail (GeoNames location ID, place name, coordinates)
    data <- raw |>
      dplyr::select(dplyr::all_of(c(
        "cowcode", "event_date", "side", "numreports", "max_scope",
        "max_partviolence", "max_secengagement", "mean_avg_numparticipants"
      ))) |>
      dplyr::mutate(
        year  = as.integer(substr(.data$event_date, 1L, 4L)),
        month = as.integer(substr(.data$event_date, 6L, 7L)),
        day   = as.integer(substr(.data$event_date, 9L, 10L)),
        cow   = standardize_cow(.data$cowcode, .data$year),
        side = as.integer(.data$side),
        # Source data stores missing values as the string "NA"
        numreports               = suppressWarnings(as.numeric(.data$numreports)),
        max_scope                = suppressWarnings(as.numeric(.data$max_scope)),
        max_partviolence         = suppressWarnings(as.numeric(.data$max_partviolence)),
        max_secengagement        = suppressWarnings(as.numeric(.data$max_secengagement)),
        mean_avg_numparticipants = suppressWarnings(as.numeric(.data$mean_avg_numparticipants))
      ) |>
      dplyr::filter(.data$year >= start_year & .data$year <= end_year) |>
      drop_imprecise_dates(tk, dataset) |>
      dplyr::group_by(dplyr::across(dplyr::all_of(group_keys))) |>
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
      data <- cow_to_gw_column(data)
    } else {
      data <- dplyr::select(data, "cow", "year", dplyr::everything())
    }
  }

  # ════════════════════════════════════════════════════════════════════════════
  # Major Episodes of Contention (MEC)
  # Published episode-level data; multiple episodes may share a country-year
  # ═════════════════════════════════════════════════════════════════════════════
  if (dataset == "mec") {
    path <- system.file("extdata", "MEC.rds", package = "contentiousR")
    if (path == "") {
      stop("Could not find `MEC.rds` in package extdata.", call. = FALSE)
    }

    data <- readRDS(path) |>
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

    data$cow <- standardize_cow(data$cow, data$year)
    if (coding_system == "gw") {
      data <- cow_to_gw_column(data)
    } else {
      data <- dplyr::select(data, "cow", "year", dplyr::everything())
    }
  }

  # ═══════════════════════════════════════════════════════════════════════════
  # RAQED - Revolutionary and Quasi-revolutionary Episodes Dataset v1.4
  # Episode-level; renamed successor of the CSRA Revolutionary Database
  # ═══════════════════════════════════════════════════════════════════════════
  if (dataset == "raqed") {
    path <- system.file("extdata", "raqed_v1.4.csv.xz", package = "contentiousR")
    if (path == "") {
      stop("Could not find `raqed_v1.4.csv.xz` in package extdata.", call. = FALSE)
    }

    raw <- readr::read_csv(
      path,
      col_types = readr::cols(
        .default   = readr::col_double(),
        start_date = readr::col_date(),
        end_date   = readr::col_date(),
        name       = readr::col_character(),
        country    = readr::col_character(),
        iso3c      = readr::col_character(),
        region     = readr::col_character(),
        type       = readr::col_character(),
        note       = readr::col_character(),
        npart_source_1 = readr::col_character(),
        npart_source_2 = readr::col_character(),
        npart_source_3 = readr::col_character(),
        military_defection_source = readr::col_character(),
        foreign_support_source    = readr::col_character()
      ),
      locale = readr::locale(encoding = "UTF-8")
    )

    data <- raw |>
      dplyr::mutate(
        onset       = 1L,
        type_re     = as.integer(.data$type == "RE"),
        type_re_q   = as.integer(.data$type == "RE?"),
        type_qre    = as.integer(.data$type == "QRE"),
        year        = as.integer(.data$start_year)
      ) |>
      dplyr::select(-"start_year") |>
      dplyr::rename_with(~ paste0("raqed_", .), .cols = -"year") |>
      dplyr::select("year", "raqed_onset", dplyr::everything())

    codes <- suppressWarnings(as.integer(countrycode::countrycode(
      data$raqed_country, "country.name", "cown"
    )))
    codes[data$raqed_country == "Serbia"] <- 345L
    codes <- standardize_cow(codes, data$year)
    data[[coding_system]] <- if (coding_system == "cow") {
      codes
    } else {
      convert_state_code(codes, data$year, "cow", "gw",
                         as.integer(format(data$raqed_start_date, "%m")))
    }
    data <- dplyr::select(data, dplyr::all_of(coding_system), dplyr::everything())
  }

  # ═══════════════════════════════════════════════════════════════════════════
  # OMG - Opposition Movements and Groups, campaign-phase level
  # Country identifiers are V-Dem country_id values
  # ═══════════════════════════════════════════════════════════════════════════
  if (dataset == "omg") {
    path <- system.file("extdata", "omg.rds", package = "contentiousR")
    if (path == "") {
      stop("Could not find `omg.rds` in package extdata.", call. = FALSE)
    }

    raw <- readRDS(path)

    data <- raw |>
      dplyr::mutate(
        year = as.integer(.data$start_year),
        country_id = as.integer(.data$country_id)
      ) |>
      dplyr::group_by(.data$campaign_id) |>
      dplyr::mutate(
        onset = as.integer(.data$phase == min(.data$phase, na.rm = TRUE))
      ) |>
      dplyr::ungroup() |>
      dplyr::mutate(phase_onset = 1L) |>
      dplyr::select(-"start_year") |>
      dplyr::rename_with(~ paste0("omg_", .), .cols = -"year") |>
      dplyr::select("year", "omg_onset", "omg_phase_onset", dplyr::everything())

    vdem_id <- data$omg_country_id
    codes <- suppressWarnings(as.integer(countrycode::countrycode(
      vdem_id, "vdem", "cown"
    )))
    # V-Dem units that countrycode does not convert, or converts to a code
    # that does not match the state system in the campaign year.
    # Western Sahara has no V-Dem country_id in the source and stays NA.
    yemen <- vdem_id %in% 14L
    codes[vdem_id %in% 198L] <- 345L                            # Serbia
    codes[yemen] <- ifelse(data$year[yemen] < 1990L, 678L, 679L)
    codes[vdem_id %in% 373L] <- 325L                            # Piedmont-Sardinia
    codes <- standardize_cow(codes)
    data[[coding_system]] <- if (coding_system == "cow") {
      codes
    } else {
      convert_state_code(codes, data$year, "cow", "gw",
                         as.integer(data$omg_start_month))
    }
    data <- dplyr::select(data, dplyr::all_of(coding_system), dplyr::everything())
  }

  # ═══════════════════════════════════════════════════════════════════════════
  # ARC 2.0 - Anatomy of Resistance Campaigns, events from SCAD and UCDP GED
  # Event-level (org_id lists participating organizations, comma-separated)
  # -> aggregated to country-year
  # ═══════════════════════════════════════════════════════════════════════════
  if (dataset == "arc") {
    path <- system.file("extdata", "ARC_2_0_Events.rds", package = "contentiousR")
    if (path == "") {
      stop("Could not find `ARC_2_0_Events.rds` in package extdata.", call. = FALSE)
    }

    events <- readRDS(path)
    events$year  <- as.integer(format(events$event_startdate, "%Y"))
    events$month <- as.integer(format(events$event_startdate, "%m"))
    events$day   <- as.integer(format(events$event_startdate, "%d"))
    events$cow   <- standardize_cow(events$ccode, events$year)
    events <- events[events$year >= start_year & events$year <= end_year, ]
    events <- drop_imprecise_dates(events, tk, dataset)

    orgs <- strsplit(events$org_id, ",\\s*")
    org_rows <- events[rep(seq_len(nrow(events)), lengths(orgs)), group_keys,
                       drop = FALSE]
    org_rows$org_id <- trimws(unlist(orgs))
    org_rows <- org_rows[!is.na(org_rows$org_id) & org_rows$org_id != "", ]
    n_orgs <- org_rows |>
      dplyr::distinct() |>
      dplyr::count(dplyr::across(dplyr::all_of(group_keys)), name = "arc_n_orgs")

    data <- events |>
      dplyr::mutate(has_org = !is.na(.data$org_id) & .data$org_id != "") |>
      dplyr::group_by(dplyr::across(dplyr::all_of(group_keys))) |>
      dplyr::summarise(
        arc_onset             = 1L,
        arc_n_events          = dplyr::n(),
        arc_n_events_scad     = sum(.data$data_source == "scad"),
        arc_n_events_ged      = sum(.data$data_source == "ged"),
        arc_n_maximalist      = sum(.data$maximalist == 1, na.rm = TRUE),
        arc_n_nonmaximalist   = sum(.data$maximalist == 0, na.rm = TRUE),
        arc_n_nonviolent_scad = sum(.data$nonviolent_scad == 1L, na.rm = TRUE),
        arc_n_events_org      = sum(.data$has_org),
        arc_share_events_org  = mean(.data$has_org),
        .groups = "drop"
      ) |>
      dplyr::left_join(n_orgs, by = group_keys) |>
      dplyr::mutate(
        arc_n_orgs = dplyr::coalesce(.data$arc_n_orgs, 0L)
      )

    if (coding_system == "gw") {
      data <- cow_to_gw_column(data)
    } else {
      data <- dplyr::select(data, "cow", "year", dplyr::everything())
    }
  }

  # ═══════════════════════════════════════════════════════════════════════════
  # NAVCO 3.0 - event-level data on 26 countries, 1990-2012
  # actor_id: 1 state, 2 anti-government campaign, 3 international,
  # 4 non-aligned, 5 local state actors -> aggregated to country-period
  # ═══════════════════════════════════════════════════════════════════════════
  if (dataset == "navco3.0") {
    path <- system.file("extdata", "navco3.0_events.rds", package = "contentiousR")
    if (path == "") {
      stop("Could not find `navco3.0_events.rds` in package extdata.", call. = FALSE)
    }

    events <- readRDS(path)
    events$year  <- as.integer(format(events$date, "%Y"))
    events$month <- as.integer(format(events$date, "%m"))
    events$day   <- as.integer(format(events$date, "%d"))
    events$cow   <- standardize_cow(events$cowcode, events$year)
    events <- events[events$year >= start_year & events$year <= end_year, ]
    events <- drop_imprecise_dates(events, tk, dataset)

    fatal <- parse_count_range(events$fatal_casu)
    injur <- parse_count_range(events$injuries)
    part  <- parse_count_range(events$num_partic_event)
    campaign <- events$actor_id %in% 2
    events$fatal_low  <- fatal$low
    events$fatal_high <- fatal$high
    events$inj_low    <- injur$low
    events$inj_high   <- injur$high
    events$part_low   <- ifelse(campaign, part$low, NA_real_)
    events$part_high  <- ifelse(campaign, part$high, NA_real_)
    events$campaign   <- campaign

    data <- events |>
      dplyr::group_by(dplyr::across(dplyr::all_of(group_keys))) |>
      dplyr::summarise(
        nvc3.0_onset              = as.integer(any(.data$campaign)),
        nvc3.0_n_events           = dplyr::n(),
        nvc3.0_n_campaign_events  = sum(.data$campaign),
        nvc3.0_n_nonviolent       = sum(.data$campaign & .data$tactical_choice %in% 1),
        nvc3.0_n_violent          = sum(.data$campaign & .data$tactical_choice %in% 0),
        nvc3.0_n_mixed            = sum(.data$campaign & .data$tactical_choice %in% 2),
        nvc3.0_n_regime_change    = sum(.data$campaign & .data$camp_goals %in% 0),
        nvc3.0_n_state_events     = sum(.data$actor_id %in% 1),
        nvc3.0_n_concessions      = sum(.data$st_posture %in% 1:3),
        nvc3.0_n_repression       = sum(.data$st_posture %in% 5:7),
        nvc3.0_n_lethal_repression = sum(.data$st_posture %in% 7),
        nvc3.0_fatalities_low     = safe_sum(.data$fatal_low),
        nvc3.0_fatalities_high    = safe_sum(.data$fatal_high),
        nvc3.0_injuries_low       = safe_sum(.data$inj_low),
        nvc3.0_injuries_high      = safe_sum(.data$inj_high),
        nvc3.0_participants_low   = safe_max(.data$part_low),
        nvc3.0_participants_high  = safe_max(.data$part_high),
        .groups = "drop"
      )

    if (coding_system == "gw") {
      data <- cow_to_gw_column(data)
    }
  }

  # ═══════════════════════════════════════════════════════════════════════════
  # Legacy datasets
  # ═══════════════════════════════════════════════════════════════════════════
  if (dataset == "navco1.3") {
    data <- data |>
      dplyr::rename_with(~ paste0("nvc1.3_", .), .cols = 7:ncol(data)) |>
      dplyr::rename_with(~ paste0("nvc1.3_", .), .cols = "CAMPAIGN") |>
      dplyr::mutate(
        nvc1.3_ONSET = 1L,
        cow = suppressWarnings(as.integer(
          countrycode::countrycode(.data$LOCATION, "country.name", "cown")
        )),
        cow = ifelse(.data$LOCATION == "Serbia", 345L, .data$cow)
      ) |>
      dplyr::rename(year = "BYEAR", nvc1.3_EYEAR = "EYEAR") |>
      dplyr::select("cow", "year", dplyr::starts_with("nvc1.3_"))
  }

  if (dataset == "navco2.1") {
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
      dplyr::mutate(cow = ifelse(.data$location == "Serbia", 345L,
                                 as.integer(.data$loc_cow))) |>
      dplyr::select("cow", "year", dplyr::starts_with("nvc2.1_"))
  }

  if (dataset == "beissinger") {
    data <- data |>
      dplyr::mutate(
        # The source also codes sub-state units (e.g. 4321, 7114) and
        # territories that are not COW states; those rows are dropped.
        cow = as.integer(.data$cowcode),
        cow = ifelse(.data$cow %in% states::cowstates$cowcode, .data$cow, NA_integer_),
        cow = ifelse(.data$location == "Serbia", 345L, .data$cow)
      ) |>
      dplyr::rename(
        year = "startyear",
        beissinger_endyear = "endyear"
      ) |>
      dplyr::rename_with(~ paste0("beissinger_", .), .cols = 11:ncol(data)) |>
      dplyr::rename_with(~ paste0("beissinger_", .), .cols = "nameofrevolution") |>
      dplyr::mutate(
        beissinger_onset = 1L,
        beissinger_startdatetxt = .data$startdatetxt
      ) |>
      dplyr::select("cow", "year", dplyr::starts_with("beissinger_"))
  }

  # Legacy datasets: COW codes by the package's conventions, then GW codes
  # by year.
  if (dataset %in% legacy_datasets) {
    data <- data[!is.na(data$cow), , drop = FALSE]
    data$cow <- standardize_cow(data$cow, data$year)
    if (coding_system == "gw") {
      data <- cow_to_gw_column(data)
    }
  }

  # Campaign and episode records: for a country-month or country-day panel,
  # the period comes from the record's start date, at the precision the
  # source reports.
  if (unit != "year" && dataset %in% campaign_datasets) {
    start <- switch(dataset,
      mec        = list(date = data$mec_bdate, precision = "day"),
      raqed      = list(date = data$raqed_start_date, precision = "day"),
      omg        = list(
        date = data$omg_date_start,
        precision = c("day", "month", "year")[data$omg_start_prec]
      ),
      beissinger = parse_beissinger_start(data$beissinger_startdatetxt)
    )
    data$year  <- as.integer(format(start$date, "%Y"))
    data$month <- as.integer(format(start$date, "%m"))
    data$day   <- as.integer(format(start$date, "%d"))
    data$month[start$precision %in% "year"] <- NA_integer_
    data$day[!start$precision %in% "day"]   <- NA_integer_
    data <- drop_imprecise_dates(data, tk, dataset)
  }

  data <- data |>
    dplyr::filter(
      .data$year >= .env$start_year & .data$year <= .env$end_year
    ) |>
    tidyr::drop_na(dplyr::all_of(c(coding_system, tk))) |>
    dplyr::arrange(dplyr::across(dplyr::all_of(c(coding_system, tk)))) |>
    mark_utf8()
  # Drop time columns finer than `unit` (campaign records carry their start
  # month and day).
  data <- data[, setdiff(names(data),
                         setdiff(c("quarter", "month", "day"), tk)),
               drop = FALSE]
  data <- dplyr::select(data, dplyr::all_of(c(coding_system, tk)), dplyr::everything())

  if (!dataset %in% campaign_datasets) {
    check_unique_key(data, c(coding_system, tk))
  }

  return(data)
}
