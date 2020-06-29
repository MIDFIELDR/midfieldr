context("utils")
library("midfieldr")

# get_my_path() internal function in tests/testthat/helper.R
# load(file = get_my_path("subset_students.rda"))
# load(file = get_my_path("subset_courses.rda"))
load(file = get_my_path("subset_terms.rda"))
# load(file = get_my_path("subset_degrees.rda"))

x <- cip[1, ]
y <- kable2html(x)
z <- attr(y, which = "format")
subset_terms <- subset_terms


# kable2html() ------------------------------------
test_that("kable2html creates an html object", {
  expect_equal(z, "html")
})

# term_separate() ------------------------------------
test_that("Data argument is a data frame or tbl", {
  expect_error(
    term_separate(data = runif(10), col = "term"),
    "term_separate data argument must be a data frame or tbl"
  )
  expect_error(
    term_separate(data = NULL, col = "term"),
    "term_separate data argument must be a data frame or tbl"
  )
})
test_that("YYYY is correctly extracted from YYYYT", {
  expect_equal(
    term_separate(data = subset_terms, col = "term")[["term_year"]],
    floor(term_separate(data = subset_terms, col = "term")[["term"]] / 10)
  )
})
test_that("Error when col argument is NULL or misnamed", {
  expect_error(
    term_separate(data = subset_terms, col = NULL),
    "term_separate col argument cannot be NULL."
  )
  expect_error(
    term_separate(data = subset_terms, col = "not_term"),
    "term_separate incorrect value for col argument."
  )
})
test_that("Error if YYYYT has not 5 digits", {
  x <- subset_terms

  x$term[1] <- 1000
  expect_error(
    term_separate(data = x, col = "term"),
    "term_separate YYYYT values can have 5 digits only."
  )
  x$term[1] <- 9999
  expect_error(
    term_separate(data = x, col = "term"),
    "term_separate YYYYT values can have 5 digits only."
  )
  x$term[1] <- 100000
  expect_error(
    term_separate(data = x, col = "term"),
    "term_separate YYYYT values can have 5 digits only."
  )

  x$term[1] <- 999999
  expect_error(
    term_separate(data = x, col = "term"),
    "term_separate YYYYT values can have 5 digits only."
  )
})
