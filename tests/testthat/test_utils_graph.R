# run from devtools::test() only, otherwise the rds files are written
# to the project root directory

library(midfieldr)
library(testthat)
library(rprojroot)

# working directories differ for tests
# During package development (working directory: package root)
# When testing with devtools::test() (working directory: tests/testthat)
# When running R CMD check (working directory: a renamed recursive copy of tests)
dir(is_testthat$find_file("hierarchy", path = is_r_package$find_file()))

context("utils_graph")

test_that("expon scale fun equal to reference", {
	expect_known_value(
		expon_scale_x_log10(),
		file = "ref_expon_scale.rds",
		update = TRUE)
})

test_that("midfield theme equal to reference", {
	expect_known_value(
		midfield_theme(),
		file = "ref_theme.rds",
		update = TRUE)
})
