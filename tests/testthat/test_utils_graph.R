# run from devtools::test() only
context("utils_graph")

testthat::test_that("scale_x_log10_expon() returns expected output", {
	fun_run <- ggplot2::ggplot() + midfieldr::scale_x_log10_expon()
	fun_run$plot_env <- NULL
	load(file = get_my_path("exp_out_01.rda"))
	testthat::expect_equal(fun_run, exp_out)
})

testthat::test_that("theme_midfield() returns expected output", {
	fun_run <- ggplot2::ggplot() + midfieldr::theme_midfield()
	fun_run$plot_env <- NULL
	load(file = get_my_path("exp_out_02.rda"))
	testthat::expect_equal(fun_run, exp_out)
})

