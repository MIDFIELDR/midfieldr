context("ever_filter")

library("dplyr")
library("midfieldr")

ever1 <- ever_filter(codes = "540104")
cip6 <- ever1["cip6"]
ever2 <- ever_filter(codes = "14YYYY")

# get_my_path() in tests/testthat/helper.R
load(file = get_my_path("subset_terms.rda"))

ever3 <- ever_filter(subset_terms, "520201")
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

test_that("Error if incorrect codes argument", {
  expect_error(
    ever_filter(),
    "midfieldr::ever_filter, codes cannot be NULL",
    fixed = TRUE
  )
  expect_error(
    ever_filter(codes = cip6),
    "midfieldr::ever_filter, codes must be an atomic variable",
    fixed = TRUE
  )
})

test_that("Optional reference argument returns correct values", {
  expect_setequal(ever3[["cip6"]], "520201")
  # expect_equal(dim(ever3), c(6, 2))
})

test_that("Input data frame can have different column names", {
  expect_equal(
    ever_filter(ref1, "030506")[["id"]],
    ever_filter(ref2, "030506", id = "altID", cip6 = "altCIP6")[["altID"]]
  )
  expect_equal(
    ever_filter(subset_terms, "030506")[["cip6"]],
    ever_filter(ref2, "030506", id = "altID", cip6 = "altCIP6")[["altCIP6"]]
  )
})
