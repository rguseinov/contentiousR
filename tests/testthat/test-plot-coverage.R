test_that("plot_coverage returns a ggplot and validates its inputs", {
  skip_if_not_installed("ggplot2")

  panel <- build_states_panel(1990, 2000, coding_system = "cow") |>
    add_conflict("ucdp_prio")

  p <- plot_coverage(panel, "ucdp_prio_onset")
  expect_s3_class(p, "ggplot")

  expect_error(plot_coverage(panel, "nonexistent"), "not found")
  expect_error(
    plot_coverage(panel, "ucdp_prio_onset", drop_empty = NA),
    "`drop_empty` must be `TRUE` or `FALSE`"
  )
  expect_error(
    plot_coverage(panel, "ucdp_prio_intensity_max"),
    "must be binary"
  )
})

test_that("plot_coverage colors 1 as Event, 0 as No event, and leaves NA blank", {
  skip_if_not_installed("ggplot2")

  # South Sudan-style case: no rows at all before independence, which must
  # be visually indistinguishable from a genuine NA (both stay unfilled).
  panel <- data.frame(
    cow     = c(2, 2, 2, 626, 626),
    country = c("USA", "USA", "USA", "South Sudan", "South Sudan"),
    year    = c(2009, 2010, 2011, 2010, 2011),
    x       = c(1, NA, 0, NA, 1)
  )

  p <- plot_coverage(panel, "x", drop_empty = FALSE)
  d <- p$data

  expect_equal(as.character(d$status[d$label == "USA" & d$year == 2009]), "Event")
  expect_true(is.na(d$status[d$label == "USA" & d$year == 2010]))
  expect_equal(as.character(d$status[d$label == "USA" & d$year == 2011]), "No event")
  expect_true(is.na(d$status[d$label == "South Sudan" & d$year == 2009]))
  expect_equal(
    as.character(d$status[d$label == "South Sudan" & d$year == 2011]), "Event"
  )
})

test_that("plot_coverage's drop_empty argument drops states with zero events", {
  skip_if_not_installed("ggplot2")

  panel <- data.frame(
    cow     = rep(c(1, 2), each = 3),
    country = rep(c("A", "B"), each = 3),
    year    = rep(2000:2002, 2),
    x       = c(1, 0, 1, 0, 0, NA)
  )

  dropped <- plot_coverage(panel, "x", drop_empty = TRUE)
  kept    <- plot_coverage(panel, "x", drop_empty = FALSE)

  expect_equal(nlevels(dropped$data$label), 1L)
  expect_equal(nlevels(kept$data$label), 2L)
})

test_that("plot_coverage uses cow/gw as the label when no country column is present", {
  skip_if_not_installed("ggplot2")

  panel <- data.frame(gw = rep(2, 3), year = 2000:2002, x = c(1, 0, 1))
  p <- plot_coverage(panel, "x")

  expect_equal(levels(p$data$label), "2")
})

test_that("show_labels controls whether row labels are drawn", {
  skip_if_not_installed("ggplot2")

  panel <- data.frame(
    cow     = rep(c(2, 20), each = 3),
    country = rep(c("A", "B"), each = 3),
    year    = rep(2000:2002, 2),
    x       = c(1, 0, 1, 1, 0, 1)
  )

  with_labels <- plot_coverage(panel, "x", show_labels = TRUE)
  no_labels   <- plot_coverage(panel, "x", show_labels = FALSE)

  get_axis_text_y <- function(p) p$theme$axis.text.y

  expect_false(inherits(get_axis_text_y(with_labels), "element_blank"))
  expect_true(inherits(get_axis_text_y(no_labels), "element_blank"))

  expect_error(
    plot_coverage(panel, "x", show_labels = NA),
    "`show_labels` must be `TRUE` or `FALSE`"
  )
})
