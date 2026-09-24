test_that("adapter adds peacesciencer metadata without changing rows", {
  cow <- build_states_panel(1990, 1991, "cow")
  gw <- build_states_panel(1990, 1991, "gw")

  cow_compatible <- as_peacesciencer_panel(cow)
  gw_compatible <- as_peacesciencer_panel(gw)

  expect_equal(nrow(cow_compatible), nrow(cow))
  expect_equal(cow_compatible$ccode, cow_compatible$cow)
  expect_equal(attr(cow_compatible, "ps_system"), "cow")
  expect_equal(attr(cow_compatible, "ps_data_type"), "state_year")

  expect_equal(nrow(gw_compatible), nrow(gw))
  expect_equal(gw_compatible$gwcode, gw_compatible$gw)
  expect_equal(attr(gw_compatible, "ps_system"), "gw")
  expect_equal(attr(gw_compatible, "ps_data_type"), "state_year")
})

test_that("adapter rejects a conflicting peacesciencer key", {
  panel <- build_states_panel(1990, 1991, "cow")
  panel$ccode <- panel$cow + 1L

  expect_error(as_peacesciencer_panel(panel), "do not match")
})

test_that("wrapper hides temporary peacesciencer keys and metadata", {
  fake_adder <- function(data, value) {
    expect_equal(attr(data, "ps_data_type"), "state_year")
    data$external_value <- value
    data
  }

  cow <- build_states_panel(1990, 1991, "cow")
  gw <- build_states_panel(1990, 1991, "gw")

  cow_result <- add_from_peacesciencer(cow, fake_adder, value = 7L)
  gw_result <- add_from_peacesciencer(gw, fake_adder, value = 8L)

  expect_equal(cow_result$cow, cow$cow)
  expect_false("ccode" %in% names(cow_result))
  expect_null(attr(cow_result, "ps_system"))
  expect_null(attr(cow_result, "ps_data_type"))
  expect_true(all(cow_result$external_value == 7L))

  expect_equal(gw_result$gw, gw$gw)
  expect_false("gwcode" %in% names(gw_result))
  expect_null(attr(gw_result, "ps_system"))
  expect_null(attr(gw_result, "ps_data_type"))
  expect_true(all(gw_result$external_value == 8L))
})

test_that("wrapper preserves compatibility fields that existed on input", {
  panel <- build_states_panel(1990, 1991, "cow")
  panel$ccode <- panel$cow
  attr(panel, "ps_system") <- "existing-system"
  attr(panel, "ps_data_type") <- "existing-type"

  result <- add_from_peacesciencer(panel, identity)

  expect_equal(result$ccode, panel$ccode)
  expect_equal(attr(result, "ps_system"), "existing-system")
  expect_equal(attr(result, "ps_data_type"), "existing-type")
})

test_that("wrapper validates the supplied function and its result", {
  panel <- build_states_panel(1990, 1991, "cow")

  expect_error(
    add_from_peacesciencer(panel, "add_archigos"),
    "must be a function"
  )
  expect_error(
    add_from_peacesciencer(panel, function(data) 1L),
    "must return a data frame"
  )

  expect_error(
    add_from_peacesciencer(panel, function(data) {
      data$cow <- NULL
      data$ccode <- NULL
      data
    }),
    "removed both"
  )

  expect_error(
    add_from_peacesciencer(panel, function(data) {
      data$ccode <- data$ccode + 1L
      data
    }),
    "no longer matches"
  )
})

test_that("wrapper restores the contentiousR key if the adder drops it", {
  panel <- build_states_panel(1990, 1991, "cow")

  result <- add_from_peacesciencer(panel, function(data) {
    data$cow <- NULL
    data
  })

  expect_equal(result$cow, panel$cow)
  expect_false("ccode" %in% names(result))
})

test_that("peacesciencer add_archigos accepts an adapted pipeline", {
  skip_if_not_installed("peacesciencer", minimum_version = "1.2.0")

  was_attached <- "package:peacesciencer" %in% search()
  if (!was_attached) {
    suppressPackageStartupMessages(
      library("peacesciencer", character.only = TRUE)
    )
    on.exit(detach("package:peacesciencer"), add = TRUE)
  }

  panel <- build_states_panel(1990, 1991, "cow") |>
    add_gdp() |>
    as_peacesciencer_panel()

  result <- peacesciencer::add_archigos(panel)

  expect_equal(nrow(result), nrow(panel))
  expect_true(all(c(
    "leadertransition", "irregular", "n_leaders", "jan1obsid", "dec31obsid"
  ) %in% names(result)))
})

test_that("wrapper adds Archigos data and restores the COW schema", {
  skip_if_not_installed("peacesciencer", minimum_version = "1.2.0")

  was_attached <- "package:peacesciencer" %in% search()
  if (!was_attached) {
    suppressPackageStartupMessages(
      library("peacesciencer", character.only = TRUE)
    )
    on.exit(detach("package:peacesciencer"), add = TRUE)
  }

  panel <- build_states_panel(1990, 1991, "cow") |> add_gdp()
  result <- add_from_peacesciencer(panel, peacesciencer::add_archigos)

  expect_equal(nrow(result), nrow(panel))
  expect_equal(result$cow, panel$cow)
  expect_false("ccode" %in% names(result))
  expect_null(attr(result, "ps_system"))
  expect_null(attr(result, "ps_data_type"))
  expect_true(all(c(
    "leadertransition", "irregular", "n_leaders", "jan1obsid", "dec31obsid"
  ) %in% names(result)))
})
