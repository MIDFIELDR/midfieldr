context("gather_ever")

library(dplyr)

ever1 <- gather_ever(series = "540104")
cip6  <- ever1["cip6"]
ever2 <- gather_ever(series = "14YYYY")

set.seed(20180628)
terms_subset <- dplyr::sample_n(midfielddata::midfieldterms, 10)
unique(terms_subset$cip6)
ever3 <- gather_ever(terms_subset, series = "520201")
ever3

test_that("Produces expected output", {
  expect_setequal(ever1[["cip6"]], "540104")
  expect_setequal(ever2[["cip6"]], "14YYYY")
  expect_equal(dim(ever1), c(41, 2))
  expect_equal(dim(ever2), c(659, 2))
})

test_that("Error if incorrect series argument", {
  expect_error(
    gather_ever(series = NULL),
    "midfieldr::gather_ever, series missing or incorrectly specified",
    fixed = TRUE
  )
	expect_error(
		gather_ever(series = cip6),
		"midfieldr::gather_ever, series must be an atomic variable",
		fixed = TRUE
	)
})

test_that("Optional .data argument returns correct values", {
	expect_setequal(ever3[["cip6"]], "520201")
	expect_equal(dim(ever3), c(3, 2))
})
