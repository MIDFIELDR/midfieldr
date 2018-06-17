context("gather_grad")

test_that("gather_grad produces correct output", {
	x <- cip_filter(series = "540104") %>%
		cip_label() %>%
		gather_grad()
	expect_equal(unique(x$institution), "Institution F")
	expect_equal(dim(x), c(24, 5))
})

