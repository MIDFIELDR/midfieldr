context("id_filter")
library("midfieldr")

# get_my_path() internal function in tests/testthat/helper.R
load(file = get_my_path("subset_students.rda"))
# load(file = get_my_path("subset_courses.rda"))
# load(file = get_my_path("subset_terms.rda"))
# load(file = get_my_path("subset_degrees.rda"))

x <- subset_students
x_id <- x[["id"]][1:5]
alt_x <- x %>% dplyr::rename("alt_id" = "id")
alt_x_id <- alt_x[["alt_id"]][1:5]

test_that("Data argument is a data frame or tbl", {
  expect_error(
    id_filter(data = runif(10), input_id = x_id),
    "id_filter data argument must be a data frame or tbl"
  )
  expect_error(
    id_filter(data = NULL, input_id = x_id),
    "id_filter data argument must be a data frame or tbl"
  )
})

test_that("Optional argument is named", {
  expect_error(
    id_filter(x, x_id, "id"),
    "id_filter() unexpected arguments: 'id'"
  )
})

test_that("Filter returns the correct records", {
  expect_equal(
    x_id,
    id_filter(x, x_id)[["id"]]
  )
  expect_equal(
    x_id,
    id_filter(x, x_id, id = "id")[["id"]]
  )
  expect_equal(
    alt_x_id,
    id_filter(alt_x, alt_x_id, id = "alt_id")[["alt_id"]]
  )
})

test_that("Optional ID argument works", {
  expect_equal(
    alt_x_id,
    id_filter(alt_x, alt_x_id, id = "alt_id")[["alt_id"]]
  )
  expect_equal(
    x_id,
    id_filter(x, x_id, id = "id")[["id"]]
  )
})

test_that("Error if incorrect value for id argument", {
  expect_error(
    id_filter(
      alt_x,
      alt_x_id
    ),
    "id_filter incorrect value for id argument."
  )
  expect_error(
    id_filter(alt_x,
      alt_x_id,
      id = "id"
    ),
    "id_filter incorrect value for id argument."
  )
  expect_error(
    id_filter(x,
      x_id,
      id = "alt_id"
    ),
    "id_filter incorrect value for id argument."
  )
})

test_that("Error when required arguments are NULL", {
  expect_error(
    id_filter(data = x, input_id = NULL),
    "id_filter input_id argument cannot be NULL."
  )
})
