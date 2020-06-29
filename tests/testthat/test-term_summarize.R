context("term_summarize")
library("midfieldr")
library("midfielddata")

# get_my_path() internal function in tests/testthat/helper.R
# load(file = get_my_path("subset_students.rda"))
load(file = get_my_path("subset_courses.rda"))
# load(file = get_my_path("subset_terms.rda"))
# load(file = get_my_path("subset_degrees.rda"))

x <- subset_terms
x_alt <- x %>% dplyr::rename("alt_institution" = "institution")
x_alt2 <- x %>% dplyr::rename("alt_term" = "term")


test_that("Default data set used when data is NULL", {
  expect_equal(
    term_summarize(data = NULL),
    term_summarize(data = midfieldterms)
  )
})

test_that("Data argument is a data frame or tbl", {
  expect_error(
    term_summarize(data = runif(10)),
    "term_summarize data argument must be a data frame or tbl"
  )
})

test_that("Optional arguments works", {
  expect_equal(
    term_summarize(x_alt, institution = "alt_institution")[["range_min"]],
    term_summarize(x)[["range_min"]]
  )
  expect_equal(
    term_summarize(x_alt2, term = "alt_term")[["range_min"]],
    term_summarize(x)[["range_min"]]
  )
})

test_that("Optional argument is named", {
  expect_error(
    term_summarize(x, "institution"),
    "term_summarize() unexpected arguments: 'institution'"
  )
  expect_error(
    term_summarize(x, institution = "institution", "term"),
    "term_summarize() unexpected arguments: 'term'"
  )
})

test_that("Error for incorrect variable names", {
  expect_error(
    term_summarize(x_alt, institution = "institution"),
    "term_summarize expects an institution variable."
  )
  expect_error(
    term_summarize(x_alt2, term = "term"),
    "term_summarize expects a term variable."
  )
})
