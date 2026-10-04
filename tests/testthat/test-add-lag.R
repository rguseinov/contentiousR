test_that("add_lag lags within each state, resetting at the start of each series", {
  panel <- build_states_panel(1990, 1992, coding_system = "cow") |>
    add_gdp() |>
    add_lag(vars = "gdp_pcap")

  usa <- panel[panel$cow == 2, ]
  usa <- usa[order(usa$year), ]

  expect_true("gdp_pcap_l" %in% names(panel))
  expect_true(is.na(usa$gdp_pcap_l[1]))
  expect_equal(usa$gdp_pcap_l[-1], usa$gdp_pcap[-nrow(usa)])
})

test_that("add_lag supports lagging by more than one year", {
  panel <- build_states_panel(1990, 1994, coding_system = "cow") |>
    add_gdp() |>
    add_lag(vars = "gdp_pcap", n = 2)

  usa <- panel[panel$cow == 2, ]
  usa <- usa[order(usa$year), ]

  expect_true(all(is.na(usa$gdp_pcap_l[1:2])))
  expect_equal(usa$gdp_pcap_l[-(1:2)], usa$gdp_pcap[1:(nrow(usa) - 2)])
})

test_that("add_lag returns NA across a gap in the year sequence instead of the wrong year's value", {
  panel <- build_states_panel(1990, 1995, coding_system = "cow") |> add_gdp()
  panel <- panel[!(panel$cow == 2 & panel$year == 1992), ]
  panel <- add_lag(panel, vars = "gdp_pcap", n = 1)

  usa <- panel[panel$cow == 2, ]
  # 1993's true predecessor (1992) is missing, so its lag must be NA, not 1991's value
  expect_true(is.na(usa$gdp_pcap_l[usa$year == 1993]))
  # 1994 correctly picks up 1993, which is genuinely one year prior
  expect_equal(
    usa$gdp_pcap_l[usa$year == 1994],
    usa$gdp_pcap[usa$year == 1993]
  )
})

test_that("add_lag handles multiple variables and multiple units together", {
  panel <- build_states_panel(1990, 1992, coding_system = "cow") |>
    add_gdp() |>
    add_lag(vars = c("gdp_pcap", "gdp_growth"))

  expect_true(all(c("gdp_pcap_l", "gdp_growth_l") %in% names(panel)))

  first_years <- panel[panel$year == 1990, ]
  expect_true(all(is.na(first_years$gdp_pcap_l)))
  expect_true(all(is.na(first_years$gdp_growth_l)))
})

test_that("add_lag validates its inputs", {
  panel <- build_states_panel(1990, 1991, coding_system = "cow") |> add_gdp()

  expect_error(add_lag(panel, vars = "nonexistent"), "not found")
  expect_error(add_lag(panel, vars = "gdp_pcap", n = 0), "positive whole number")
  expect_error(add_lag(panel, vars = "gdp_pcap", n = 1.5), "positive whole number")

  already <- add_lag(panel, vars = "gdp_pcap")
  expect_error(add_lag(already, vars = "gdp_pcap"), "already has column")
})
