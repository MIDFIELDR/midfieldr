context("gather_ever")

library(dplyr)

d <- cip_filter(series = "540104") %>%
	cip_label() %>%
	gather_ever()

test_that("gather_ever produces correct output", {
	expect_equal(unique(d[["cip6"]]), "540104")
	expect_equal(dim(d), c(41, 3))
})

test_that("Error if argument not a data frame", {
	x <- runif(10)
	expect_error(
		gather_ever(x),
		"midfieldr::gather_ever() argument must be a data frame or tbl",
		fixed = TRUE)
})

test_that("Error required variables missing from data frame", {
	id <- select(d, id, program)
	expect_error(
		gather_ever(id),
		"midfieldr::gather_ever() data frame must include a `cip6` variable",
		fixed = TRUE
	)
	id <- select(d, id, cip6)
	expect_error(
		gather_ever(id),
		"midfieldr::gather_ever() data frame must include a `program` variable",
		fixed = TRUE
	)

})
