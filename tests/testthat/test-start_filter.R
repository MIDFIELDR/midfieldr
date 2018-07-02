context("start_filter")

library(dplyr)

x <- subset_students
x_cip6_col  <- x["cip6"]
x_cip6_atom <- x[["cip6"]]

ref1 <- subset_students
ref2 <- subset_students[ , 1:3]
ref3 <- unlist(ref1)[1:100]
ref4 <- rename(case_fye, mid = id, start = cip6)

test_that("Error if incorrect series argument", {

	expect_error(
		start_filter(series = NULL),
		"series cannot be NULL",
		fixed = TRUE
	)

	expect_error(
		start_filter(series = x_cip6_col),
		"series must be an atomic variable",
		fixed = TRUE
	)

})

test_that("error produced if ... incorrectly used", {

	expect_error(
		start_filter(x_cip6, x_cip6),
		"gather_ever unexpected arguments")

	})

test_that("reference produces expected results", {

	expect_equal(
		start_filter(series = x_cip6_atom, reference = ref1),
		start_filter(series = x_cip6_atom, reference = ref2)
		)

	expect_error(
		start_filter(x_cip6_atom, reference = ref3),
		"reference must be a data frame or tbl"
		)

	expect_named(
		start_filter(series = x_cip6_atom, reference = NULL),
		c("id", "cip6"),
		ignore.order = TRUE, ignore.case = FALSE
		)

})

test_that("alternate id and cip6 work", {

	expect_named(
		start_filter(series = "140201", reference = case_fye),
		expected = c("id", "cip6"),
		ignore.order = TRUE
	)

	expect_named(
		start_filter(
			series = "140201",
			reference = ref4,
			id = "mid",
			cip6 = "start"
		),
		expected = c("mid", "start"),
		ignore.order = TRUE
	)

	expect_error(
		start_filter(
			series = "140201",
			reference = ref4,
			cip6 = "start"
		),
		"use the id argument for non-default name"
	)

	expect_error(
		start_filter(
			series = "140201",
			reference = ref4,
			id = "mid"
		),
		"use the cip6 argument for non-default name"
	)

})
