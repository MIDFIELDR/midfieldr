# helper function for using rprojroot
get_my_path <- function(filename) {
  rprojroot::find_testthat_root_file(
    "testing_data", filename
  )
}

## create argumnents and expected results
## arguments in a list to use with do.call() in test_*.R file



## for testing scale_x_log10_expon() () ---------------------------
  # exp_out <- ggplot() + scale_x_log10_expon()
  # exp_out$plot_env <- NULL
  # save(exp_out, file = "tests/testthat/testing_data/exp_out_01.rda")



## for testing theme_midfield() () ---------------------------
  # exp_out <- ggplot() + theme_midfield()
  # exp_out$plot_env <- NULL
  # save(exp_out, file = "tests/testthat/testing_data/exp_out_02.rda")



## create test data for multiway_order() ---------------------------
# data("starwars", package = "dplyr")
#   df1 <- dplyr::select(starwars, name, species, mass)
#   df2 <- dplyr::select(starwars, name, species, mass) %>%
# 	  dplyr::mutate_if(is.character, as.factor)
#   df3 <- dplyr::select(starwars, name, species, mass, height)
#   df4 <- dplyr::select(starwars, name, species, gender, mass)
#   save(df1, df2, df3, df4, file = "tests/testthat/testing_data/test_df_01.rda")



## create test data for zero_fill() ---------------------------
# a <- rep(c("A", "B"), each = 3)
# b <- rep(c("D", "E", "F"), times = 2)
# n <- 1:6
# df1 <- data.frame(a, b, n)
# df2 <- df1[-6, ]
#
# ## for df1, no missing combinations
# my_args <- list(df1, dplyr::quo(a), dplyr::quo(b))
# (do.call(midfieldr::zero_fill, my_args))
# save(my_args, file = "tests/testthat/testing_data/my_args_03.rda")
# exp_out <- zero_fill(df1, a, b)
# save(exp_out, file = "tests/testthat/testing_data/exp_out_03.rda")
#
# ## for df2, missing a combination
# my_args <- list(df2, dplyr::quo(a), dplyr::quo(b))
# (do.call(midfieldr::zero_fill, my_args))
# save(my_args, file = "tests/testthat/testing_data/my_args_04.rda")
# exp_out <- zero_fill(df2, a, b)
# save(exp_out, file = "tests/testthat/testing_data/exp_out_04.rda")



## create data for race_sex_join() ---------------------------------------
# x <- cip_filter(series = "540104") %>%
# 	cip_label(program = NULL) %>%
# 	gather_grad()
#
# my_args <- list(df = x)
# save(my_args, file = "tests/testthat/testing_data/my_args_05.rda")
# (do.call(midfieldr::race_sex_join, my_args))
# exp_out <- race_sex_join(df = x)
# save(exp_out, file = "tests/testthat/testing_data/exp_out_05.rda")
#
# # with a race and sex column already present
# my_args <- list(df = exp_out)
# (do.call(midfieldr::race_sex_join, my_args))
# save(my_args, file = "tests/testthat/testing_data/my_args_06.rda")
# exp_out <- race_sex_join(df = x)
# save(exp_out, file = "tests/testthat/testing_data/exp_out_06.rda")



## create data for cip_label() ---------------------------------------
# engr <- cip_filter(series = cip_engr)
# bio_sci <- cip_filter(series = cip_bio_sci)
# math_stat <- cip_filter(series = cip_math_stat)
# phys_sci <- cip_filter(series = cip_phys_sci)
#
# my_args <- list(data = engr, program = NULL)
# (do.call(midfieldr::cip_label, my_args))
# save(my_args, file = "tests/testthat/testing_data/my_args_05.rda")
# exp_out <- cip_label(data = engr, program = NULL)
# save(exp_out, file = "tests/testthat/testing_data/exp_out_05.rda")
#
# my_args <- list(data = bio_sci, program = NULL)
# save(my_args, file = "tests/testthat/testing_data/my_args_06.rda")
# exp_out <- cip_label(data = bio_sci, program = NULL)
# save(exp_out, file = "tests/testthat/testing_data/exp_out_06.rda")
#
# my_args <- list(data = math_stat, program = NULL)
# save(my_args, file = "tests/testthat/testing_data/my_args_07.rda")
# exp_out <- cip_label(data = math_stat, program = NULL)
# save(exp_out, file = "tests/testthat/testing_data/exp_out_07.rda")
#
# my_args <- list(data = phys_sci, program = NULL)
# save(my_args, file = "tests/testthat/testing_data/my_args_10.rda")
# exp_out <- cip_label(data = phys_sci, program = NULL)
# save(exp_out, file = "tests/testthat/testing_data/exp_out_10.rda")
#
# my_args <- list(data = engr, program = "cip2name")
# save(my_args, file = "tests/testthat/testing_data/my_args_11.rda")
# exp_out <- cip_label(data = engr, program = "cip2name")
# save(exp_out, file = "tests/testthat/testing_data/exp_out_11.rda")
#
# my_args <- list(data = engr, program = "cip4name")
# save(my_args, file = "tests/testthat/testing_data/my_args_12.rda")
# exp_out <- cip_label(data = engr, program = "cip4name")
# save(exp_out, file = "tests/testthat/testing_data/exp_out_12.rda")
#
# my_args <- list(data = engr, program = "cip6name")
# save(my_args, file = "tests/testthat/testing_data/my_args_13.rda")
# exp_out <- cip_label(data = engr, program = "cip6name")
# save(exp_out, file = "tests/testthat/testing_data/exp_out_13.rda")
#
# my_args <- list(data = engr, program = "randomname")
# save(my_args, file = "tests/testthat/testing_data/my_args_14.rda")
# exp_out <- cip_label(data = engr, program = "randomname")
# save(exp_out, file = "tests/testthat/testing_data/exp_out_14.rda")






# some issue with stem and other stem ------------------------------
# library(tidyverse)
# library(midfieldr)
# other_stem <- cip_filter(series = cip_other_stem)
# stem <- cip_filter(series = cip_stem)
#
#
# my_args <- list(data = other_stem, program = NULL)
# save(my_args, file = "tests/testthat/testing_data/my_args_08.rda")
# exp_out <- cip_label(data = other_stem, program = NULL)
# save(exp_out, file = "tests/testthat/testing_data/exp_out_08.rda")
#
# df1 <- do.call(midfieldr::cip_label, my_args)
# df2 <- cip_label(data = other_stem, program = NULL)
# all_equal(df1, df2)
#
#
# my_args <- list(data = stem, program = NULL)
# save(my_args, file = "tests/testthat/testing_data/my_args_09.rda")
# (do.call(midfieldr::cip_label, my_args))
# exp_out <- cip_label(data = stem, program = NULL)
# save(exp_out, file = "tests/testthat/testing_data/exp_out_09.rda")











## practice testing gather_ever() ---------------------------------------
# x <- cip_filter(series = "540104") %>%
# 	cip_label() %>%
# 	gather_ever()
# unique(x$institution)
# dim(x)
#
#
## practice testing gather_grad() ---------------------------------------
# x <- cip_filter(series = "540104") %>%
# 	cip_label() %>%
# 	gather_grad()
# unique(x$institution)
# dim(x)




















# ------------------- reference -------------------------------------
# data("CO2")
# x <- as.data.frame(head(CO2, n = 5L))
# sigdig <- c(3, 3)
# ambig_0_adj <- TRUE
# y <- format_engr(x, sigdig = sigdig, ambig_0_adj = ambig_0_adj)
# rm("CO2")
#
# ## for testing format_engr()
# my_args <- list(x, sigdig, ambig_0_adj)
# save(my_args, file = "tests/testthat/testing_data/my_args_01.rda")
# exp_out <- format_engr(x, sigdig = sigdig, ambig_0_adj = ambig_0_adj)
# save(exp_out, file = "tests/testthat/testing_data/exp_out_01.rda")
#
# ## for testing align_pander()
# my_args <- list(y)
# save(my_args, file = "tests/testthat/testing_data/my_args_02.rda")
# exp_out <- capture_output(align_pander(y))
# save(exp_out, file = "tests/testthat/testing_data/exp_out_02.rda")
#
# ## for testing put_axes()
# my_args <- list(quadrant = NULL, col = NULL, size = NULL)
# save(my_args, file = "tests/testthat/testing_data/my_args_03.rda")
# exp_out <- do.call(docxtools::put_axes, my_args)
# save(exp_out, file = "tests/testthat/testing_data/exp_out_03.rda")


