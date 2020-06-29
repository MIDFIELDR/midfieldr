context("rcb")
library("midfieldr")

test_that("produces expected hex color code", {
  expect_equal(rcb("dark_Br"), "#8C510A")
  expect_equal(rcb("mid_Gn"), "#5AAE61")
  expect_equal(rcb("pale_Gray"), "#D9D9D9")
})
