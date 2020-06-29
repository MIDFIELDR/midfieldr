context("cip6_select")
library("midfieldr")

ece <- cip_filter(cip, keep_any = "^1410")

test_that("Pipe correctly passes the data argument", {
  expect_equal(ece %>% cip6_select(program = "ECE"),
               cip6_select(ece, program = "ECE"))
})

test_that("Data argument present and in correct form", {
  expect_error(cip6_select(data = NULL, program = "ECE"),
               paste("cip6_select. Explicit data argument required",
                     "unless passed by a pipe.")
  )
  expect_error(cip6_select(data = "ECE", program = "ECE"),
               "cip6_select. Data argument must be a data frame or tbl."
  )
  expect_error(cip6_select(data = TRUE, program = "ECE"),
               "cip6_select. Data argument must be a data frame or tbl."
  )
})

test_that("Variables in data have correct names and class", {
  alt    <- ece
  alt[1] <- FALSE
  expect_error(
    cip6_select(alt),
    "cip6_select. Variables in data must be character class only.")
  alt <- ece
  names(alt)[1] <- "code2"
  expect_error(
    cip6_select(alt),
    "cip6_select. Variable names in data must match names in cip."
  )
})

test_that("Error if program argument is not a scalar character only", {
  expect_error(cip6_select(ece, program = c("ECE", "CVE")),
               "Argument program must a scalar character or NULL.")
  expect_error(cip6_select(ece, program = TRUE),
               "Argument program must a scalar character or NULL.")
})

test_that("Options for the program argument produce expected results", {
  expect_equal(cip6_select(ece, program = "cip2name"),
               cip6_select(ece, program = "Engineering"))
  expect_equal(cip6_select(ece, program = "cip4name"),
               cip6_select(ece, program = NULL))
  expect_equal(cip6_select(ece, program = "cip6name")["cip6name"],
               ece["cip6name"])
})



