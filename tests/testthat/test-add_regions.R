test_that("add_regions adds the World Bank region by default", {
  panel <- build_states_panel(1990, 1991, coding_system = "cow")
  out   <- add_regions(panel)

  expect_true("region" %in% names(out))
  expect_equal(nrow(out), nrow(panel))
  usa_region <- out$region[out$cow == 2][1]
  expect_equal(usa_region, "North America")
})

test_that("add_regions can add several classifications at once", {
  panel <- build_states_panel(1990, 1991, coding_system = "cow")
  out   <- add_regions(
    panel,
    region = c("region", "region23", "un.region.name", "un.regionsub.name")
  )

  expect_true(all(
    c("region", "region23", "un.region.name", "un.regionsub.name") %in% names(out)
  ))
})

test_that("add_regions validates its `region` argument", {
  panel <- build_states_panel(1990, 1991, coding_system = "cow")
  expect_error(add_regions(panel, region = "bogus"), "must be one or more of")
  expect_error(add_regions(panel, region = character(0)), "must be one or more of")
})

test_that("add_regions errors if a target column already exists", {
  panel <- build_states_panel(1990, 1991, coding_system = "cow") |> add_regions()
  expect_error(add_regions(panel, region = "region"), "already has column")
})

test_that("add_regions works with a gw-coded panel", {
  panel <- build_states_panel(1990, 1991, coding_system = "gw")
  out   <- add_regions(panel)
  expect_true("region" %in% names(out))
})
