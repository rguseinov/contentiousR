test_that("list_datasets() describes every conflict dataset", {
  all <- list_datasets()
  conflict <- list_datasets("conflict")
  expect_true(all(c("dataset", "topic", "start_year", "end_year", "units",
                    "prefix", "zero_fill") %in% names(all)))
  expect_setequal(conflict$dataset, eval(formals(conflict_data)$dataset))
  expect_false(anyNA(conflict$zero_fill))
  expect_true(all(is.na(all$zero_fill[all$topic != "conflict"])))
  expect_error(list_datasets("nonsense"))
})

test_that("fill_zero sets 0 only inside a dataset's coverage", {
  panel <- build_states_panel(2002, 2013, "cow", unit = "month")
  plain <- add_conflict(panel, "mmad")
  filled <- add_conflict(panel, "mmad", fill_zero = TRUE)

  egypt <- filled[filled$cow == 651L & filled$year == 2012L, ]
  expect_equal(egypt$mmad_n_events[egypt$month == 7L], 0)
  expect_true(is.na(egypt$mmad_max_scope[egypt$month == 7L]))
  expect_true(is.na(plain$mmad_onset[plain$cow == 651L & plain$year == 2012L &
                                       plain$month == 7L]))
  # Outside MMAD's years and outside its countries
  expect_true(all(is.na(filled$mmad_onset[filled$year == 2002L])))
  expect_true(all(is.na(filled$mmad_onset[filled$cow == 220L])))
  # Only NA values change
  same <- !is.na(plain$mmad_n_events)
  expect_equal(filled$mmad_n_events[same], plain$mmad_n_events[same])
})

test_that("fill_zero follows the country-years Mass Mobilization lists", {
  panel <- build_states_panel(1995, 1995, "cow")
  filled <- add_conflict(panel, "mm", fill_zero = TRUE)
  listed <- conflict_data(1995, 1995, "mm", "cow")
  covered <- filled$cow %in% listed$cow
  expect_false(anyNA(filled$mm_onset[covered]))
  expect_true(all(is.na(filled$mm_onset[!covered])))
})

test_that("episode datasets mark periods in progress", {
  monthly <- suppressMessages(add_conflict(
    build_states_panel(2011, 2011, "cow", unit = "month"), "raqed",
    fill_zero = TRUE
  ))
  egypt <- monthly[monthly$cow == 651L, ]
  expect_equal(egypt$raqed_onset[1:3], c(1, 0, 0))
  expect_equal(egypt$raqed_incidence[1:3], c(1, 1, 0))

  for (ds in c("navco1.3", "navco2.1", "beissinger", "raqed", "mec", "omg")) {
    out <- suppressMessages(add_conflict(build_states_panel(1990, 2010, "cow"), ds))
    prefix <- list_datasets("conflict")$prefix[list_datasets("conflict")$dataset == ds]
    incidence <- out[[paste0(prefix, "incidence")]]
    n_active <- out[[paste0(prefix, "n_active")]]
    onset <- out[[grep("_(onset|ONSET)$", names(out), value = TRUE)[1]]]
    expect_true(all(!is.na(incidence[!is.na(onset)])), info = ds)
    expect_true(all(n_active >= 1L, na.rm = TRUE), info = ds)
    expect_false(anyDuplicated(out[c("cow", "year")]) > 0L, info = ds)
  }
})

test_that("monthly campaign joins do not add a day column", {
  monthly <- suppressMessages(add_conflict(
    build_states_panel(2010, 2011, "cow", unit = "month"), "raqed"
  ))
  expect_false("day" %in% names(monthly))
  expect_equal(contentiousR:::detect_panel_unit(monthly), "month")
})

test_that("leaders are placed by their dates in office", {
  monthly <- load_leader_data(2011, 2011, "archigos", "cow", unit = "month")
  egypt <- monthly[monthly$cow == 651L, ]
  expect_equal(egypt$leader[egypt$month == 1L], "Mubarak")
  expect_equal(egypt$leader[egypt$month == 2L], "Tantawi")
  expect_equal(egypt$leader_tenure_months[egypt$month == 3L], 2L)

  daily <- build_states_panel(2011, 2011, "cow", unit = "day") |>
    add_leader_data()
  expect_equal(
    daily$leader[daily$cow == 651L & daily$month == 2L & daily$day == 10L],
    "Mubarak"
  )
  expect_error(load_leader_data(2011, 2011, "reign", unit = "day"), "REIGN")
})

test_that("REIGN keeps leaders still in office when the data end", {
  reign <- load_leader_data(2019, 2021, "reign", "cow")
  expect_equal(reign$leader[reign$cow == 365L & reign$year == 2021L], "Putin")
  expect_equal(reign$leader[reign$cow == 2L & reign$year == 2021L], "Biden")
})

test_that("quarterly panels work end to end", {
  quarterly <- build_states_panel(2010, 2012, "gw", unit = "quarter")
  yearly <- build_states_panel(2010, 2012, "gw")
  expect_true(all(c("gw", "year", "quarter", "country") %in% names(quarterly)))
  # South Sudan (GW 626) became independent in July 2011.
  expect_equal(nrow(quarterly), 4L * nrow(yearly) - 2L)
  expect_equal(quarterly$quarter[quarterly$gw == 626L & quarterly$year == 2011L],
               c(3L, 4L))
  expect_false(anyDuplicated(quarterly[c("gw", "year", "quarter")]) > 0L)

  q <- add_conflict(quarterly, "mmad")
  y <- add_conflict(yearly, "mmad")
  expect_equal(sum(q$mmad_n_events, na.rm = TRUE),
               sum(y$mmad_n_events, na.rm = TRUE))
  lagged <- add_lag(q, "mmad_n_events")
  egypt <- lagged[lagged$gw == 651L, ]
  expect_equal(egypt$mmad_n_events_l[-1], egypt$mmad_n_events[-nrow(egypt)])
})

test_that("aggregate_panel() reproduces annual data from monthly data", {
  monthly <- build_states_panel(2008, 2012, "cow", unit = "month") |>
    add_gdp() |>
    add_conflict("scad") |>
    add_conflict("mmad", fill_zero = TRUE) |>
    add_lag("gdp_pcap")
  yearly <- build_states_panel(2008, 2012, "cow") |>
    add_gdp() |>
    add_conflict("scad") |>
    add_conflict("mmad", fill_zero = TRUE)

  aggregated <- suppressMessages(aggregate_panel(monthly, "year"))
  expect_named(aggregated, setdiff(names(yearly), character(0)),
               ignore.order = TRUE)
  expect_false("gdp_pcap_l" %in% names(aggregated))
  joined <- merge(yearly, aggregated, by = c("cow", "year"))
  for (v in c("gdp_pcap", "scad_n_events", "scad_escalation_max",
              "mmad_onset", "mmad_n_events", "mmad_max_scope")) {
    expect_equal(joined[[paste0(v, ".x")]], joined[[paste0(v, ".y")]], info = v)
  }

  quarterly <- suppressMessages(aggregate_panel(monthly, "quarter"))
  expect_equal(contentiousR:::detect_panel_unit(quarterly), "quarter")
  expect_equal(sum(quarterly$mmad_n_events, na.rm = TRUE),
               sum(monthly$mmad_n_events, na.rm = TRUE))

  arc_monthly <- build_states_panel(2010, 2010, "cow", unit = "month") |>
    add_conflict("arc")
  arc_yearly <- suppressMessages(aggregate_panel(arc_monthly, "year"))
  nigeria <- arc_monthly[arc_monthly$cow == 475L, ]
  expect_equal(arc_yearly$arc_n_orgs[arc_yearly$cow == 475L],
               max(nigeria$arc_n_orgs, na.rm = TRUE))

  expect_error(aggregate_panel(yearly, "year"), "coarser")
  expect_error(aggregate_panel(monthly, "year", sum = "nope"), "not in `panel`")
  overridden <- suppressMessages(aggregate_panel(monthly, "year",
                                                 sum = "mmad_onset"))
  expect_true(max(overridden$mmad_onset, na.rm = TRUE) > 1)
})
