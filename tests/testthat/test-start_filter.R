context("start_filter")
library("midfieldr")

# get_my_path() internal function in tests/testthat/helper.R
load(file = get_my_path("subset_students.rda"))
# load(file = get_my_path("subset_courses.rda"))
# load(file = get_my_path("subset_terms.rda"))
# load(file = get_my_path("subset_degrees.rda"))

x <- subset_students
x_cip6_col <- x["cip6"]
x_cip6_atom <- x[["cip6"]]

ref1 <- subset_students
ref2 <- subset_students[, 1:3]
ref3 <- unlist(ref1)[1:100]
ref4 <- dplyr::rename(exa_imputed_fye, mid = id, start = cip6)

test_that("Data argument is a data frame or tbl", {
  expect_error(
    start_filter(data = runif(10), codes = "540104"),
    "start_filter data argument must be a data frame or tbl"
  )
})

test_that("Default data set used when data is NULL", {
  expect_equal(
    start_filter(data = NULL, codes = "540104"),
    start_filter(data = midfieldstudents, codes = "540104")
  )
})

test_that("Error if incorrect series argument", {
  expect_error(
    start_filter(codes = NULL),
    "codes cannot be NULL",
    fixed = TRUE
  )

  expect_error(
    start_filter(codes = x_cip6_col),
    "codes must be an atomic variable",
    fixed = TRUE
  )
})

test_that("reference produces expected results", {
  expect_equal(
    start_filter(data = ref1, codes = x_cip6_atom),
    start_filter(data = ref2, codes = x_cip6_atom)
  )
  expect_named(
    start_filter(data = NULL, codes = x_cip6_atom),
    c("id", "cip6"),
    ignore.order = TRUE, ignore.case = FALSE
  )
})

test_that("alternate id and cip6 work", {
  expect_named(
    start_filter(data = exa_imputed_fye, codes = "140201"),
    expected = c("id", "cip6"),
    ignore.order = TRUE
  )
})
