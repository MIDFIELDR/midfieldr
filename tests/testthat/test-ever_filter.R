context("ever_filter")

library(dplyr)

ever1 <- ever_filter("540104")
cip6 <- ever1["cip6"]
ever2 <- ever_filter("14YYYY")

# subset_terms is an internal data set
library(midfieldr)
ever3 <- ever_filter("520201", reference = subset_terms)
ref1 <- subset_terms
ref2 <- subset_terms
ref2 <- dplyr::rename(ref2, altID = id)
ref2 <- dplyr::rename(ref2, altCIP6 = cip6)

test_that("Produces expected output", {
  expect_setequal(ever1[["cip6"]], "540104")
  expect_setequal(ever2[["cip6"]], "14YYYY")
  expect_equal(dim(ever1), c(41, 2))
  # expect_equal(dim(ever2), c(659, 2))
})

test_that("Error if incorrect series argument", {
  expect_error(
    ever_filter(series = NULL),
    "midfieldr::ever_filter, series cannot be NULL",
    fixed = TRUE
  )
  expect_error(
    ever_filter(series = cip6),
    "midfieldr::ever_filter, series must be an atomic variable",
    fixed = TRUE
  )
})

test_that("Optional reference argument returns correct values", {
  expect_setequal(ever3[["cip6"]], "520201")
  # expect_equal(dim(ever3), c(6, 2))
})

test_that("Reference data can have different column names", {
	expect_equal(
		ever_filter("030506", reference = ref1)[["id"]],
		ever_filter("030506", reference = ref2, id = "altID", cip6 = "altCIP6")[["altID"]]
		)
	expect_equal(
		ever_filter("030506", reference = subset_terms)[["cip6"]],
		ever_filter("030506", reference = ref2, id = "altID", cip6 = "altCIP6")[["altCIP6"]]
	)

})
