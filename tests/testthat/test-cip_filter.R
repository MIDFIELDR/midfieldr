context("cip_filter")
library("midfieldr")

# create test cases
engr     <- cip_filter(cip, keep_any = "^14")
chem_ece <- cip_filter(engr, keep_any = c("^1407", "^1410"))
ece      <- cip_filter(chem_ece, drop_any = "Chemical")

test_that("Function works as expected", {
  expect_equal(c("1407", "1410"), unique(chem_ece[["cip4"]]))
  expect_equal("1410", unique(ece[["cip4"]]))
  expect_equal(cip, cip_filter())
  expect_equal(cip_filter(engr, keep_any = "tech"),
               cip_filter(engr, "tech"))
  expect_equal(engr %>% cip_filter("tech"),
               cip_filter(engr, "tech"))
  expect_equal(dim(cip_filter(as.data.frame(engr), "tech")),
               dim(cip_filter(engr, "tech")))
})

test_that("Data argument correct when NULL", {
  expect_equal(cip_filter(data = NULL), cip_filter(data = cip))
})

test_that("Problems with data argument produce errors", {
  expect_error(
    cip_filter(c("^1407", "^1410")),
    "cip_filter. Explicit data argument required unless passed by a pipe."
  )
  alt    <- ece
  alt[1] <- FALSE
  expect_error(cip_filter(alt, keep_any = "electrical"),
               "cip_filter. Variables in data must be character class only.")
  alt <- ece
  names(alt)[1] <- "code2"
  expect_error(
    cip_filter(alt),
    "cip_filter. Variable names in data must match names in cip."
  )
  expect_error(
    cip_filter(data = TRUE),
    paste("cip_filter. Explicit data argument required",
          "unless passed by a pipe.")
  )
  expect_error(
    cip_filter(data = NA),
    paste("cip_filter. Explicit data argument required",
          "unless passed by a pipe.")
  )
})

test_that("Problems with arguments of wrong class", {
  expect_error(
    cip_filter(engr, "engineering", drop_any = TRUE),
    "cip_filter. Argument drop_any must be an atomic character vector."
  )
  expect_error(
    cip_filter(engr, keep_any = TRUE),
    "cip_filter. Argument keep_any must be an atomic character vector."
  )
})

test_that("Problems with keep_any arguments produce errors", {
  expect_error(
    cip_filter(engr, keep_any = "111111"),
    "cip_filter. No programs satisfy the filter criteria."
  )
  expect_error(
    cip_filter(engr, keep_any = "arctic explorer"),
    "cip_filter. No programs satisfy the filter criteria."
  )
})

test_that("Problems with drop_any arguments produce errors", {
  expect_error(
    cip_filter(engr, drop_any = "111111"),
    "cip_filter. Argument drop_any misspelled or does not exist."
  )
  expect_error(
    cip_filter(engr, drop_any = "enginerr"),
    "cip_filter. Argument drop_any misspelled or does not exist."
  )
  expect_error(
    cip_filter(engr, keep_any = "engineer", drop_any = "engineer"),
    "cip_filter. No programs satisfy the filter criteria."
  )
  expect_error(
    cip_filter(engr, keep_any = "engineer", "mechanical"),
    paste("Arguments after ... must be named.",
          "unexpected arguments: 'mechanical'")
  )
  expect_error(
    cip_filter(engr, "engineer", "mechanical"),
    paste("Arguments after ... must be named.",
          "unexpected arguments: 'mechanical'")
  )
})
