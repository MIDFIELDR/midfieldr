context("gather_ever")

library(dplyr)

ever1 <- gather_ever("540104")
cip6 <- ever1["cip6"]
ever2 <- gather_ever("14YYYY")

# subset_terms is an internal data set
library(midfieldr)
ever3 <- gather_ever("520201", reference = subset_terms)
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
    gather_ever(series = NULL),
    "midfieldr::gather_ever, series cannot be NULL",
    fixed = TRUE
  )
  expect_error(
    gather_ever(series = cip6),
    "midfieldr::gather_ever, series must be an atomic variable",
    fixed = TRUE
  )
})

test_that("Optional reference argument returns correct values", {
  expect_setequal(ever3[["cip6"]], "520201")
  # expect_equal(dim(ever3), c(6, 2))
})

test_that("Reference data can have different column names", {
	expect_equal(
		gather_ever("030506", reference = ref1)[["id"]],
		gather_ever("030506", reference = ref2, id = "altID", cip6 = "altCIP6")[["altID"]]
		)
	expect_equal(
		gather_ever("030506", reference = subset_terms)[["cip6"]],
		gather_ever("030506", reference = ref2, id = "altID", cip6 = "altCIP6")[["altCIP6"]]
	)

})
