context("cip6_select")

# testing data frames
ece <- cip_filter(cip, "^1410")
ece_prog1 <- cip6_select(ece, "ECE")
ece_prog2 <- cip6_select(ece, "cip2name")
ece_prog4 <- cip6_select(ece, "cip4name")
ece_prog6 <- cip6_select(ece, "cip6name")
ece_prog7 <- cip6_select(ece, program = NULL)

df1 <- cip6_select(cip_filter(cip, cip_phys_sci), "named_series")
df2 <- cip6_select(cip_filter(cip, cip_engr), "named_series")
df3 <- cip6_select(cip_filter(cip, cip_bio_sci), "named_series")
df4 <- cip6_select(cip_filter(cip, cip_math_stat), "named_series")
df5 <- cip6_select(cip_filter(cip, cip_other_stem), "named_series")
df6 <- cip6_select(cip_filter(cip, cip_stem), "named_series")

test_that("cip6_select yields correct program name", {
  expect_equal("ECE", unique(ece_prog1$program))
  expect_equal(ece$cip2name, ece_prog2$program)
  expect_equal(ece$cip4name, ece_prog4$program)
  expect_equal(ece$cip6name, ece_prog6$program)
  expect_equal(ece$cip4name, ece_prog7$program)

  expect_equal("Physical Sciences", unique(df1$program))
  expect_equal("Engineering", unique(df2$program))
  expect_equal("Biological and Biomedical Sciences", unique(df3$program))
  expect_equal("Mathematics and Statistics", unique(df4$program))
  expect_equal("Other STEM", unique(df5$program))
  expect_equal("STEM", unique(df6$program))

  expect_error(cip6_select(cip_filter(cip, "cip_stm"), "named_series"), "cip6_select: Error in named series")
})




# test_that("cip6_select() uses program argument = cip2name", {
#   load(file = get_my_path("my_args_11.rda"))
#   load(file = get_my_path("exp_out_11.rda"))
#   expect_equal(do.call(cip6_select, my_args), exp_out)

# load(file = get_my_path("my_args_12.rda"))
# load(file = get_my_path("exp_out_12.rda"))
# expect_equal(do.call(cip6_select, my_args), exp_out)
#
# load(file = get_my_path("my_args_13.rda"))
# load(file = get_my_path("exp_out_13.rda"))
# expect_equal(do.call(cip6_select, my_args), exp_out)
#
# load(file = get_my_path("my_args_14.rda"))
# load(file = get_my_path("exp_out_14.rda"))
# expect_equal(do.call(cip6_select, my_args), exp_out)
# })


# test_that("cip6_select() labels named series", {
#
#   # expect_setequal() ignores order and duplicates
#   df <- midfieldr::cip_filter(cip, series = cip_engr) %>% cip6_select()
#   expect_setequal(unique(df$program), "Engineering")
#
#   df <- midfieldr::cip_filter(cip, series = cip_bio_sci) %>% cip6_select()
#   expect_setequal(unique(df$program), "Biological and Biomedical Sciences")
#
#   df <- midfieldr::cip_filter(cip, series = cip_math_stat) %>% cip6_select()
#   expect_setequal(unique(df$program), "Mathematics and Statistics")
#
#   df <- midfieldr::cip_filter(cip, series = cip_phys_sci) %>% cip6_select()
#   expect_setequal(unique(df$program), "Physical Sciences")
#
#   df <- midfieldr::cip_filter(cip, series = cip_other_stem) %>% cip6_select()
#   expect_setequal(unique(df$program), "Other STEM")
#
#   df <- midfieldr::cip_filter(cip, series = cip_stem) %>% cip6_select()
#   expect_setequal(unique(df$program), "STEM")
# })
