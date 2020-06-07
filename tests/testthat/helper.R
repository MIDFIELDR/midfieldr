# helper function for using rprojroot
get_my_path <- function(filename) {
  rprojroot::find_testthat_root_file(
    "testing-data", filename
  )
}







# create subsets of midfielddata with no missing values for testing
# library(midfieldr)
# library(midfielddata)
# library(tidyverse)
# gather_data_subset <- function(data_file) {
#   set.seed(20180628)
#   subset <- dplyr::sample_n(data_file, 5000)
#   subset_names <- names(subset)[colSums(is.na(subset)) > 0]
#   subset <- subset %>%
#     arrange_at(vars(subset_names), list(name = ~is.na(.))) %>%
#     head(n = 100L)
# }
# subset_students <- gather_data_subset(midfielddata::midfieldstudents)
# subset_terms    <- gather_data_subset(midfielddata::midfieldterms)
# subset_courses  <- gather_data_subset(midfielddata::midfieldcourses)
# subset_degrees  <- gather_data_subset(midfielddata::midfielddegrees)
# save(subset_students, file = "tests/testthat/testing-data/subset_students.rda")
# save(subset_terms, file = "tests/testthat/testing-data/subset_terms.rda")
# save(subset_courses, file = "tests/testthat/testing-data/subset_courses.rda")
# save(subset_degrees, file = "tests/testthat/testing-data/subset_degrees.rda")


## create argumnents and expected results
## arguments in a list to use with do.call() in test_*.R file



# ## for testing scale_x_log10_expon() () ---------------------------
# exp_out <- ggplot() + scale_x_log10_expon()
# exp_out$plot_env <- NULL
# save(exp_out, file = "tests/testthat/testing-data/exp_out_01.rda")
#
#
#
# ## for testing theme_midfield() () ---------------------------
# exp_out <- ggplot() + theme_midfield()
# exp_out$plot_env <- NULL
# save(exp_out, file = "tests/testthat/testing-data/exp_out_02.rda")



## create test data for multiway_order() ---------------------------
# data("starwars", package = "dplyr")
#   df1 <- dplyr::select(starwars, name, species, mass) %>%
#   	drop_na()
#   df2 <- dplyr::select(starwars, name, species, mass) %>%
# 	  dplyr::mutate_if(is.character, as.factor) %>%
#   	drop_na()
#   df3 <- dplyr::select(starwars, name, species, mass, height) %>%
#   	drop_na()
#   df4 <- dplyr::select(starwars, name, species, gender, mass) %>%
#   	drop_na()
#   save(df1, df2, df3, df4, file = "tests/testthat/testing-data/test_df_01.rda")







## create data for race_sex_join() ---------------------------------------
# .data  <- cip_filter(series = "540104") %>%
# 	cip_label(program = NULL) %>%
# 	gather_grad()
#
# my_args <- list(.data)
# save(my_args, file = "tests/testthat/testing-data/my_args_05.rda")
# (do.call(midfieldr::race_sex_join, my_args))
# exp_out <- race_sex_join(.data)
# save(exp_out, file = "tests/testthat/testing-data/exp_out_05.rda")
#
# # with a race and sex column already present
# my_args <- list(.data  = exp_out)
# (do.call(midfieldr::race_sex_join, my_args))
# save(my_args, file = "tests/testthat/testing-data/my_args_06.rda")
# exp_out <- race_sex_join(.data )
# save(exp_out, file = "tests/testthat/testing-data/exp_out_06.rda")



# # create data for cip_label() ---------------------------------------
# engr <- cip_filter(series = cip_engr)
# bio_sci <- cip_filter(series = cip_bio_sci)
# math_stat <- cip_filter(series = cip_math_stat)
# phys_sci <- cip_filter(series = cip_phys_sci)
#
# my_args <- list(.cip = engr, program = NULL)
# (do.call(midfieldr::cip_label, my_args))
# save(my_args, file = "tests/testthat/testing-data/my_args_05.rda")
# exp_out <- cip_label(.cip = engr, program = NULL)
# save(exp_out, file = "tests/testthat/testing-data/exp_out_05.rda")
#
# my_args <- list(.cip = bio_sci, program = NULL)
# save(my_args, file = "tests/testthat/testing-data/my_args_06.rda")
# exp_out <- cip_label(.cip = bio_sci, program = NULL)
# save(exp_out, file = "tests/testthat/testing-data/exp_out_06.rda")
#
# my_args <- list(.cip = math_stat, program = NULL)
# save(my_args, file = "tests/testthat/testing-data/my_args_07.rda")
# exp_out <- cip_label(.cip = math_stat, program = NULL)
# save(exp_out, file = "tests/testthat/testing-data/exp_out_07.rda")
#
# my_args <- list(.cip = phys_sci, program = NULL)
# save(my_args, file = "tests/testthat/testing-data/my_args_10.rda")
# exp_out <- cip_label(.cip = phys_sci, program = NULL)
# save(exp_out, file = "tests/testthat/testing-data/exp_out_10.rda")
#
# my_args <- list(.cip = engr, program = "cip2name")
# save(my_args, file = "tests/testthat/testing-data/my_args_11.rda")
# exp_out <- cip_label(.cip = engr, program = "cip2name")
# save(exp_out, file = "tests/testthat/testing-data/exp_out_11.rda")
#
# my_args <- list(.cip = engr, program = "cip4name")
# save(my_args, file = "tests/testthat/testing-data/my_args_12.rda")
# exp_out <- cip_label(.cip = engr, program = "cip4name")
# save(exp_out, file = "tests/testthat/testing-data/exp_out_12.rda")
#
# my_args <- list(.cip = engr, program = "cip6name")
# save(my_args, file = "tests/testthat/testing-data/my_args_13.rda")
# exp_out <- cip_label(.cip = engr, program = "cip6name")
# save(exp_out, file = "tests/testthat/testing-data/exp_out_13.rda")
#
# my_args <- list(.cip = engr, program = "randomname")
# save(my_args, file = "tests/testthat/testing-data/my_args_14.rda")
# exp_out <- cip_label(.cip = engr, program = "randomname")
# save(exp_out, file = "tests/testthat/testing-data/exp_out_14.rda")






# some issue with stem and other stem ------------------------------
# library(tidyverse)
# library(midfieldr)
# other_stem <- cip_filter(series = cip_other_stem)
# stem <- cip_filter(series = cip_stem)
#
#
# my_args <- list(data = other_stem, program = NULL)
# save(my_args, file = "tests/testthat/testing-data/my_args_08.rda")
# exp_out <- cip_label(data = other_stem, program = NULL)
# save(exp_out, file = "tests/testthat/testing-data/exp_out_08.rda")
#
# df1 <- do.call(midfieldr::cip_label, my_args)
# df2 <- cip_label(data = other_stem, program = NULL)
# all_equal(df1, df2)
#
#
# my_args <- list(data = stem, program = NULL)
# save(my_args, file = "tests/testthat/testing-data/my_args_09.rda")
# (do.call(midfieldr::cip_label, my_args))
# exp_out <- cip_label(data = stem, program = NULL)
# save(exp_out, file = "tests/testthat/testing-data/exp_out_09.rda")











# # practice testing gather_ever() ---------------------------------------
# ever <- cip_filter(series = "540104") %>%
# 	cip_label() %>%
# 	gather_ever()
# unique(ever$institution)
# dim(ever)
#
#
# # practice testing gather_grad() ---------------------------------------
# grad <- cip_filter(series = "540104") %>%
# 	cip_label() %>%
# 	gather_grad()
# unique(grad$institution)
# dim(grad)
#
# # practice testing tally_stickiness() ---------------------------------
# program_group <- cip_filter(series = "540104") %>%
# 	cip_label(program = "cip4name")
#
# # count students ever enrolled in programs
# ever <- gather_ever(program_group) %>%
# 	race_sex_join() %>%
# 	group_by(program, race, sex) %>%
# 	summarize(ever = n()) %>%
# 	ungroup() %>%
# 	zero_fill(program, race, sex)
#
# # count students graduating from programs
# grad <- gather_grad(program_group) %>%
# 	race_sex_join() %>%
# 	group_by(program, race, sex) %>%
# 	summarize(grad = n()) %>%
# 	ungroup() %>%
# 	zero_fill(program, race, sex)
#
# stick <- full_join(ever, grad) %>%
# 	zero_fill(program, race, sex)
#
# # compute stickiness of programs
# stick <- tally_stickiness(ever, grad)


















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
# save(my_args, file = "tests/testthat/testing-data/my_args_01.rda")
# exp_out <- format_engr(x, sigdig = sigdig, ambig_0_adj = ambig_0_adj)
# save(exp_out, file = "tests/testthat/testing-data/exp_out_01.rda")
#
# ## for testing align_pander()
# my_args <- list(y)
# save(my_args, file = "tests/testthat/testing-data/my_args_02.rda")
# exp_out <- capture_output(align_pander(y))
# save(exp_out, file = "tests/testthat/testing-data/exp_out_02.rda")
#
# ## for testing put_axes()
# my_args <- list(quadrant = NULL, col = NULL, size = NULL)
# save(my_args, file = "tests/testthat/testing-data/my_args_03.rda")
# exp_out <- do.call(docxtools::put_axes, my_args)
# save(exp_out, file = "tests/testthat/testing-data/exp_out_03.rda")
