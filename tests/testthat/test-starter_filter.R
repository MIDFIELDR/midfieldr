context("starter_filter")

library(dplyr)

# get_my_path() in tests/testthat/helper.R
load(file = get_my_path("subset_students.rda"))

x <- subset_students
x_cip6_col  <- x["cip6"]
x_cip6_atom <- x[["cip6"]]

ref1 <- subset_students
ref2 <- subset_students[, 1:3]
ref3 <- unlist(ref1)[1:100]
ref4 <- rename(case_fye, mid = id, start = cip6)

test_that("Error if incorrect series argument", {
  expect_error(
    starter_filter(codes = NULL),
    "codes cannot be NULL",
    fixed = TRUE
  )

  expect_error(
    starter_filter(codes = x_cip6_col),
    "codes must be an atomic variable",
    fixed = TRUE
  )
})

# test_that("error produced if ... incorrectly used", {
#   expect_error(
#     starter_filter(x_cip6, x_cip6),
#     "unexpected arguments"
#   )
# })

test_that("reference produces expected results", {
  expect_equal(
    starter_filter(data = ref1, codes = x_cip6_atom),
    starter_filter(data = ref2, codes = x_cip6_atom)
  )
  expect_error(
    starter_filter(data = ref3, codes = x_cip6_atom),
    "data must be a data frame or tbl"
  )

  expect_named(
    starter_filter(data = NULL, codes = x_cip6_atom),
    c("id", "cip6"),
    ignore.order = TRUE, ignore.case = FALSE
  )
})

test_that("alternate id and cip6 work", {
  expect_named(
    starter_filter(data = case_fye, codes = "140201"),
    expected = c("id", "cip6"),
    ignore.order = TRUE
  )
  # expect_named(
  #   starter_filter(
  #     data      = ref4,
  #     codes = "140201",
  #     id        = "mid",
  #     cip6      = "start"
  #   ),
  #   expected = c("mid", "start"),
  #   ignore.order = TRUE
  # )
  # expect_error(
  #   starter_filter(
  #     data      = ref4,
  #     codes = "140201",
  #     cip6      = "start"
  #   ),
  #   "use the id argument for non-default name"
  # )
  # expect_error(
  #   starter_filter(
  #     data      = ref4,
  #     codes = "140201",
  #     id        = "mid"
  #   ),
  #   "use the cip6 argument for non-default name"
  # )
})
