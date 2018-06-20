# run from devtools::test() only
context("cip_filter")

# create test case
case_engr <- cip_filter(.data = cip, series = cip_engr)

test_that(".data argument NULL", {
  expect_equal(cip_filter(.data = NULL), cip_filter(.data = cip))
  expect_equal(cip_filter(series = cip_engr), cip_filter(series = "^14"))
})

test_that("CIP data dimensions equal to reference", {
  expect_known_value(
    dim(cip_filter()),
    file = "ref_dim_case_all.rds",
    update = TRUE
  )
})

test_that("NULL arguments returns full CIP", {
  expect_equal(cip, cip_filter(.data = NULL, series = NULL))
})

test_that("NULL series returns unaltered data", {
  expect_equal(
    cip_filter(.data = cip, series = cip_engr),
    cip_filter(.data = case_engr, series = NULL)
  )
})

test_that("regular data frame is converted to tibble", {
  expect_equal(
    cip_filter(.data = as.data.frame(case_engr)),
    cip_filter(.data = case_engr)
  )
})

test_that("Numeric terms are coverted to strings", {
  expect_equal(
    cip_filter(series = 140801),
    cip_filter(series = "140801")
  )
})

test_that("Invalid series are quietly ignored", {
  expect_equal(
    cip_filter(series = seq(140800, 140899)),
    cip_filter(series = "^1408")
  )
})
