context("gather_grad")

library(dplyr)

.data <- cip_filter(series = "540104") %>%
  cip_label() %>%
  gather_grad()

test_that("gather_grad produces correct output", {
  expect_equal(unique(.data[["cip6"]]), "540104")
  expect_equal(dim(.data), c(24, 3))
})

test_that("Error if argument not a data frame", {
  x <- runif(10)
  expect_error(gather_grad(x), "midfieldr::gather_grad() argument must be a data frame or tbl", fixed = TRUE)
})

test_that("Error required variables missing from data frame", {
  no_cip6 <- select(.data, id, program)
  expect_error(
    gather_grad(no_cip6),
    "midfieldr::gather_grad() data frame must include a `cip6` variable",
    fixed = TRUE
  )
  no_program <- select(.data, id, cip6)
  expect_error(
    gather_grad(no_program),
    "midfieldr::gather_grad() data frame must include a `program` variable",
    fixed = TRUE
  )
})
