context("race_sex_join")

.data <- cip_filter(series = "540104") %>%
  cip_label() %>%
  gather_ever()

test_that("race_sex_join() produces expected output", {
  load(file = get_my_path("my_args_05.rda"))
  load(file = get_my_path("exp_out_05.rda"))
  expect_equal(do.call(race_sex_join, my_args), exp_out)

  load(file = get_my_path("my_args_06.rda"))
  load(file = get_my_path("exp_out_06.rda"))
  expect_equal(do.call(race_sex_join, my_args), exp_out)
})


test_that("Argument is a data frame", {
  x <- runif(10)
  expect_error(race_sex_join(x), "midfieldr::race_sex_join() argument must be a data.frame or tbl", fixed = TRUE)
})


test_that("Required variables are present", {
  .no_id <- select(.data, cip6, program)
  expect_error(
    race_sex_join(.no_id),
    "midfieldr::race_sex_join() data frame must include an `id` variable",
    fixed = TRUE
  )
})
