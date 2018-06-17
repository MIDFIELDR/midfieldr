context("gather_ever")

test_that("gather_ever produces correct output", {
	x <- cip_filter(series = "540104") %>%
		cip_label() %>%
		gather_ever()
	expect_equal(unique(x$institution), c("Institution F", "Institution L"))
	expect_equal(dim(x), c(41, 9))
})
