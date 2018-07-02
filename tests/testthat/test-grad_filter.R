context("grad_filter")

library(dplyr)
library(tidyr)

grad1 <- grad_filter(series = "540104")
cip6 <- grad1["cip6"]
grad2 <- grad_filter(series = "14YYYY")
grad3 <- grad_filter(series = "^52", reference = subset_degrees)

ref1 <- subset_degrees
ref2 <- subset_degrees
ref2 <- dplyr::rename(ref2, altID = id)
ref2 <- dplyr::rename(ref2, altCIP6 = cip6)

test_that("Produces expected output", {
  expect_setequal(grad1[["cip6"]], "540104")
  expect_equal(dim(grad1), c(24, 2))
  expect_equal(dim(grad2), c(0, 2))
})

test_that("Error if incorrect series argument", {
  expect_error(
    grad_filter(series = NULL),
    "midfieldr::grad_filter, series missing or incorrectly specified",
    fixed = TRUE
  )
  expect_error(
    grad_filter(series = cip6),
    "midfieldr::grad_filter, series must be an atomic variable",
    fixed = TRUE
  )
})

test_that("Optional data argument returns correct values", {
  expect_setequal(
    grad3[["cip6"]],
    c("520301", "520201", "520101", "520801", "521099")
  )
  # expect_equal(dim(grad3), c(12, 2))
})

test_that("Reference data can have different column names", {
	expect_equal(
		grad_filter("030506", reference = ref1)[["id"]],
		grad_filter("030506", reference = ref2, id = "altID", cip6 = "altCIP6")[["altID"]]
	)
	expect_equal(
		grad_filter("030506", reference = subset_degrees)[["cip6"]],
		grad_filter("030506", reference = ref2, id = "altID", cip6 = "altCIP6")[["altCIP6"]]
	)

})
