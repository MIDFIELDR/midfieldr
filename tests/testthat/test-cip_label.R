context("cip_label")

test_that("cip_label() uses program argument = cip2name", {

	load(file = get_my_path("my_args_11.rda"))
	load(file = get_my_path("exp_out_11.rda"))
	expect_equal(do.call(cip_label, my_args), exp_out)

	load(file = get_my_path("my_args_12.rda"))
	load(file = get_my_path("exp_out_12.rda"))
	expect_equal(do.call(cip_label, my_args), exp_out)

	load(file = get_my_path("my_args_13.rda"))
	load(file = get_my_path("exp_out_13.rda"))
	expect_equal(do.call(cip_label, my_args), exp_out)

	load(file = get_my_path("my_args_14.rda"))
	load(file = get_my_path("exp_out_14.rda"))
	expect_equal(do.call(cip_label, my_args), exp_out)
})


test_that("cip_label() labels named series", {

	df <- midfieldr::cip_filter(series = cip_engr) %>%  cip_label()
	expect_equal(unique(df$program), "Engineering")

	df <- midfieldr::cip_filter(series = cip_bio_sci) %>%  cip_label()
	expect_equal(unique(df$program), "Biological and Biomedical Sciences")

	df <- midfieldr::cip_filter(series = cip_math_stat) %>%  cip_label()
	expect_equal(unique(df$program), "Mathematics and Statistics")

	df <- midfieldr::cip_filter(series = cip_phys_sci) %>%  cip_label()
	expect_equal(unique(df$program), "Physical Sciences")

	# df <- midfieldr::cip_filter(series = cip_other_stem) %>%  cip_label()
	# expect_equal(unique(df$program), "Other STEM")
	#
	# df <- midfieldr::cip_filter(series = cip_stem) %>%  cip_label()
	# expect_equal(unique(df$program), "STEM")

})



