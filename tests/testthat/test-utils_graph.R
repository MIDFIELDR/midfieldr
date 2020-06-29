context("utils_graph")
library("midfieldr")

# get_my_path() internal function in tests/testthat/helper.R
# load(file = get_my_path("subset_students.rda"))
# load(file = get_my_path("subset_courses.rda"))
# load(file = get_my_path("subset_terms.rda"))
# load(file = get_my_path("subset_degrees.rda"))

test_that("theme_midfield works", {
  expect_is(theme_midfield(), "theme")
})

test_that("scale_x_log10_expon works", {
  expect_is(scale_x_log10_expon(), "ScaleContinuous")
})
