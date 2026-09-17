test_that("GDP data are ranged, keyed, and derived consistently", {
  gdp <- load_gdp_data(1990, 1992, coding_system = "cow")
  gdp_gw <- load_gdp_data(1990, 1992, coding_system = "gw")

  expect_named(
    gdp,
    c("cow", "year", "gdp_pcap", "log_gdp_pcap", "gdp_growth")
  )
  expect_true(all(gdp$year %in% 1990:1992))
  expect_false(anyDuplicated(gdp[c("cow", "year")]) > 0L)
  expect_equal(gdp$log_gdp_pcap, log(gdp$gdp_pcap))
  expect_named(
    gdp_gw,
    c("gw", "year", "gdp_pcap", "log_gdp_pcap", "gdp_growth")
  )
  expect_false(anyDuplicated(gdp_gw[c("gw", "year")]) > 0L)

  expect_error(load_gdp_data(2001, 2000), "less than or equal")
})

test_that("gapminder gdp_growth is computed against the true prior year", {
  gdp <- load_gdp_data(1990, 1992, coding_system = "cow", dataset = "gapminder")
  usa <- gdp[gdp$cow == 2, ] |> dplyr::arrange(year)

  full_range <- load_gdp_data(1989, 1992, coding_system = "cow", dataset = "gapminder")
  usa_full <- full_range[full_range$cow == 2, ] |> dplyr::arrange(year)
  expected_1990_growth <- (usa_full$gdp_pcap[usa_full$year == 1990] /
    usa_full$gdp_pcap[usa_full$year == 1989] - 1) * 100

  expect_equal(usa$gdp_growth[usa$year == 1990], expected_1990_growth)
})

test_that("Fariss GDP data are ranged, keyed, and combine level and per-capita", {
  gdp <- load_gdp_data(1990, 1992, dataset = "fariss", coding_system = "cow")
  gdp_gw <- load_gdp_data(1990, 1992, dataset = "fariss", coding_system = "gw")

  expect_named(gdp, c("cow", "year", "fariss_gdp", "fariss_gdppc"))
  expect_true(all(gdp$year %in% 1990:1992))
  expect_false(anyDuplicated(gdp[c("cow", "year")]) > 0L)
  expect_named(gdp_gw, c("gw", "year", "fariss_gdp", "fariss_gdppc"))
  expect_false(anyDuplicated(gdp_gw[c("gw", "year")]) > 0L)
})

test_that("population loaders return unique country-years for all three sources", {
  wpp <- load_population_data(1990, 1992, dataset = "wpp", coding_system = "cow")
  nmc <- load_population_data(1990, 1992, dataset = "nmc", coding_system = "cow")
  fariss <- load_population_data(1990, 1992, dataset = "fariss", coding_system = "gw")

  expect_named(wpp, c("cow", "year", "wpp_pop"))
  expect_false(anyDuplicated(wpp[c("cow", "year")]) > 0L)
  # China's wpp_pop is deduplicated (via median) from three source rows
  expect_equal(sum(wpp$cow == 710), length(1990:1992))

  expect_named(nmc, c("cow", "year", "nmc_tpop", "nmc_upop"))
  expect_false(anyDuplicated(nmc[c("cow", "year")]) > 0L)
  expect_false(any(nmc$nmc_tpop == -9, na.rm = TRUE))
  expect_false(any(nmc$nmc_upop == -9, na.rm = TRUE))

  expect_named(fariss, c("gw", "year", "fariss_pop"))
  expect_false(anyDuplicated(fariss[c("gw", "year")]) > 0L)

  expect_error(load_population_data(2001, 2000), "less than or equal")
})

test_that("military expenditure loaders return unique country-years for all three sources", {
  sipri <- load_military_expenditure_data(1990, 1992, dataset = "sipri", coding_system = "cow")
  nmc <- load_military_expenditure_data(1990, 1992, dataset = "nmc", coding_system = "cow")
  barnum <- load_military_expenditure_data(1990, 1992, dataset = "barnum", coding_system = "gw")

  expect_named(sipri, c("cow", "year", "sipri_milex", "sipri_milburden"))
  expect_false(anyDuplicated(sipri[c("cow", "year")]) > 0L)

  expect_named(nmc, c("cow", "year", "nmc_milex"))
  expect_false(anyDuplicated(nmc[c("cow", "year")]) > 0L)

  expect_named(barnum, c("gw", "year", "barnum_milburden", "barnum_sipri", "barnum_nmc"))
  expect_false(anyDuplicated(barnum[c("gw", "year")]) > 0L)

  expect_error(load_military_expenditure_data(2001, 2000), "less than or equal")
})

test_that("leader loaders return unique country-years", {
  archigos <- load_leader_data(1990, 1992, "archigos", "cow")
  archigos_gw <- load_leader_data(1990, 1992, "archigos", "gw")
  reign_cow <- load_leader_data(1990, 1992, "reign", "cow")
  reign <- load_leader_data(1990, 1992, "reign", "gw")

  expect_named(
    archigos,
    c(
      "cow", "year", "leader", "entry", "exit", "irregular_entry",
      "irregular_exit", "female_leader", "yrborn", "posttenurefate",
      "leader_tenure"
    )
  )
  expect_named(
    reign,
    c(
      "gw", "year", "leader", "female_leader", "military_bg",
      "birthyear", "leader_tenure"
    )
  )
  expect_false(anyDuplicated(archigos[c("cow", "year")]) > 0L)
  expect_false(anyDuplicated(archigos_gw[c("gw", "year")]) > 0L)
  expect_false(anyDuplicated(reign_cow[c("cow", "year")]) > 0L)
  expect_false(anyDuplicated(reign[c("gw", "year")]) > 0L)
  expect_true(all(archigos$leader_tenure >= 1L))
  expect_true(all(reign$leader_tenure >= 1L))
})

test_that("V-Dem loader validates and subsets variables", {
  skip_if_not_installed("vdemdata")

  vdem <- load_vdem_data("v2x_polyarchy", 2000, 2001, "cow")
  vdem_gw <- load_vdem_data("v2x_polyarchy", 2000, 2001, "gw")

  expect_named(vdem, c("cow", "year", "v2x_polyarchy"))
  expect_true(all(vdem$year %in% 2000:2001))
  expect_false(anyDuplicated(vdem[c("cow", "year")]) > 0L)
  expect_named(vdem_gw, c("gw", "year", "v2x_polyarchy"))
  expect_false(anyDuplicated(vdem_gw[c("gw", "year")]) > 0L)
  expect_error(load_vdem_data("not_a_vdem_variable"), "not found")
})
