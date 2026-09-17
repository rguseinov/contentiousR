test_that("build_states_panel returns a data frame", {
  panel <- build_states_panel(1990, 1995)
  expect_s3_class(panel, "data.frame")
  expect_true(all(c("cow", "year", "country") %in% names(panel)))
})

test_that("build_states_panel returns unique cow-year observations", {
  panel <- build_states_panel(1990, 1995)
  dupes <- panel |>
    dplyr::count(cow, year) |>
    dplyr::filter(n > 1)
  expect_equal(nrow(dupes), 0)
})

test_that("build_states_panel validates years", {
  expect_error(
    build_states_panel(2000, 1990),
    "`start_year` must be less than or equal to `end_year`"
  )
  expect_error(build_states_panel(2000.5, 2001), "whole year")
  expect_error(build_states_panel(2000, Inf), "finite whole year")
  expect_error(build_states_panel(NA_real_, 2001), "finite whole year")
})

test_that("optional exclusions reduce or preserve the state universe", {
  full <- build_states_panel(
    2000, 2001,
    exclude_microstates = FALSE,
    exclude_non_un = FALSE,
    exclude_islands = FALSE
  )
  restricted <- build_states_panel(
    2000, 2001,
    exclude_microstates = TRUE,
    exclude_non_un = TRUE,
    exclude_islands = TRUE
  )

  expect_lte(nrow(restricted), nrow(full))
})

test_that("build_states_panel supports both coding systems", {
  cow_panel <- build_states_panel(1990, 1991, coding_system = "cow")
  gw_panel <- build_states_panel(1990, 1991, coding_system = "gw")

  expect_named(cow_panel, c("cow", "year", "country"))
  expect_named(gw_panel, c("gw", "year", "country"))
  expect_true(all(cow_panel$year %in% 1990:1991))
  expect_true(all(gw_panel$year %in% 1990:1991))
})

test_that("panel filters must be logical flags", {
  expect_error(
    build_states_panel(exclude_microstates = NA),
    "`exclude_microstates` must be `TRUE` or `FALSE`"
  )
  expect_error(
    build_states_panel(exclude_non_un = 1),
    "`exclude_non_un` must be `TRUE` or `FALSE`"
  )
})

test_that("the internal COW panel builder matches the public dispatcher", {
  expect_identical(
    build_states_cow_panel(1990, 1991),
    build_states_panel(1990, 1991, coding_system = "cow")
  )
})
