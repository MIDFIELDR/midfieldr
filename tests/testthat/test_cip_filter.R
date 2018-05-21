library(midfieldr)
library(testthat)
context("cip_filter")

# create some test data frames
case_cip2 <- cip_filter(series = NULL, data = NULL)
case_engr <- cip_filter("^14")
case_elec <- cip_filter(data = case_engr, series = "Electrical")

test_that("With no arguments, default is level 2, no duplicates", {
	expect_equal_to_reference(case_cip2, "default_cip.rds")
	expect_false(unique(duplicated(case_cip2[["CIP2"]])))
})

test_that("With data argument and NULL series, one row returned", {
	expect_equal(nrow(cip_filter(data = case_engr, series = NULL)), 1)
})

test_that("With both arguments, result is a subset of the original", {
	for (jj in seq_along(case_elec$CIP6name)){
		expect_true(unlist(case_elec[["CIP6name"]][jj]) %in%
									unlist(case_engr[["CIP6name"]]))
	}
})

test_that("CIP2, CIP4, and CIP6 are variables (column names)", {
	expect_true("CIP2" %in% names(case_engr))
	expect_true("CIP4" %in% names(case_engr))
	expect_true("CIP6" %in% names(case_engr))
})

test_that("Search returns an appropriate CIP", {
	expect_true("Engineering" %in%
								unlist(unique(cip_filter(series = c("Civil", "civil"))[["CIP2name"]])))
	expect_true("Engineering" %in%
								unlist(unique(cip_filter(series = c("^14"))[["CIP2name"]])))
	expect_true("Civil Engineering" %in%
								unlist(unique(cip_filter(series = c("^1408"))[["CIP4name"]])))
	expect_true("German Language and Literature" %in%
								unlist(unique(cip_filter(series = c("160501"))[["CIP6name"]])))
})

test_that("Invalid codes are quietly ignored", {
	expect_equal(nrow(cip_filter(540109)), 0)
})

test_that("CIP data dimensions equal to reference", {
	expect_equal_to_reference(dim(case_cip2), "dim_cip_data.rds")
})
