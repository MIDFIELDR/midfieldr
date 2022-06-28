test_condition_multiway <- function() {
    
    # usage 
    # condition_multiway(dframe,
    #              x,
    #              yy,
    #              ..., 
    #              order_by = NULL,
    #              param_col = NULL)
    
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
            "urban"  , "men"  , 12  , 53 |
            "urban"  , "women", 14  , 67 |
            "rural"  , "men"  , 10  , 61 |
            "rural"  , "women", 20  , 72 |
            "suburb" , "men"  , 13  , 49 |
            "suburb" , "women", 15  , 46 |
            "village", "men"  , 32  , 66 |
            "village", "women", 14  , 81)
    dframe$metric <- round(dframe$a / dframe$b, 2)
    DT <- copy(dframe)
    setDT(DT)
    
    # apply the conditioning function
    x <- c("metric")
    yy <- c("catg1", "catg2")
    mw <- condition_multiway(DT, x, yy)

    
    
    
    
    # Begin tests
    # input can be data.frame or data.table
    expect_equivalent(
        condition_multiway(dframe, x, yy),
        condition_multiway(DT, x, yy)
    )
    # categories can be characters or factors
    expect_equivalent(
        condition_multiway(DT, x, yy),
        condition_multiway(mw[, .(catg1, catg2, a, b, metric)], x, yy)
    )
    # overwrites default median columns
    expect_equivalent(
        condition_multiway(dframe, x, yy),
        condition_multiway(mw, x, yy)
    )
    
    # columns have expected class
    expect_equal(class(mw[, catg1]), "factor")
    expect_equal(class(mw[, catg2]), "factor")
    expect_equal(class(mw[, metric]), "numeric")

    # error when input arguments wrong class, NA, or NULL
    expect_error(condition_multiway(dframe = as.list(dframe), x, yy))
    expect_error(condition_multiway(dframe, as.list(x), yy))
    expect_error(condition_multiway(dframe, x, as.list(yy)))
    expect_error(condition_multiway(dframe = NULL, x, yy))
    expect_error(condition_multiway(dframe, x = NULL, y))
    expect_error(condition_multiway(dframe, x, yy = NULL))
    expect_error(condition_multiway(dframe = NA, x, yy))

    # names specified in arguments are columns in dframe
    expect_error(condition_multiway(dframe, x, yy = c("catg1", NA_character_)))
    expect_error(condition_multiway(dframe, x = NA_character_, yy))
    
    # arguments after ... must be named
    expect_error(condition_multiway(dframe,
                                    x,
                                    yy,
                                    NULL,
                                    param_col = NULL))
    expect_error(condition_multiway(dframe,
                                    x,
                                    yy,
                                    order_by = NULL,
                                    NULL))

    # optional arguments
    expect_error( # order_by = "percent" requires param_col
        condition_multiway(dframe,
                     x,
                     yy,
                     order_by = "percent",
                     param_col = NULL)
    )
    expect_error( # param_col must be numeric
        condition_multiway(dframe,
                     x,
                     yy,
                     order_by = "percent",
                     param_col = c("catg1", "catg2"))
    )
    # optional arguments. NULL method same as median
    expect_equal(
        condition_multiway(dframe,
                           x,
                           yy,
                           order_by = "median",
                           param_col = NULL),
        condition_multiway(dframe,
                           x,
                           yy,
                           order_by = NULL,
                           param_col = NULL)
    )
    # optional arguments. order_by median correct
    mw <- condition_multiway(dframe,
                             x,
                             yy,
                             order_by = "median",
                             param_col = NULL)
    temp <- copy(DT)
    temp[, col_check := stats::median(metric, na.rm = TRUE), by = catg1]
    expect_equal(mw[, catg1_metric], temp[, col_check])
    
    temp[, col_check := stats::median(metric, na.rm = TRUE), by = catg2]
    expect_equal(mw[, catg2_metric], temp[, col_check])
    
    # optional arguments. order_by mean correct
    mw <- condition_multiway(dframe,
                             x,
                             yy,
                             order_by = "mean",
                             param_col = NULL)
    temp <- copy(DT)
    temp[, col_check := mean(metric, na.rm = TRUE), by = catg1]
    expect_equal(mw[, catg1_metric], temp[, col_check])
    
    temp[, col_check := mean(metric, na.rm = TRUE), by = catg2]
    expect_equal(mw[, catg2_metric], temp[, col_check])
    
    # optional arguments. order_by percent correct
    mw <- condition_multiway(dframe,
                             x,
                             yy,
                             order_by = "percent",
                             param_col = c("a", "b"))
    
    temp <- copy(DT)
    temp[, sum_a := sum(a, na.rm = TRUE), by = catg1]
    temp[, sum_b := sum(b, na.rm = TRUE), by = catg1]
    temp[, chk_ratio := round(100 * sum_a / sum_b, 1), by = catg1]
    expect_equal(mw[, catg1_metric], temp[, chk_ratio])
    
    temp[, sum_a := sum(a, na.rm = TRUE), by = catg2]
    temp[, sum_b := sum(b, na.rm = TRUE), by = catg2]
    temp[, chk_ratio := round(100 * sum_a / sum_b, 1), by = catg2]
    expect_equal(mw[, catg2_metric], temp[, chk_ratio])
    
    # warning when param_col but order_by is not "percent" 
    expect_warning(condition_multiway(dframe, x, yy, param_col = c("a", "b")))
    
    # optional arguments. order_by sum correct, when x is the "a" column
    mw <- condition_multiway(dframe,
                             x = "a",
                             yy, 
                             order_by = "sum")
    temp <- copy(DT)
    temp[, sum_a := sum(a, na.rm = TRUE), by = catg1]
    temp[, sum_b := sum(b, na.rm = TRUE), by = catg1]
    expect_equal(mw[, catg1_a], temp[, sum_a])
    mw <- condition_multiway(dframe,
                             x = "b",
                             yy,
                             order_by = "sum")
    expect_equal(mw[, catg1_b], temp[, sum_b])
    
    # integer metrics unaffected
    DT[, a := as.integer(a)]
    mw <- condition_multiway(DT, x, yy)
    expect_equal(class(mw$a), "integer")
    
    # order_by "alphabet" correct
    z <- condition_multiway(dframe,
                            x,
                            yy,
                            order_by = "alphabet")
    expect_equal(
        as.character(z$catg1),
        sort(dframe$catg1, decreasing = TRUE)
    )
    expect_equal(
        as.character(z$catg2),
        rev(dframe$catg2)
    )

    # ordering factors does not affect metric values
    p <- condition_multiway(dframe,
                      x,
                      yy,
                      order_by = "alphabet")
    s <- p[, .(catg1, catg2, metric)]
    q <- condition_multiway(dframe,
                      x,
                      yy,
                      order_by = "median")
    r <- condition_multiway(dframe,
                      x,
                      yy, 
                      order_by = "sum")
    u <- condition_multiway(dframe,
                            x,
                            yy,
                            order_by = "percent", 
                            param_col = c("a", "b"))
    # Use left outer join into s
    expect_equal(
        s, 
        p[s, .(catg1, catg2, metric), on = c("catg1", "catg2")]
    )
    expect_equal(
        s, 
        q[s, .(catg1, catg2, metric), on = c("catg1", "catg2")]
    )
    expect_equal(
        s, 
        r[s, .(catg1, catg2, metric), on = c("catg1", "catg2")]
    )
    expect_equal(
        s, 
        u[s, .(catg1, catg2, metric), on = c("catg1", "catg2")]
    )
    
    
    
    
    invisible(NULL)
}

test_condition_multiway()



