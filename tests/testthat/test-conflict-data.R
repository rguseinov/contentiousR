conflict_ranges <- list(
  "navco1.3" = 1990:1991,
  "navco2.1" = 1990:1991,
  "beissinger" = 1990:1991,
  "raqed" = 2000:2001,
  "scad" = 1990:1991,
  "ucdp_prio" = 1990:1991,
  "ucdp_vpp" = 2010:2011,
  "mm" = 1990:1991,
  "mmad" = 2003:2004,
  "mec" = 1990:1991,
  "omg" = 1990:1991,
  "arc" = 1990:1991,
  "navco3.0" = 2000:2001
)

test_that("all conflict sources honor the requested years", {
  for (dataset in names(conflict_ranges)) {
    years <- conflict_ranges[[dataset]]
    for (coding_system in c("cow", "gw")) {
      data <- conflict_data(
        min(years), max(years), dataset, coding_system
      )

      expect_gt(nrow(data), 0L)
      expect_true(all(data$year %in% years), info = dataset)
      expect_true(
        all(c(coding_system, "year") %in% names(data)),
        info = dataset
      )
    }
  }
})

test_that("country-year conflict sources have unique keys", {
  datasets <- c("scad", "ucdp_prio", "ucdp_vpp", "mm", "mmad", "arc", "navco3.0")

  for (dataset in datasets) {
    years <- conflict_ranges[[dataset]]
    data <- conflict_data(min(years), max(years), dataset, "gw")
    expect_false(
      anyDuplicated(data[c("gw", "year")]) > 0L,
      info = dataset
    )
  }
})

test_that("SCAD aggregation excludes placeholders and location duplicates", {
  scad <- conflict_data(1989, 2017, "scad", "cow")

  expect_equal(sum(scad$scad_n_events), 20927L)
  expect_false(any(scad$scad_ndeath_total < 0, na.rm = TRUE))
  expect_true(any(is.na(scad$scad_ndeath_total)))
})

test_that("UCDP distinguishes episode onset from incidence", {
  ucdp <- conflict_data(1946, 2025, "ucdp_prio", "gw")

  expect_true(all(ucdp$ucdp_prio_incidence == 1L))
  expect_true(any(ucdp$ucdp_prio_onset == 0L))
  expect_true(any(ucdp$ucdp_prio_onset == 1L))
  expect_true(all(ucdp$ucdp_prio_onset <= ucdp$ucdp_prio_incidence))
})

test_that("VPP compatibility alias is explicit", {
  vpp <- conflict_data(1989, 2025, "ucdp_vpp", "gw")
  expect_identical(vpp$ucdp_vpp_onset, vpp$ucdp_vpp_incidence)
})

test_that("Mass Mobilization preserves nonnumeric participant reports", {
  mm <- conflict_data(1990, 1991, "mm", "cow")

  expect_type(mm$mm_participants, "double")
  expect_type(mm$mm_participants_reported, "character")
  expect_true(any(grepl("[<>]", mm$mm_participants_reported)))
})

test_that("MMAD all-missing means are represented by NA", {
  protest_events <- conflict_data(2003, 2022, "mmad", "cow")
  expect_false(any(is.nan(protest_events$mmad_mean_participants)))
  expect_true(any(is.na(protest_events$mmad_mean_participants)))
})

test_that("MEC preserves the published episode-level release", {
  mec <- conflict_data(1955, 2018, "mec", "cow")

  expect_equal(nrow(mec), 2734L)
  expect_equal(ncol(mec), 95L)
  expect_equal(length(unique(mec$mec_id)), 2734L)
  expect_equal(as.integer(table(mec$mec_category)), c(2255L, 479L))
  expect_equal(range(mec$year), c(1955L, 2018L))
  expect_true(all(mec$mec_episode == 1L))
  expect_equal(sum(as.integer(format(mec$mec_bdate, "%Y")) < mec$year), 14L)
  expect_true(all(c("mec_campaign", "mec_bdate", "mec_outcome") %in% names(mec)))
})

test_that("MEC applies documented COW to GW historical mappings", {
  mec_cow <- conflict_data(1955, 2018, "mec", "cow")
  mec_gw <- conflict_data(1955, 2018, "mec", "gw")

  expect_true(any(mec_cow$cow == 679L))
  expect_true(any(mec_cow$cow == 817L))
  expect_true(any(mec_cow$cow == 955L))
  expect_true(any(mec_gw$gw == 678L))
  expect_true(any(mec_gw$gw == 817L))
  expect_true(all(mec_gw$gw[mec_gw$mec_location %in% "Tonga"] == 972L))
  # Serbia from 2006 is GW 340; Yugoslavia before that is GW 345.
  serbia <- mec_gw$mec_location %in% c("Serbia", "Yugoslavia")
  expect_true(all(mec_gw$gw[serbia & mec_gw$year >= 2007L] == 340L))
  expect_true(all(mec_gw$gw[serbia & mec_gw$year <= 2005L] == 345L))
})

test_that("MEC can be joined raw or with the existing aggregation policy", {
  panel <- build_states_panel(1990, 1991, "cow")

  raw <- add_conflict(panel, "mec", aggregate = FALSE)
  aggregated <- suppressMessages(add_conflict(panel, "mec"))

  expect_gt(nrow(raw), nrow(panel))
  expect_true(anyDuplicated(raw[c("cow", "year")]) > 0L)
  expect_equal(nrow(aggregated), nrow(panel))
  expect_false(anyDuplicated(aggregated[c("cow", "year")]) > 0L)
  expect_true("n_campaigns" %in% names(aggregated))
})

test_that("conflict_data() text columns are tagged UTF-8, not left unknown", {
  # An "unknown"-encoded but genuinely UTF-8 string (e.g. NAVCO 1.3's
  # "Student’s Anti-Chun Protest" campaign name) is treated as the
  # platform's native encoding wherever it's next converted -- harmless on
  # macOS/Linux, but this silently corrupted into an embedded nul byte on
  # Windows, making R CMD check's vignette rebuild fail outright.
  for (ds in c("navco1.3", "navco2.1", "beissinger", "raqed", "omg")) {
    events <- conflict_data(1900, 2020, dataset = ds, coding_system = "cow")
    char_cols <- names(events)[vapply(events, is.character, logical(1))]
    for (col in char_cols) {
      non_ascii <- grepl("[^\x01-\x7f]", events[[col]])
      expect_false(
        any(non_ascii & Encoding(events[[col]]) == "unknown"),
        info = paste(ds, col)
      )
    }
  }
})

test_that("RAQED is episode-level with type dummies", {
  raqed <- conflict_data(2000, 2026, "raqed", "cow")

  expect_equal(nrow(raqed), 245L)
  expect_true(all(raqed$raqed_onset == 1L))
  expect_false(anyDuplicated(raqed$raqed_n) > 0L)
  expect_true(all(
    raqed$raqed_type_re + raqed$raqed_type_re_q + raqed$raqed_type_qre == 1L
  ))
  expect_s3_class(raqed$raqed_start_date, "Date")
  expect_true(all(raqed$cow[raqed$raqed_country == "Serbia"] == 345L))

  raqed_gw <- conflict_data(2000, 2026, "raqed", "gw")
  serbia <- raqed_gw$raqed_country == "Serbia"
  expect_true(all(raqed_gw$gw[serbia & raqed_gw$year >= 2007L] == 340L))
  expect_true(all(raqed_gw$gw[serbia & raqed_gw$year <= 2005L] == 345L))
  expect_true(all(raqed_gw$gw[raqed_gw$raqed_country == "Yemen"] == 678L))
})

test_that("csra was removed in favour of raqed", {
  expect_error(conflict_data(2000, 2024, "csra", "cow"), "raqed")
  expect_error(
    add_conflict(build_states_panel(2000, 2001, "cow"), "csra"),
    "raqed"
  )
})

test_that("OMG onset marks only the first phase of each campaign", {
  omg <- conflict_data(1789, 2019, "omg", "cow")

  expect_true(all(omg$omg_phase_onset == 1L))
  first <- omg[omg$omg_onset == 1L, ]
  expect_false(anyDuplicated(first$omg_campaign_id) > 0L)
  expect_true(all(omg$omg_phase[omg$omg_onset == 0L] > 1))
  expect_true(all(omg$cow[omg$omg_country_name == "Serbia"] == 345L))
  expect_true(all(
    omg$cow[omg$omg_country_name == "Yemen" & omg$year >= 1990] == 679L
  ))
  expect_false(any(omg$omg_country_name == "Western Sahara"))
})

test_that("ARC aggregates events and organizations to country-year", {
  arc <- conflict_data(1990, 2018, "arc", "cow")

  expect_equal(sum(arc$arc_n_events), 28683L)
  expect_equal(arc$arc_n_events, arc$arc_n_events_scad + arc$arc_n_events_ged)
  expect_equal(arc$arc_n_events, arc$arc_n_maximalist + arc$arc_n_nonmaximalist)
  expect_true(all(arc$arc_share_events_org >= 0 & arc$arc_share_events_org <= 1))

  algeria <- arc[arc$cow == 615L & arc$year == 2014L, ]
  expect_equal(algeria$arc_n_events, 56L)
  expect_equal(algeria$arc_n_orgs, 8L)
})

test_that("Mass Mobilization country-years without protest are zero, not onsets", {
  mm <- conflict_data(1990, 2020, "mm", "cow")
  expect_true(any(mm$mm_onset == 0L))
  expect_true(all(mm$mm_n_protests[mm$mm_onset == 0L] == 0L))
  expect_true(all(mm$mm_n_protests[mm$mm_onset == 1L] > 0L))
})

test_that("NAVCO 3.0 separates campaign and state actions", {
  navco3 <- conflict_data(1990, 2012, "navco3.0", "cow")
  expect_equal(sum(navco3$nvc3.0_n_events), 112381L)
  expect_true(all(navco3$nvc3.0_n_campaign_events <= navco3$nvc3.0_n_events))
  expect_true(all(
    navco3$nvc3.0_n_nonviolent + navco3$nvc3.0_n_violent + navco3$nvc3.0_n_mixed <=
      navco3$nvc3.0_n_campaign_events
  ))
  expect_equal(navco3$nvc3.0_onset, as.integer(navco3$nvc3.0_n_campaign_events > 0L))
  expect_true(all(
    navco3$nvc3.0_participants_low <= navco3$nvc3.0_participants_high,
    na.rm = TRUE
  ))
})

test_that("parse_count_range() reads numbers and ranges", {
  out <- parse_count_range(c("11", "500 - 3000", "100-300", ".", NA))
  expect_equal(out$low, c(11, 500, 100, NA, NA))
  expect_equal(out$high, c(11, 3000, 300, NA, NA))
})
