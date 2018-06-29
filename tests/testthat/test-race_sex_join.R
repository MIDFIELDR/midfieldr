context("race_sex_join")

library(dplyr)

ever1 <- gather_ever(series = "540104") %>%
	race_sex_join()
ever2 <- ever1 %>%
	select(-race) %>%
	race_sex_join()
ever3 <- ever1 %>%
	select(-sex) %>%
	race_sex_join()
ever4 <- ever1 %>%
	race_sex_join()
ever5 <- ever1 %>%
	select(-id)

test_that("race_sex_join() does not overwrite existing race or sex variables", {
	expect_setequal(ever1$race, ever2$race)
	expect_setequal(ever1$race, ever3$race)
	expect_setequal(ever1$race, ever4$race)
	expect_setequal(ever1$sex, ever2$sex)
	expect_setequal(ever1$sex, ever3$sex)
	expect_setequal(ever1$sex, ever4$sex)
})

test_that("check for id produces error", {
	expect_error(
		race_sex_join(ever5),
		"midfieldr::race_sex_join() expects id variable in .data",
		fixed=TRUE)
})
