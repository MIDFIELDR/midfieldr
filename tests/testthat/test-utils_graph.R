context("utils_graph")

test_that("theme_midfield works", {
        expect_is(theme_midfield(), "theme")
})

test_that("scale_x_log10_expon works", {
        expect_is(scale_x_log10_expon(), "ScaleContinuous")
})




