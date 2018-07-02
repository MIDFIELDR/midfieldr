context("race_sex_join")

library(dplyr)

ever <- ever_filter(series = "540104")

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
    "midfieldr::race_sex_join, id missing from data",
    fixed = TRUE
  )
  expect_error(
    race_sex_join(data = id_only1, reference = data1),
    "midfieldr::race_sex_join, id, race, or sex missing from reference data",
    fixed = TRUE
  )
})

test_that("optional reference argument works", {
  expect_equivalent(
    race_sex_join(data = id_only1, reference = subset_students),
    race_sex_join(data = id_only1)
  )
})

test_that("id mismatch between data and reference throws an error", {
  expect_error(
    race_sex_join(data = id_only2, reference = subset_students),
    "midfieldr::race_sex_join, id mismatch between data and reference",
    fixed = TRUE
  )
})
