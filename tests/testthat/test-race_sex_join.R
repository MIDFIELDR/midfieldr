context("race_sex_join")

test_that("race_sex_join() produces expected output", {

	load(file = get_my_path("my_args_05.rda"))
	load(file = get_my_path("exp_out_05.rda"))
	expect_equal(do.call(race_sex_join, my_args), exp_out)

	load(file = get_my_path("my_args_06.rda"))
	load(file = get_my_path("exp_out_06.rda"))
	expect_equal(do.call(race_sex_join, my_args), exp_out)

})
