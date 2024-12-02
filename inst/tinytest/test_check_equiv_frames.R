test_check_equiv_frames <- function() {

    # usage
    # check_equiv_frames(x, y)

    # Needed for tinytest::build_install_test()
    library("data.table")

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
    expect_true(check_equiv_frames(x, y))
    
    # When not same content, output is FALSE
    expect_true(!check_equiv_frames(dt1, dt2))
    
    # Different number of rows only
    expect_true(!check_equiv_frames(dt1, dt1[1:4]))
    
    # Different column names only
    expect_true(!check_equiv_frames(dt2[, .(gamma, delta)], dt2[, .(gamma, epsilon)]))
    
    # Different number of columns
    expect_true(!check_equiv_frames(dt2, dt2[, 1:2]))

    # Same number of rows, different row content
    expect_true(!check_equiv_frames(dt1[1:4], dt1[2:5]))

    # data frame arguments must be data frames
    expect_true(!check_equiv_frames(dt1$alpha, dt1))
    
    # function output not printed
    invisible(NULL)
}

test_check_equiv_frames()






