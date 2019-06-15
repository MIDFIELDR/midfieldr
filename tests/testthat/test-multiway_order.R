# run from devtools::test() only
context("test-multiway_order")

# test data df1, df2, df3, df4
# get_my_path() in tests/testthat/helper.R
load(file = get_my_path("test_df_01.rda"))

test_that("Two character variables are converted to factors", {
  expect_equal( # input is character, character, numeric
    unname(purrr::map_chr(multiway_order(df1), class)),
    c("factor", "factor", "numeric")
  )
  expect_equal( # input is factor, factor, numeric
    unname(purrr::map_chr(multiway_order(df2), class)),
    c("factor", "factor", "numeric")
  )
})

test_that("Median argument returns expected values", {
  expect_equal(
    names(multiway_order(df1, return_medians = TRUE)),
    c("name", "species", "mass", "med_name", "med_species")
  )
  expect_equal(
    names(multiway_order(df1, return_medians = NULL)),
    c("name", "species", "mass")
  )
})

test_that("Error produces if argument not a data frame", {
  x <- runif(10)
  expect_error(multiway_order(x), "midfieldr::multiway_order() argument must be a data frame or tbl", fixed = TRUE)
})
