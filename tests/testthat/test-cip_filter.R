# run from devtools::test() only
context("test-cip_filter")

# create test cases
case_engr <- cip_filter(cip, keep_any = cip_engr)
chem_engr <- cip_filter(cip, keep_any = "^1407")

test_that("data argument NULL", {
  expect_equal(cip_filter(data = NULL), cip_filter(data = cip))
  expect_equal(cip_filter(keep_any = cip_engr), cip_filter(keep_any = "^14"))
})

test_that("cip_filter() gives meaningful errors", {
  expect_error(cip_filter(cip_engr), "midfieldr::cip_filter, first argument must be a data.frame or tbl.")
  expect_error(cip_filter(case_engr, keep_any = case_engr), "midfieldr::cip_filter, keep_any argument must be a character vector.")
  expect_error(cip_filter(case_engr, keep_any = "^1410", drop_any = case_engr), "midfieldr::cip_filter, drop_any argument must be a character vector.")
})

test_that("Numeric terms are coverted to strings", {
  expect_equal(
    cip_filter(cip, keep_any = 140801),
    cip_filter(cip, keep_any = "140801")
  )
})

test_that("Invalid series are quietly ignored", {
  expect_equal(
    cip_filter(cip, keep_any = seq(140800, 140899)),
    cip_filter(cip, keep_any = "^1408")
  )
})

test_that("drop_any() yields expected result", {
  expect_equal(
    chem_engr[c(1, 3), ],
    cip_filter(chem_engr, keep_any = "14", drop_any = "Bio")
  )
})
