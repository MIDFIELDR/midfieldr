context("utils")

library("midfieldr")
x <- cip[1, ]
y <- kable2html(x)
z <- attr(y, which = "format")

test_that("kable2html creates an html object", {
        expect_equal(z, "html")
})



