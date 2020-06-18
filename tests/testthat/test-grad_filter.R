context("grad_filter")

library(dplyr)
library(tidyr)

# get_my_path() in tests/testthat/helper.R
load(file = get_my_path("subset_degrees.rda"))

grad1 <- grad_filter(codes = "540104")
cip6  <- grad1["cip6"]
grad2 <- grad_filter(codes = "14YYYY")
grad3 <- grad_filter(subset_degrees, codes = "^52")

ref1 <- subset_degrees
ref2 <- subset_degrees
ref2 <- dplyr::rename(ref2, altID = id)
ref2 <- dplyr::rename(ref2, altCIP6 = cip6)

test_that("Produces expected output", {
  expect_setequal(grad1[["cip6"]], "540104")
  expect_equal(dim(grad1), c(24, 2))
  expect_equal(dim(grad2), c(0, 2))
})

test_that("Error if incorrect codes argument", {
  expect_error(
    grad_filter(codes = NULL),
    "midfieldr::grad_filter, codes cannot be NULL",
    fixed = TRUE
  )
  expect_error(
    grad_filter(codes = cip6),
    "midfieldr::grad_filter, codes must be an atomic variable",
    fixed = TRUE
  )
})

test_that("Optional data argument returns correct values", {
  expect_setequal(
    grad3[["cip6"]],
    c("520201", "520801", "520601", "521101", "520901", "520301", "521301")
  )
  # expect_equal(dim(grad3), c(12, 2))
})

test_that("Reference data can have different column names", {
  expect_equal(
    grad_filter(ref1, "030506")[["id"]],
    grad_filter(ref2, "030506", id = "altID", cip6 = "altCIP6")[["altID"]]
  )
  expect_equal(
    grad_filter(subset_degrees, "030506")[["cip6"]],
    grad_filter(ref2, "030506", id = "altID", cip6 = "altCIP6")[["altCIP6"]]
  )
})
