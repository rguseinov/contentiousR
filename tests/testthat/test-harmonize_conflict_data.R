test_that("harmonize_conflict_data aggregates event-level data to country-year", {
  panel <- build_states_panel(2015, 2018, coding_system = "cow")

  acled_like <- data.frame(
    country    = c("Nigeria", "Nigeria", "Mali", "Mali", "Mali"),
    event_date = c("2016-03-01", "2017-11-20", "2015-06-14", "2015-09-02", "2018-01-30"),
    stringsAsFactors = FALSE
  )

  out <- harmonize_conflict_data(
    panel, acled_like,
    country_col = "country", origin_code = "country.name",
    date_col = "event_date", prefix = "acled"
  )

  expect_equal(nrow(out), nrow(panel))
  expect_true(all(c("acled_onset", "acled_n_events") %in% names(out)))

  mali_2015 <- out[out$cow == 432 & out$year == 2015, ]
  expect_equal(mali_2015$acled_onset, 1L)
  expect_equal(mali_2015$acled_n_events, 2L)

  mali_2016 <- out[out$cow == 432 & out$year == 2016, ]
  expect_true(is.na(mali_2016$acled_onset))
})

test_that("harmonize_conflict_data supports date_format for non-ISO dates", {
  panel <- build_states_panel(2015, 2018, coding_system = "cow")

  gdelt_like <- data.frame(
    Actor1CountryCode = c("NI", "NI", "ML"),
    SQLDATE           = c(20160301L, 20171120L, 20150614L)
  )

  out <- harmonize_conflict_data(
    panel, gdelt_like,
    country_col = "Actor1CountryCode", origin_code = "fips",
    date_col = "SQLDATE", date_format = "%Y%m%d", prefix = "gdelt"
  )

  expect_equal(out$gdelt_n_events[out$cow == 475 & out$year == 2016], 1L)
})

test_that("harmonize_conflict_data supports a pre-extracted year_col", {
  panel <- build_states_panel(2015, 2018, coding_system = "cow")
  d <- data.frame(country = "Mali", yr = 2015)

  out <- harmonize_conflict_data(
    panel, d, country_col = "country", origin_code = "country.name",
    year_col = "yr", prefix = "x"
  )
  expect_equal(out$x_onset[out$cow == 432 & out$year == 2015], 1L)
})

test_that("harmonize_conflict_data reads a factor year_col by its value, not its level code", {
  panel <- build_states_panel(2015, 2018, coding_system = "cow")
  # A factor with levels sorted so the level code ("2") would not equal the
  # printed year ("2016") if as.integer() were applied to the factor itself.
  d <- data.frame(country = "Mali", yr = factor("2016", levels = c("2015", "2016", "2017")))

  out <- harmonize_conflict_data(
    panel, d, country_col = "country", origin_code = "country.name",
    year_col = "yr", prefix = "x"
  )
  expect_equal(out$x_onset[out$cow == 432 & out$year == 2016], 1L)
})

test_that("harmonize_conflict_data errors informatively on an unparseable date_col", {
  panel <- build_states_panel(2015, 2018, coding_system = "cow")
  d <- data.frame(country = "Mali", event_date = "01 March 2016")

  expect_error(
    harmonize_conflict_data(
      panel, d, country_col = "country", origin_code = "country.name",
      date_col = "event_date", prefix = "x"
    ),
    "could not be parsed as a date"
  )
})

test_that("harmonize_conflict_data(aggregate = FALSE) joins data as-is, prefixed", {
  panel <- build_states_panel(2015, 2018, coding_system = "cow")
  d <- data.frame(
    country    = c("Nigeria", "Mali"),
    event_date = c("2016-03-01", "2015-06-14"),
    fatalities = c(5L, 2L),
    stringsAsFactors = FALSE
  )

  out <- harmonize_conflict_data(
    panel, d, country_col = "country", origin_code = "country.name",
    date_col = "event_date", prefix = "acled", aggregate = FALSE
  )

  expect_true("acled_fatalities" %in% names(out))
  expect_equal(out$acled_fatalities[out$cow == 432 & out$year == 2015], 2L)

  dupes <- data.frame(
    country = c("Mali", "Mali"), event_date = c("2015-06-14", "2015-09-02")
  )
  expect_error(
    harmonize_conflict_data(
      panel, dupes, country_col = "country", origin_code = "country.name",
      date_col = "event_date", prefix = "x", aggregate = FALSE
    ),
    "not uniquely identified"
  )
})

test_that("harmonize_conflict_data validates its inputs", {
  panel <- build_states_panel(2015, 2018, coding_system = "cow")
  d <- data.frame(country = "Mali", year = 2015)

  expect_error(
    harmonize_conflict_data(panel, d, "country", "country.name", "x"),
    "exactly one"
  )
  expect_error(
    harmonize_conflict_data(
      panel, d, "country", "country.name", "x",
      year_col = "year", date_col = "year"
    ),
    "exactly one"
  )
  expect_error(
    harmonize_conflict_data(panel, d, "nope", "country.name", "x", year_col = "year"),
    "not found in `data`"
  )
  expect_error(
    harmonize_conflict_data(panel, d, "country", "country.name", "", year_col = "year"),
    "non-empty string"
  )
  expect_error(
    harmonize_conflict_data(panel, "not a data frame", "country", "country.name", "x", year_col = "year"),
    "must be a data frame"
  )

  once <- harmonize_conflict_data(panel, d, "country", "country.name", "x", year_col = "year")
  expect_error(
    harmonize_conflict_data(once, d, "country", "country.name", "x", year_col = "year"),
    "already has column"
  )
})

test_that("harmonize_conflict_data drops and reports unmatched/unparseable rows", {
  panel <- build_states_panel(2015, 2018, coding_system = "cow")
  d <- data.frame(
    country = c("Mali", "Not A Real Country"),
    year    = c(2015, 2016)
  )

  expect_message(
    harmonize_conflict_data(panel, d, "country", "country.name", "y", year_col = "year"),
    "1 row\\(s\\) of `data` dropped"
  )
})

test_that("harmonize_conflict_data works with a gw-coded panel", {
  panel <- build_states_panel(2015, 2018, coding_system = "gw")
  d <- data.frame(country = "Mali", year = 2015)

  out <- harmonize_conflict_data(
    panel, d, country_col = "country", origin_code = "country.name",
    year_col = "year", prefix = "x"
  )
  expect_true("x_onset" %in% names(out))
  expect_equal(out$x_onset[out$gw == 432 & out$year == 2015], 1L)
})
