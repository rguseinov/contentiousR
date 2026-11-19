test_that("build_states_panel() supports month and day units", {
  yearly <- build_states_panel(2000, 2001, "cow")
  monthly <- build_states_panel(2000, 2001, "cow", unit = "month")
  daily <- build_states_panel(2000, 2000, "gw", unit = "day")

  expect_named(yearly, c("cow", "year", "country"))
  expect_true(all(c("cow", "year", "month", "country") %in% names(monthly)))
  expect_true(all(c("gw", "year", "month", "day", "date") %in% names(daily)))
  expect_false(anyDuplicated(monthly[c("cow", "year", "month")]) > 0L)
  expect_false(anyDuplicated(daily[c("gw", "date")]) > 0L)
  expect_equal(nrow(monthly), 12L * nrow(yearly))
  expect_equal(sum(daily$gw == 2L), 366L)
})

test_that("German unification is not duplicated in a monthly COW panel", {
  monthly <- build_states_panel(1990, 1990, "cow", unit = "month")
  germany <- monthly[monthly$cow == 255L, ]
  expect_equal(nrow(germany), 12L)
  expect_equal(germany$country[germany$month == 9L], "German Federal Republic")
  expect_equal(germany$country[germany$month == 10L], "Germany")
})

test_that("event counts are the same at every unit", {
  counts <- c(
    scad = "scad_n_events", mmad = "mmad_n_events", arc = "arc_n_events",
    navco3.0 = "nvc3.0_n_events"
  )
  for (ds in names(counts)) {
    yearly <- suppressMessages(conflict_data(2000, 2005, ds, "cow"))
    monthly <- suppressMessages(conflict_data(2000, 2005, ds, "cow", unit = "month"))
    expect_equal(sum(monthly[[counts[[ds]]]]), sum(yearly[[counts[[ds]]]]), info = ds)
    expect_false(anyDuplicated(monthly[c("cow", "year", "month")]) > 0L, info = ds)
  }
})

test_that("year-only datasets refuse sub-annual units", {
  for (ds in c("navco1.3", "navco2.1", "ucdp_prio", "ucdp_vpp")) {
    expect_error(
      conflict_data(2000, 2001, ds, unit = "month"),
      "available only with `unit = \"year\"`",
      info = ds
    )
  }
})

test_that("episode records are placed by start date and imprecise ones dropped", {
  raqed <- conflict_data(2011, 2011, "raqed", "cow", unit = "day")
  expect_equal(
    as.Date(sprintf("%d-%02d-%02d", raqed$year, raqed$month, raqed$day)),
    raqed$raqed_start_date
  )
  expect_message(
    conflict_data(1789, 2019, "omg", "cow", unit = "month"),
    "without a month-precise start date"
  )
})

test_that("add_conflict(), add_lag() and add_spell_duration() follow the unit", {
  panel <- build_states_panel(2011, 2011, "cow", unit = "month") |>
    add_conflict("mmad")
  expect_equal(nrow(panel), nrow(build_states_panel(2011, 2011, "cow", unit = "month")))

  egypt <- panel[panel$cow == 651L, ]
  egypt$mmad_onset[is.na(egypt$mmad_onset)] <- 0L
  egypt <- add_lag(egypt, "mmad_n_events")
  expect_equal(egypt$mmad_n_events_l[-1], egypt$mmad_n_events[-12])

  toy <- data.frame(
    cow = 2L, year = 2000L, month = 1:4, onset = c(1L, 0L, 0L, 1L)
  )
  expect_equal(add_spell_duration(toy, "onset")$onset_spell, c(0L, 0L, 1L, 2L))
})

test_that("annual data repeat within a year in a monthly panel", {
  panel <- build_states_panel(2000, 2000, "cow", unit = "month") |> add_gdp()
  us <- panel[panel$cow == 2L, ]
  expect_length(unique(us$gdp_pcap), 1L)
})

test_that("peacesciencer helpers require a country-year panel", {
  monthly <- build_states_panel(2000, 2000, "cow", unit = "month")
  expect_error(as_peacesciencer_panel(monthly), "country-year panel")
})
