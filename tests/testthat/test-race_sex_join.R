context("race_sex_join")
library("midfieldr")

# get_my_path() internal function in tests/testthat/helper.R
load(file = get_my_path("subset_students.rda"))
# load(file = get_my_path("subset_courses.rda"))
# load(file = get_my_path("subset_terms.rda"))
load(file = get_my_path("subset_degrees.rda"))

ever <- ever_filter(codes = "540104")

ever1 <- ever %>%
  race_sex_join()
ever2 <- ever1 %>%
  select(-race) %>%
  race_sex_join()
ever3 <- ever1 %>%
  select(-sex) %>%
  race_sex_join()
ever4 <- ever1 %>%
  race_sex_join()

data1 <- subset_degrees %>%
  select(-id)

id_only1 <- subset_students["id"]
id_only2 <- ever["id"]

test_that("Data argument is a data frame or tbl", {
  expect_error(
    race_sex_join(data = runif(10)),
    "race_sex_join data argument must be a data frame or tbl"
  )
  expect_error(
    race_sex_join(data = NULL),
    "race_sex_join data argument must be a data frame or tbl"
  )
})

test_that("Default data set used when demographics is NULL", {
  expect_equal(
    race_sex_join(data = ever, demographics = NULL),
    race_sex_join(data = ever, demographics = midfieldstudents)
  )
})

test_that("race_sex_join() does not overwrite existing race or sex variables", {
  expect_setequal(ever1$race, ever2$race)
  expect_setequal(ever1$race, ever3$race)
  expect_setequal(ever1$race, ever4$race)
  expect_setequal(ever1$sex, ever2$sex)
  expect_setequal(ever1$sex, ever3$sex)
  expect_setequal(ever1$sex, ever4$sex)
})

test_that("data includes id", {
  expect_error(
    race_sex_join(data1),
    "race_sex_join, id missing from data",
    fixed = TRUE
  )
  expect_error(
    race_sex_join(data = id_only1, demographics = data1),
    "race_sex_join, id, race, or sex missing from demographics",
    fixed = TRUE
  )
})

test_that("optional reference argument works", {
  expect_equivalent(
    race_sex_join(data = id_only1, demographics = subset_students),
    race_sex_join(data = id_only1)
  )
})

test_that("id mismatch between data and reference throws an error", {
  expect_error(
    race_sex_join(data = id_only2, demographics = subset_students),
    "race_sex_join, id mismatch between data and demographics",
    fixed = TRUE
  )
})
