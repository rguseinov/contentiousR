test_that("add functions preserve a unique panel's rows", {
  panel <- build_states_panel(1990, 1991, "cow")

  with_gdp <- add_gdp(panel)
  with_leaders <- add_leader_data(panel, "archigos")
  with_conflict <- add_conflict(panel, "ucdp_prio")

  expect_equal(nrow(with_gdp), nrow(panel))
  expect_equal(nrow(with_leaders), nrow(panel))
  expect_equal(nrow(with_conflict), nrow(panel))
  expect_true("gdp_pcap" %in% names(with_gdp))
  expect_true("leader" %in% names(with_leaders))
  expect_true("ucdp_prio_incidence" %in% names(with_conflict))
  expect_false("n_campaigns" %in% names(with_conflict))
})

test_that("add_gdp supports the fariss dataset", {
  panel <- build_states_panel(1990, 1991, "cow")
  joined <- add_gdp(panel, dataset = "fariss")

  expect_equal(nrow(joined), nrow(panel))
  expect_true(all(c("fariss_gdp", "fariss_gdppc") %in% names(joined)))
})

test_that("add_population supports all three population datasets", {
  panel <- build_states_panel(1990, 1991, "cow")

  with_wpp <- add_population(panel)
  with_nmc <- add_population(panel, dataset = "nmc")
  with_fariss <- add_population(panel, dataset = "fariss")

  expect_equal(nrow(with_wpp), nrow(panel))
  expect_equal(nrow(with_nmc), nrow(panel))
  expect_equal(nrow(with_fariss), nrow(panel))
  expect_true("wpp_pop" %in% names(with_wpp))
  expect_true(all(c("nmc_tpop", "nmc_upop") %in% names(with_nmc)))
  expect_true("fariss_pop" %in% names(with_fariss))
})

test_that("add_military_expenditure supports all three sources", {
  panel <- build_states_panel(1990, 1991, "cow")

  with_sipri <- add_military_expenditure(panel)
  with_nmc <- add_military_expenditure(panel, dataset = "nmc")
  with_barnum <- add_military_expenditure(panel, dataset = "barnum")

  expect_equal(nrow(with_sipri), nrow(panel))
  expect_equal(nrow(with_nmc), nrow(panel))
  expect_equal(nrow(with_barnum), nrow(panel))
  expect_true(all(c("sipri_milex", "sipri_milburden") %in% names(with_sipri)))
  expect_true("nmc_milex" %in% names(with_nmc))
  expect_true(
    all(c("barnum_milburden", "barnum_sipri", "barnum_nmc") %in% names(with_barnum))
  )
})

test_that("legacy aggregation does not create infinities", {
  panel <- build_states_panel(1990, 1992, "cow")
  joined <- NULL
  expect_message(
    joined <- add_conflict(panel, "navco2.1"),
    "Aggregating to country-year"
  )
  numeric_columns <- vapply(joined, is.numeric, logical(1))

  expect_false(any(vapply(
    joined[numeric_columns],
    function(x) any(is.infinite(x), na.rm = TRUE),
    logical(1)
  )))
  expect_equal(nrow(joined), nrow(panel))
  expect_true("n_campaigns" %in% names(joined))
})

test_that("country-year conflict data pass through without losing text", {
  panel <- build_states_panel(1990, 1991, "cow")
  joined <- add_conflict(panel, "mm")

  expect_true("mm_participants_reported" %in% names(joined))
  expect_false("n_campaigns" %in% names(joined))
})

test_that("add functions reject ambiguous or malformed panels", {
  expect_error(add_gdp(data.frame(year = 2000)), "country-code column")
  expect_error(
    add_gdp(data.frame(cow = 2, gw = 2, year = 2000)),
    "exactly one"
  )
  expect_error(
    add_gdp(data.frame(cow = numeric(), year = numeric())),
    "at least one"
  )
  expect_error(
    add_gdp(data.frame(cow = 2, year = "2000")),
    "finite numeric years"
  )
  expect_error(
    add_conflict(data.frame(cow = 2, year = 2000), "scad", aggregate = NA),
    "`aggregate` must be `TRUE` or `FALSE`"
  )
})

test_that("V-Dem can be added without changing panel rows", {
  skip_if_not_installed("vdemdata")
  panel <- build_states_panel(2000, 2001, "gw")
  joined <- add_vdem(panel, "v2x_polyarchy")

  expect_equal(nrow(joined), nrow(panel))
  expect_true("v2x_polyarchy" %in% names(joined))
})
