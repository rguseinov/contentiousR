conflict_ranges <- list(
  "navco1.3" = 1990:1991,
  "navco2.1" = 1990:1991,
  "beissinger" = 1990:1991,
  "csra" = 2000:2001,
  "scad" = 1990:1991,
  "ucdp_prio" = 1990:1991,
  "ucdp_vpp" = 2010:2011,
  "mm" = 1990:1991,
  "mmad" = 2003:2004,
  "mec" = 1990:1991
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
  datasets <- c("scad", "ucdp_prio", "ucdp_vpp", "mm", "mmad")

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
  expect_false(any(mec_gw$mec_location == "Tonga"))
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
  for (ds in c("navco1.3", "navco2.1", "beissinger", "csra")) {
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
