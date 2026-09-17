test_that("cn_cite finds a single-source entry by keyword and prints BibTeX", {
  expect_output(result <- cn_cite("archigos"), "@Article\\{goemansIntroducingArchigosDataset2009")
  expect_s3_class(result, "bibentry")
  expect_length(result, 1L)
})

test_that("cn_cite matches multiple entries sharing a keyword", {
  expect_output(result <- cn_cite("add_conflict()"))
  expect_gt(length(result), 1L)
})

test_that("cn_cite looks up by bibtexkey", {
  expect_output(
    result <- cn_cite("bellRulersElectionsIrregular2021", column = "bibtexkey")
  )
  expect_length(result, 1L)
})

test_that("cn_cite errors informatively when nothing matches", {
  expect_error(cn_cite("not_a_real_keyword"), "No bundled citation matches")
})
