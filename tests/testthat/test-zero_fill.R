context("zero_fill")

test_that("zero_fill() does not expands if no combinations missing", {
	load(file = get_my_path("my_args_03.rda"))
	load(file = get_my_path("exp_out_03.rda"))
	expect_equal(do.call(zero_fill, my_args), exp_out)
})

test_that("zero_fill() expands if a combination is missing", {
	load(file = get_my_path("my_args_04.rda"))
	load(file = get_my_path("exp_out_04.rda"))
	expect_equal(do.call(zero_fill, my_args), exp_out)

})

test_that("Input arguments correct type", {
	m <- matrix(c(1, 2, 3, 11, 12, 13), nrow = 3)
	expect_error(zero_fill(m), "is.data.frame(df) is not TRUE", fixed = TRUE)
	})
