context("ever_filter")
library("midfieldr")
library("midfielddata")

# get_my_path() internal function in tests/testthat/helper.R
# load(file = get_my_path("subset_students.rda"))
# load(file = get_my_path("subset_courses.rda"))
load(file = get_my_path("subset_terms.rda"))
# load(file = get_my_path("subset_degrees.rda"))

ever1 <- ever_filter(codes = "540104")
cip6 <- ever1["cip6"]
ever2 <- ever_filter(codes = "14YYYY")

ever3 <- ever_filter(subset_terms, "520201")
ref1 <- subset_terms
ref2 <- subset_terms
ref2 <- dplyr::rename(ref2, altID = id)
ref2 <- dplyr::rename(ref2, altCIP6 = cip6)

test_that("Data argument is a data frame or tbl", {
  expect_error(
    ever_filter(data = runif(10), codes = "540104"),
    "ever_filter data argument must be a data frame or tbl"
  )
})

test_that("Produces expected output", {
  expect_setequal(ever1[["cip6"]], "540104")
  expect_setequal(ever2[["cip6"]], "14YYYY")
  expect_equal(dim(ever1), c(41, 2))
  # expect_equal(dim(ever2), c(659, 2))
})

test_that("Default data set used when data is NULL", {
  expect_equal(
    ever_filter(data = NULL, "^99"),
    ever_filter(data = midfieldterms, "^99")
  )
})

test_that("Error if incorrect codes argument", {
  expect_error(
    ever_filter(),
    "ever_filter, codes cannot be NULL",
    fixed = TRUE
  )
  expect_error(
    ever_filter(codes = cip6),
    "ever_filter, codes must be an atomic variable",
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
