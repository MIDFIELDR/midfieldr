# run from devtools::test() only
context("multiway_order")

# test data df1, df2, df3, df4
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

test_that("Median argument returns median columns", {
	expect_equal(
		names(multiway_order(df1, medians = TRUE)),
		c("name", "species", "mass", "med_name", "med_species")
		)
	})

test_that("Error produces if argument not a data frame", {
	x <- runif(10)
	expect_error(multiway_order(x), "midfieldr::multiway_order() argument must be a data frame or tbl", fixed = TRUE)
})
