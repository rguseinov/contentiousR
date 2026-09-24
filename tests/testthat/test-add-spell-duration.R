test_that("add_spell_duration matches the reference peace-years algorithm for onset-style columns", {
  panel <- data.frame(cow = rep(1, 8), year = 2000:2007, x_onset = c(0, 0, 1, 0, 0, 1, 1, 0))

  result <- add_spell_duration(panel, event = "x_onset")

  expect_named(result, c("cow", "year", "x_onset", "x_spell"))
  expect_equal(result$x_spell, c(0L, 1L, 2L, 0L, 1L, 2L, 0L, 0L))
})

test_that("add_spell_duration handles multiple cross-sectional units independently", {
  panel <- data.frame(
    cow  = rep(c(1, 2), each = 6),
    year = rep(2000:2005, 2),
    y_onset = c(0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1)
  )

  result <- add_spell_duration(panel, event = "y_onset")

  expect_equal(
    result$y_spell,
    c(0L, 1L, 0L, 1L, 2L, 0L, 0L, 1L, 2L, 3L, 0L, 1L)
  )
})

test_that("add_spell_duration collapses consecutive events for ongoing-style columns", {
  panel <- data.frame(
    cow = rep(1, 8), year = 2000:2007, x_incidence = c(0, 0, 1, 0, 0, 1, 1, 0)
  )

  result <- add_spell_duration(panel, event = "x_incidence")

  # 2005-2006 is one continuous event (run of 1s); the continuation year (2006)
  # is excluded (NA) rather than treated as a second, independent failure.
  expect_equal(
    result$x_spell,
    c(0L, 1L, 2L, 0L, 1L, 2L, NA_integer_, 0L)
  )
})

test_that("add_spell_duration infers `ongoing` from the column suffix", {
  onset_panel <- data.frame(cow = 1, year = 2000:2001, x_onset = c(1, 0))
  incidence_panel <- data.frame(cow = 1, year = 2000:2001, x_incidence = c(1, 1))

  # An onset column treats every 1 as independent; two consecutive years
  # would each be a fresh failure if this were misread as "ongoing".
  expect_equal(add_spell_duration(onset_panel)$x_spell, c(0L, 0L))
  # An incidence column collapses the run; the second year is a continuation.
  expect_equal(add_spell_duration(incidence_panel)$x_spell, c(0L, NA_integer_))
})

test_that("add_spell_duration auto-detects a unique candidate column and errors when ambiguous", {
  panel <- data.frame(cow = 1, year = 2000:2001, x_onset = c(0, 1))
  expect_equal(add_spell_duration(panel)$x_spell, add_spell_duration(panel, event = "x_onset")$x_spell)

  ambiguous <- data.frame(cow = 1, year = 2000, a_onset = 0, b_incidence = 1)
  expect_error(add_spell_duration(ambiguous), "Multiple candidate")

  none <- data.frame(cow = 1, year = 2000, x = 0)
  expect_error(add_spell_duration(none), "Specify `event`")
})

test_that("add_spell_duration validates its inputs", {
  missing_col <- data.frame(cow = 1, year = 2000, x_onset = 0)
  expect_error(add_spell_duration(missing_col, event = "nope"), "not found")

  has_na <- data.frame(cow = 1, year = 2000:2001, x_onset = c(0, NA))
  expect_error(add_spell_duration(has_na), "contains NA")

  not_binary <- data.frame(cow = 1, year = 2000, x_onset = 2)
  expect_error(add_spell_duration(not_binary), "must be binary")

  already_has_output <- data.frame(cow = 1, year = 2000, x_onset = 0, x_spell = 0)
  expect_error(add_spell_duration(already_has_output), "already has a column")
})

test_that("add_spell_duration counts calendar years, not rows, across a gap", {
  # 2000-2001-2005: a 3-year real gap (e.g. from dropping NA rows upstream).
  # The spell at 2005 must reflect 4 elapsed calendar years since 2001,
  # not 2 (which a row-number-based count would silently produce).
  panel <- data.frame(cow = 1, year = c(2000, 2001, 2005), x_onset = c(0, 0, 0))

  result <- add_spell_duration(panel, event = "x_onset")

  expect_equal(result$x_spell, c(0L, 1L, 5L))
})

test_that("add_spell_duration works with real conflict_data output", {
  panel <- build_states_panel(1990, 2005, coding_system = "gw") |>
    add_conflict(dataset = "ucdp_prio") |>
    tidyr::drop_na("ucdp_prio_onset")

  result <- add_spell_duration(panel, event = "ucdp_prio_onset")

  expect_true("ucdp_prio_spell" %in% names(result))
  expect_equal(nrow(result), nrow(panel))
})
