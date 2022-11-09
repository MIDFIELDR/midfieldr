test_same_content <- function() {

    # usage
    # same_content(x, y)

    # Needed for tinytest::build_install_test()
    suppressPackageStartupMessages(library("data.table"))

    # test cases
    alpha <- letters[1:5]
    beta <- 5:1
    dt1 <- data.table(alpha, beta)
    
    gamma <- LETTERS[1:10]
    delta <- 10:1
    epsilon <- runif(10, 1, 100)
    dt2 <- data.table(gamma, delta, epsilon)
    
    # Same information but different row order, column order, and key
    x <- dt1[, .(alpha, beta)]
    setkey(x, alpha)
    y <- dt1[, .(beta, alpha)]
    setkey(y, beta)
    expect_true(same_content(x, y))
    
    # When not same content, output is character
    expect_equal(class(same_content(dt1, dt2)), "character")
    
    # Different number of rows only
    expect_equal(class(same_content(dt1, dt1[1:4])), "character")
    
    # Different column names only
    expect_equal(class(
        same_content(dt2[, .(gamma, delta)], dt2[, .(gamma, epsilon)])
        ), "character")

    # Different number of columns
    expect_equal(class(same_content(dt2, dt2[, 1:2])), "character")

    # Same number of rows, different row content
    expect_equal(class(same_content(dt1[1:4], dt1[2:5])), "character")
    
    # data frame arguments must be data frames
    expect_error(
        same_content(dt1$alpha, dt1)
    )
    expect_error(
        same_content(dt2, dt2$gamma)
    )
    
    # function output not printed
    invisible(NULL)
}

test_same_content()






