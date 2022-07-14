test_condition_multiway <- function() {
    
    # usage 
    # condition_multiway(dframe,
    #              x,
    #              yy,
    #              ..., 
    #              order_by = NULL,
    #              param_col = NULL)
    
    # when running internal checks 
    # library("tinytest")
    
    # Needed for tinytest::build_install_test()
    suppressMessages(library("data.table"))
    options(
        datatable.print.nrows = 8,
        datatable.print.topn = 8,
        datatable.print.class = TRUE
    )
    
    # create a multiway
    dframe <- wrapr::build_frame(
        "catg1"    , "catg2", "a", "b"   |
            "urban"  , "men"  , 112  , 153 |
            "urban"  , "women", 214  , 1267 |
            "rural"  , "men"  , 310  , 361 |
            "rural"  , "women", 420  , 1472 |
            "suburb" , "men"  , 513  , 549 |
            "suburb" , "women", 615  , 1646 |
            "village", "men"  , 732  , 766 |
            "village", "women", 814  , 1881)
    dframe$metric <- round(dframe$a / dframe$b, 2)
    DT <- copy(dframe)
    setDT(DT)
    
    # apply the conditioning function
    mw_med <- condition_multiway(DT, 
                                 x = "a", 
                                 yy = c("catg1", "catg2"), 
                                 order_by = "median")
    mw_pct <- condition_multiway(DT, 
                                 x = "metric", 
                                 yy = c("catg1", "catg2"), 
                                 order_by = "percent", 
                                 param_col = c("a", "b"))
    
    # Begin tests
    # input can be data.frame or data.table
    expect_equivalent(
        mw_med, 
        condition_multiway(dframe,
                           x = "a", 
                           yy = c("catg1", "catg2"), 
                           order_by = "median")
    )
    
    # categories can be characters or factors
    expect_equivalent(
        condition_multiway(DT[, .(catg1, catg2, a)],
                           x = "a", 
                           yy = c("catg1", "catg2"), 
                           order_by = "median"), 
        condition_multiway(mw_med[, .(catg1, catg2, a)],
                           x = "a", 
                           yy = c("catg1", "catg2"), 
                           order_by = "median")
    )
    
    # overwrites default median columns
    expect_equivalent(
        condition_multiway(DT,
                           x = "a", 
                           yy = c("catg1", "catg2"), 
                           order_by = "median"), 
        condition_multiway(mw_med,
                           x = "a", 
                           yy = c("catg1", "catg2"), 
                           order_by = "median")
    )
    
    # columns have expected class
    expect_equal(class(mw_med[, catg1]), "factor")
    expect_equal(class(mw_med[, catg2]), "factor")
    expect_equal(class(mw_med[, a]), "numeric")
    expect_equal(class(mw_med[, b]), "numeric")
    expect_equal(class(mw_med[, metric]), "numeric")
    
    # error when input arguments wrong class, NA, or NULL
    p <- "a"
    q <- c("catg1", "catg2")
    expect_error(condition_multiway(as.list(dframe), p, q))
    expect_error(condition_multiway(dframe, as.list(p), q))
    expect_error(condition_multiway(dframe, p, as.list(q)))
    expect_error(condition_multiway(NULL, p, q))
    expect_error(condition_multiway(dframe, NULL, q))
    expect_error(condition_multiway(dframe, p, NULL))
    expect_error(condition_multiway(NA, p, q))
    
    # names specified in arguments are columns in dframe
    p <- "a"
    q <- c("catg1", "catg2")
    expect_error(condition_multiway(dframe, p, c("catg1", NA_character_)))
    expect_error(condition_multiway(dframe, NA_character_, q))
    
    # arguments after ... must be named
    p <- "metric"
    q <- c("catg1", "catg2")
    expect_error(condition_multiway(dframe,
                                    p,
                                    q,
                                    NULL,
                                    param_col = NULL))
    expect_error(condition_multiway(dframe,
                                    p, 
                                    q,
                                    order_by = NULL,
                                    NULL))
    
    # percent method requires param_col
    p <- "metric"
    q <- c("catg1", "catg2")
    expect_error( 
        condition_multiway(dframe,
                           p,
                           q,
                           order_by = "percent",
                           param_col = NULL)
    )
    # param_col must be numeric
    expect_error( 
        condition_multiway(dframe,
                           p,
                           q,
                           order_by = "percent",
                           param_col = c("catg1", "catg2"))
    )
    
    # optional arguments. NULL method same as median
    p <- "a"
    q <- c("catg1", "catg2")
    expect_equal(
        condition_multiway(dframe,
                           p,
                           q,
                           order_by = "median",
                           param_col = NULL),
        condition_multiway(dframe,
                           p,
                           q,
                           order_by = NULL,
                           param_col = NULL)
    )
    
    # median method produces correct answers
    temp <- DT[, lapply(.SD, median), .SDcols = c("a"), by = c("catg1")]
    setnames(temp, "a", "catg1_median")
    expect_equal(
        temp[, .(catg1_median)], 
        unique(mw_med[, .(catg1_median)])
    )
    temp <- DT[, lapply(.SD, median), .SDcols = c("a"), by = c("catg2")]
    setnames(temp, "a", "catg2_median")
    expect_equal(
        temp[, .(catg2_median)], 
        unique(mw_med[, .(catg2_median)])
    )
    
    # percent method produces correct answers 
    # (condition_multiway rounds to one place)
    temp <- DT[, lapply(.SD, sum), .SDcols = c("a", "b"), by = c("catg1")]
    temp[, catg1_metric := round(100 * a / b, 1)]
    expect_equal(
        temp[, .(catg1_metric)], 
        unique(mw_pct[, .(catg1_metric)])
    )
    temp <- DT[, lapply(.SD, sum), .SDcols = c("a", "b"), by = c("catg2")]
    temp[, catg2_metric := round(100 * a / b, 1)]
    expect_equal(
        temp[, .(catg2_metric)], 
        unique(mw_pct[, .(catg2_metric)])
    )

    # warning when param_col but order_by is not "percent" 
    p <- "metric"
    q <- c("catg1", "catg2")
    expect_warning(condition_multiway(dframe, 
                                      p, 
                                      q, 
                                      order_by = "median",
                                      param_col = c("a", "b")))
    
    # integer metrics unaffected
    p <- "a"
    q <- c("catg1", "catg2")
    temp <- copy(DT)
    temp[, a := as.integer(a)]
    temp <- condition_multiway(temp, p, q)
    expect_equal(class(temp$a), "integer")

    # ordering factors does not affect numeric columns
    # inner join to check results
    # median method
    u <- condition_multiway(dframe, 
                            x = "a", 
                            yy = c("catg1", "catg2"))
    u <- u[, .(catg1, catg2, a)]
    u[, `:=`(catg1 = as.character(catg1), catg2 = as.character(catg2))]
    v <- u[dframe, .(catg1, catg2, a), on = c("catg1", "catg2"), nomatch = NULL]
    expect_equal(u, v)
    
    # percent metod
    u <- condition_multiway(dframe, 
                            x = "metric", 
                            yy = c("catg1", "catg2"), 
                            order_by = "percent", 
                            param_col = c("a", "b"))
    u <- u[, .(catg1, catg2, metric)]
    u[, `:=`(catg1 = as.character(catg1), catg2 = as.character(catg2))]
    v <- u[dframe, .(catg1, catg2, metric), on = c("catg1", "catg2"), nomatch = NULL]
    expect_equal(u, v)

    invisible(NULL)
}

test_condition_multiway()



