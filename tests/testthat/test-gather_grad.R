context("gather_grad")

library(dplyr)
library(tidyr)

grad1 <- gather_grad(series = "540104")
cip6 <- grad1["cip6"]
grad2 <- gather_grad(series = "14YYYY")
grad3 <- gather_grad(series = "^52", reference = subset_degrees)


test_that("Produces expected output", {
  expect_setequal(grad1[["cip6"]], "540104")
  expect_equal(dim(grad1), c(24, 2))
  expect_equal(dim(grad2), c(0, 2))
})

test_that("Error if incorrect series argument", {
  expect_error(
    gather_grad(series = NULL),
    "midfieldr::gather_grad, series missing or incorrectly specified",
    fixed = TRUE
  )
  expect_error(
    gather_grad(series = cip6),
    "midfieldr::gather_grad, series must be an atomic variable",
    fixed = TRUE
  )
})

test_that("Optional data argument returns correct values", {
  expect_setequal(
  	grad3[["cip6"]],
  	c("520301", "520201", "520101", "520801", "521099")
  	)
  expect_equal(dim(grad3), c(12, 2))
})
