context("cip6_select")

# test_that("cip6_select() uses program argument = cip2name", {
#   load(file = get_my_path("my_args_11.rda"))
#   load(file = get_my_path("exp_out_11.rda"))
#   expect_equal(do.call(cip6_select, my_args), exp_out)
#
#   load(file = get_my_path("my_args_12.rda"))
#   load(file = get_my_path("exp_out_12.rda"))
#   expect_equal(do.call(cip6_select, my_args), exp_out)
#
#   load(file = get_my_path("my_args_13.rda"))
#   load(file = get_my_path("exp_out_13.rda"))
#   expect_equal(do.call(cip6_select, my_args), exp_out)
#
#   load(file = get_my_path("my_args_14.rda"))
#   load(file = get_my_path("exp_out_14.rda"))
#   expect_equal(do.call(cip6_select, my_args), exp_out)
# })


test_that("cip6_select() labels named series", {

  # expect_setequal() ignores order and duplicates
  df <- midfieldr::cip_filter(cip, series = cip_engr) %>% cip6_select()
  expect_setequal(unique(df$program), "Engineering")

  df <- midfieldr::cip_filter(cip, series = cip_bio_sci) %>% cip6_select()
  expect_setequal(unique(df$program), "Biological and Biomedical Sciences")

  df <- midfieldr::cip_filter(cip, series = cip_math_stat) %>% cip6_select()
  expect_setequal(unique(df$program), "Mathematics and Statistics")

  df <- midfieldr::cip_filter(cip, series = cip_phys_sci) %>% cip6_select()
  expect_setequal(unique(df$program), "Physical Sciences")

  df <- midfieldr::cip_filter(cip, series = cip_other_stem) %>% cip6_select()
  expect_setequal(unique(df$program), "Other STEM")

  df <- midfieldr::cip_filter(cip, series = cip_stem) %>% cip6_select()
  expect_setequal(unique(df$program), "STEM")
})
