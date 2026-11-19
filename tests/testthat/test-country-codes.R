covered <- function(panel, var, code_col, code) {
  values <- panel[[var]][panel[[code_col]] == code]
  sum(!is.na(values))
}

test_that("GW panels include states countrycode cannot name", {
  gw <- build_states_panel(1950, 2010, "gw")
  expect_equal(sum(gw$gw == 816L), length(1954:2010))
  expect_equal(unique(gw$country[gw$gw == 816L]), "Vietnam")
  expect_true(all(c(396L, 397L) %in%
    build_states_panel(2010, 2010, "gw", exclude_microstates = FALSE,
                       exclude_non_un = FALSE)$gw))
  expect_false(any(c(396L, 397L) %in%
    build_states_panel(2010, 2010, "gw", exclude_microstates = FALSE)$gw))
})

test_that("COW and GW codes are converted by year", {
  conv <- contentiousR:::convert_state_code
  expect_equal(conv(c(255, 255, 260), c(1900, 1995, 1970), "cow", "gw"),
               c(255L, 260L, 260L))
  expect_equal(conv(c(345, 345, 345), c(1900, 1990, 2010), "cow", "gw"),
               c(340L, 345L, 340L))
  expect_equal(conv(c(345, 345), 2006, "cow", "gw", month = c(3, 8)), c(345L, 340L))
  expect_equal(conv(c(679, 678, 816, 955), c(2000, 1980, 2000, 2000), "cow", "gw"),
               c(678L, 678L, 816L, 972L))
  expect_equal(conv(c(678, 678, 816, 340, 260, 315), c(1980, 2000, 2000, 2010, 1970, 1980),
                    "gw", "cow"),
               c(678L, 679L, 816L, 345L, 255L, 316L))
})

test_that("GW-coded sources fill COW panels for Germany, Yemen, Vietnam, Serbia", {
  recent <- build_states_panel(1946, 2019, "cow") |> add_gdp("fariss")
  # Unified Yemen from 1991 (in 1990, GW 678 is the Yemen Arab Republic)
  expect_equal(covered(recent, "fariss_gdp", "cow", 679L), length(1991:2019))
  expect_equal(covered(recent, "fariss_gdp", "cow", 816L), length(1954:2019))
  expect_equal(covered(recent, "fariss_gdp", "cow", 345L), length(1946:2019))
  early <- build_states_panel(1880, 1945, "cow") |> add_population("fariss")
  expect_gt(covered(early, "fariss_pop", "cow", 255L), 60L)

  ucdp <- conflict_data(1994, 2025, "ucdp_prio", "cow")
  expect_true(any(ucdp$cow == 679L))
  expect_false(any(ucdp$cow == 678L))
})

test_that("COW-coded sources fill GW panels for Yemen and Serbia", {
  gw <- build_states_panel(1991, 2019, "gw") |>
    add_population("nmc") |>
    add_gdp() |>
    add_military_expenditure("sipri")
  expect_equal(covered(gw, "nmc_tpop", "gw", 678L), length(1991:2019))
  expect_equal(covered(gw, "gdp_pcap", "gw", 678L), length(1991:2019))
  expect_gt(covered(gw, "nmc_tpop", "gw", 340L), 10L)
  expect_gt(covered(gw, "gdp_pcap", "gw", 345L), 10L)
})

test_that("COW panels match COW sources for West Germany and Czechoslovakia", {
  panel <- build_states_panel(1960, 1989, "cow") |> add_population("nmc")
  expect_equal(covered(panel, "nmc_tpop", "cow", 255L), 30L)
  expect_equal(covered(panel, "nmc_tpop", "cow", 316L), 30L)
  leaders <- build_states_panel(1960, 1989, "cow") |> add_leader_data()
  expect_equal(covered(leaders, "leader", "cow", 255L), 30L)
})

test_that("Mass Mobilization's own codes are mapped to COW", {
  mm <- conflict_data(2008, 2020, "mm", "cow")
  # MM codes Kosovo as 341 (COW Montenegro) and Montenegro as 348.
  expect_true(any(mm$cow == 347L))
  expect_true(any(mm$cow == 341L))
  expect_true(any(mm$cow == 626L))
  expect_false(any(mm$cow %in% c(342L, 348L, 525L, 529L)))
})

test_that("peacesciencer gets standard COW codes", {
  panel <- build_states_panel(1980, 1995, "cow")
  ps <- as_peacesciencer_panel(panel)
  expect_true(all(ps$ccode[ps$cow == 255L & ps$year <= 1989L] == 260L))
  expect_true(all(ps$ccode[ps$cow == 316L & ps$year <= 1992L] == 315L))
  restored <- add_from_peacesciencer(panel, identity)
  expect_equal(restored$cow, panel$cow)
  expect_false("ccode" %in% names(restored))
})

test_that("harmonize_conflict_data() handles keys and year-specific codes", {
  panel <- build_states_panel(2015, 2018, "cow")
  data <- data.frame(country = "Mali", year = 2016, val = 1)
  out <- harmonize_conflict_data(panel, data, "country", "country.name", "x",
                                 year_col = "year", aggregate = FALSE)
  expect_equal(out$x_val[out$cow == 432L & out$year == 2016L], 1)

  events <- data.frame(country = c("Serbia", "Yemen"), year = 2016)
  cow <- harmonize_conflict_data(panel, events, "country", "country.name",
                                 "acled", year_col = "year")
  expect_equal(cow$acled_n_events[cow$cow %in% c(345L, 679L) & cow$year == 2016L],
               c(1L, 1L))
  gw <- harmonize_conflict_data(build_states_panel(2015, 2018, "gw"), events,
                                "country", "country.name", "acled",
                                year_col = "year")
  expect_equal(gw$acled_n_events[gw$gw %in% c(340L, 678L) & gw$year == 2016L],
               c(1L, 1L))
})

test_that("add_regions() covers Serbia, Yemen, and Vietnam", {
  cow <- add_regions(build_states_panel(2010, 2010, "cow"), "un.region.name")
  gw <- add_regions(build_states_panel(2010, 2010, "gw"), "un.region.name")
  expect_false(is.na(cow$un.region.name[cow$cow == 345L]))
  expect_false(any(is.na(gw$un.region.name[gw$gw %in% c(340L, 678L, 816L)])))
})

test_that("every dataset value has a citation", {
  for (d in unique(list_datasets()$dataset)) {
    expect_s3_class(cn_cite(d), "bibentry")
  }
})

test_that("WPP population follows the states of each year", {
  cow <- load_population_data(1949, 2023, "wpp", "cow")
  gw <- load_population_data(1949, 2023, "wpp", "gw")
  pop <- function(d, code_col, code, y) d$wpp_pop[d[[code_col]] == code & d$year == y]

  # States that split are the sum of their parts.
  expect_gt(pop(cow, "cow", 365L, 1980L), 2 * pop(cow, "cow", 365L, 1995L) * 0.85)
  expect_equal(pop(cow, "cow", 316L, 1980L), pop(gw, "gw", 315L, 1980L))
  # Pakistan includes East Pakistan (Bangladesh) until 1970.
  expect_gt(pop(cow, "cow", 770L, 1970L), pop(cow, "cow", 770L, 1972L) * 1.5)
  expect_equal(pop(cow, "cow", 365L, 1980L), pop(gw, "gw", 365L, 1980L))
  # Serbia: with Montenegro and Kosovo until they became states.
  expect_gt(pop(cow, "cow", 345L, 2005L), pop(cow, "cow", 345L, 2008L))
  expect_equal(pop(gw, "gw", 345L, 2005L), pop(cow, "cow", 345L, 2005L))
  expect_equal(pop(gw, "gw", 340L, 2010L), pop(cow, "cow", 345L, 2010L))
  # Unified states: no data for their parts before unification.
  expect_length(pop(cow, "cow", 255L, 1980L), 0L)
  expect_length(pop(cow, "cow", 678L, 1980L), 0L)
  expect_length(pop(gw, "gw", 260L, 1980L), 0L)
  expect_gt(pop(cow, "cow", 255L, 1995L), 80000)
  expect_gt(pop(gw, "gw", 678L, 2000L), 15000)
  # One row per state-year, only for states in the system.
  expect_false(anyDuplicated(cow[c("cow", "year")]) > 0L)
  expect_length(pop(cow, "cow", 31L, 1960L), 0L)

  panel <- build_states_panel(1991, 2023, "gw") |> add_population("wpp")
  expect_false(anyNA(panel$wpp_pop))
})
