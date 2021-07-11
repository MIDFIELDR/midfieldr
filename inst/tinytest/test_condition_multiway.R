test_condition_multiway <- function() {
    
    # usage 
    # condition_multiway(dframe,
    #              categ_col,
    #              quant_col,
    #              ..., 
    #              detail = NULL, 
    #              order_by = NULL,
    #              param_col = NULL)
    
    # Needed for tinytest::build_install_test()
    library("data.table")
    options(
        datatable.print.nrows = 8,
        datatable.print.topn = 8,
        datatable.print.class = TRUE
    )
    
    # create a multiway
    catg1 <- rep(c("urban", "rural", "suburb", "village"), each = 2)
    catg2 <- rep(c("men", "women"), times = 4)
    
    
    # Store existing random state
    if (!exists(".Random.seed", mode = "numeric", envir = globalenv())) {
        sample(NA)
    }
    oldSeed <- get(".Random.seed", mode = "numeric", envir = globalenv());
    set.seed(20210710)
    a <- floor(runif(8, min = 1, max = 20))
    b <- floor(runif(8, min = 40, max = 100))
    # Reset random seed to old state
    assign(".Random.seed", oldSeed, envir=globalenv());
    value <- round(a / b, 2)
    dframe <- data.frame(catg1, catg2, a, b, value)
    DT <- copy(dframe)
    setDT(DT)
    
    # apply the conditioning function 
    categ_col <- c("catg1", "catg2")
    quant_col <- c("value")
    mw <- condition_multiway(dframe,
                       categ_col,
                       quant_col)
    
    # factors converted to characters and then to factors again
    expect_equivalent(
        condition_multiway(dframe,
                     categ_col,
                     quant_col), 
        condition_multiway(mw,
                     categ_col,
                     quant_col))
    
    # columns have expected class
    expect_equal(class(mw[, catg1]), "factor")
    expect_equal(class(mw[, catg2]), "factor")
    expect_equal(class(mw[, value]), "numeric")
    
    # error when input arguments wrong class
    expect_error(
        condition_multiway(dframe = as.list(dframe), # wrong class
                     categ_col,
                     quant_col)
    )
    expect_error(
        condition_multiway(dframe,
                     categ_col = 2, # wrong class
                     quant_col)
    )
    expect_error(
        condition_multiway(dframe,
                     categ_col,
                     quant_col = 2) # wrong class
    )
    expect_error(
        condition_multiway(dframe = NULL, # cannot be NULL
                     categ_col,
                     quant_col)
    )
    expect_error(
        condition_multiway(dframe,
                     categ_col = NULL, # cannot be NULL
                     quant_col)
    )
    expect_error(
        condition_multiway(dframe,
                     categ_col,
                     quant_col = NULL) # cannot be NULL
    )
    expect_error(
        condition_multiway(dframe = NA, # must be a DF
                     categ_col,
                     quant_col)
    )
    # names specified in arguments are columns in dframe 
    expect_error(
        condition_multiway(dframe,
                     categ_col = c("catg1", NA_character_),
                     quant_col) 
    )
    expect_error(
        condition_multiway(dframe,
                     categ_col,
                     quant_col = NA_character_) 
    )
    # arguments after ... must be named
    expect_error( # detail not named
        condition_multiway(dframe,
                     categ_col,
                     quant_col,
                     NULL,             
                     order_by = NULL,
                     param_col = NULL)
    )
    expect_error( # order_by not named
        condition_multiway(dframe,
                     categ_col,
                     quant_col,
                     detail = NULL,
                     NULL,
                     param_col = NULL)
    )
    expect_error( # param_col not named
        condition_multiway(dframe,
                     categ_col,
                     quant_col,
                     detail = NULL,
                     order_by = NULL,
                     NULL)
    )
    # optional arguments 
    expect_error( # order_by = "percent" requires param_col
        condition_multiway(dframe,
                     categ_col,
                     quant_col,
                     detail = NULL,
                     order_by = "percent",
                     param_col = NULL) 
    )
    expect_error( # param_col must be numeric
        condition_multiway(dframe,
                     categ_col,
                     quant_col,
                     detail = NULL,
                     order_by = "percent", 
                     param_col = c("catg1", "catg2"))
    )
    
    # optional arguments. NULL method same as median
    expect_equal(
        condition_multiway(dframe,
                     categ_col,
                     quant_col,
                     detail = NULL,
                     order_by = "median",
                     param_col = NULL), 
        condition_multiway(dframe,
                     categ_col,
                     quant_col,
                     detail = NULL,
                     order_by = NULL, 
                     param_col = NULL)
    )
    # optional arguments. order_by median correct 
    mw <- condition_multiway(dframe,
                       categ_col,
                       quant_col,
                       detail = TRUE,
                       order_by = "median",
                       param_col = NULL)
    temp <- copy(DT)
    temp[, col_check := stats::median(value, na.rm = TRUE), by = catg1]
    expect_equal(mw[, catg1_value], temp[, col_check])
    temp[, col_check := stats::median(value, na.rm = TRUE), by = catg2]
    expect_equal(mw[, catg2_value], temp[, col_check])
    
    # optional arguments. order_by mean correct 
    mw <- condition_multiway(dframe,
                       categ_col,
                       quant_col,
                       detail = TRUE,
                       order_by = "mean",
                       param_col = NULL)
    temp <- copy(DT)
    temp[, col_check := mean(value, na.rm = TRUE), by = catg1]
    expect_equal(mw[, catg1_value], temp[, col_check])
    temp[, col_check := mean(value, na.rm = TRUE), by = catg2]
    expect_equal(mw[, catg2_value], temp[, col_check])

    # optional arguments. order_by percent correct 
    mw <- condition_multiway(dframe,
                       categ_col,
                       quant_col,
                       detail = TRUE,
                       order_by = "percent",
                       param_col = c("a", "b"))
    
    temp <- copy(DT)
    temp[, sum_a := sum(a, na.rm = TRUE), by = catg1]
    temp[, sum_b := sum(b, na.rm = TRUE), by = catg1]
    temp[, chk_ratio := round(100 * sum_a / sum_b, 1), by = catg1][]
    expect_equal(mw[, catg1_value], temp[, chk_ratio])
    
    temp[, sum_a := sum(a, na.rm = TRUE), by = catg2]
    temp[, sum_b := sum(b, na.rm = TRUE), by = catg2]
    temp[, chk_ratio := round(100 * sum_a / sum_b, 1), by = catg2][]
    expect_equal(mw[, catg2_value], temp[, chk_ratio])
    
    # warning when param_col specified but order_by is NOT percent
    expect_warning(
        condition_multiway(dframe,
                     categ_col,
                     quant_col,
                     param_col = c("a", "b"))
    )

    # optional arguments. order_by sum correct 
    mw <- condition_multiway(dframe,
                       categ_col,
                       quant_col = "a",
                       detail = TRUE,
                       order_by = "sum")
    temp <- copy(DT)
    temp[, sum_a := sum(a, na.rm = TRUE), by = catg1]
    temp[, sum_b := sum(b, na.rm = TRUE), by = catg1]
    expect_equal(mw[, catg1_a], temp[, sum_a])
    mw <- condition_multiway(dframe,
                       categ_col,
                       quant_col = "b",
                       detail = TRUE,
                       order_by = "sum")
    expect_equal(mw[, catg1_b], temp[, sum_b])
    
    # integer values unaffected
    DT[, a := as.integer(a)]
    mw <- condition_multiway(DT,
                       categ_col,
                       quant_col)
    
    expect_equal(class(mw$a), "integer")
    
    # detail produces correct columns out
    x <- names(dframe)
    y <- names(condition_multiway(dframe,
                            categ_col,
                            quant_col,
                            detail = TRUE,
                            order_by = "percent",
                            param_col = c("a", "b")))
    expect_equal(
        setdiff(y, x),
        c("catg1_a", "catg1_b", "catg2_a", "catg2_b", 
          "catg1_value", "catg2_value")
    )
    y <- names(condition_multiway(dframe,
                            categ_col,
                            quant_col,
                            detail = TRUE,
                            order_by = "median"))
    expect_equal(
        setdiff(y, x),
        c("catg1_value", "catg2_value")
    )
    y <- names(condition_multiway(dframe,
                            categ_col,
                            quant_col = "a",
                            detail = TRUE,
                            order_by = "sum"))
    expect_equal(
        setdiff(y, x),
        c("catg1_a", "catg2_a")
    )
    y <- names(condition_multiway(dframe,
                            categ_col,
                            quant_col, 
                            detail = TRUE,
                            order_by = "alphabet"))
    expect_equal(sort(x), sort(y))
    
    # order_by "alphabet" correct
    z <- condition_multiway(dframe,
                      categ_col,
                      quant_col = "value",
                      order_by = "alphabet")
    expect_equal(
        levels(z$catg1), 
        sort(unique(catg1), decreasing = TRUE)
    )
    expect_equal(
        levels(z$catg2), 
        sort(unique(catg2), decreasing = TRUE)
    )
    
    # ordering factors does not affect values
    quant_col <- "value"
    x <- condition_multiway(dframe,
                      categ_col,
                      quant_col, 
                      order_by = "alphabet")
    y <- condition_multiway(dframe,
                      categ_col,
                      quant_col,
                      order_by = "median")
    y <- condition_multiway(dframe,
                      categ_col,
                      quant_col,
                      order_by = "sum")
    expect_equal(
        x[, .(a, b, value)], 
        y[, .(a, b, value)] 
    )
    expect_equal(
        y[, .(a, b, value)], 
        z[, .(a, b, value)] 
    )
    invisible(NULL)
}

test_condition_multiway()
