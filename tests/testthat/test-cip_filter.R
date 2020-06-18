# run from devtools::test() only
context("test-cip_filter")

# create test case
case_engr <- cip_filter(cip, keep_any = cip_engr)

# test_that(".data argument NULL", {
#   expect_equal(cip_filter(reference = NULL), cip_filter(reference = cip))
#   expect_equal(cip_filter(series = cip_engr), cip_filter(series = "^14"))
# })
#
# test_that("NULL arguments returns full CIP", {
#   expect_equal(cip, cip_filter(series = NULL, reference = NULL))
# })
#
# test_that("NULL series returns unaltered data", {
#   expect_equal(
#     cip_filter(series = cip_engr),
#     cip_filter(series = NULL, reference = case_engr)
#   )
# })

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
