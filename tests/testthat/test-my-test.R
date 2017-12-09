context("test-my-test.R")

test_that("CIP filters operating correctly", {
	expect_equal(filter_cip(series = "14")$PROGRAM, "Engineering")
	expect_error(filter_cip(series = "88"), "Check that the series exists")
})
