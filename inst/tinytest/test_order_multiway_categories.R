test_order_multiway_categories <- function() {
    
    # usage 
    # order_multiway_categories(dframe,
    #              quantity,
    #              categories,
    #              ..., 
    #              method = NULL,
    #              ratio_of = NULL)
    
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
    mw_med <- order_multiway_categories(DT, 
                                 quantity = "a", 
                                 categories = c("catg1", "catg2"), 
                                 method = "median")
    mw_pct <- order_multiway_categories(DT, 
                                 quantity = "metric", 
                                 categories = c("catg1", "catg2"), 
                                 method = "percent", 
                                 ratio_of = c("a", "b"))
    
    # Begin tests
    # input can be data.frame or data.table
    expect_equivalent(
        mw_med, 
        order_multiway_categories(dframe,
                           quantity = "a", 
                           categories = c("catg1", "catg2"), 
                           method = "median")
    )
    
    # categories can be characters or factors
    expect_equivalent(
        order_multiway_categories(DT[, .(catg1, catg2, a)],
                           quantity = "a", 
                           categories = c("catg1", "catg2"), 
                           method = "median"), 
        order_multiway_categories(mw_med[, .(catg1, catg2, a)],
                           quantity = "a", 
                           categories = c("catg1", "catg2"), 
                           method = "median")
    )
    
    # overwrites default median columns
    expect_equivalent(
        order_multiway_categories(DT,
                           quantity = "a", 
                           categories = c("catg1", "catg2"), 
                           method = "median"), 
        order_multiway_categories(mw_med,
                           quantity = "a", 
                           categories = c("catg1", "catg2"), 
                           method = "median")
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
    expect_error(order_multiway_categories(as.list(dframe), p, q))
    expect_error(order_multiway_categories(dframe, as.list(p), q))
    expect_error(order_multiway_categories(dframe, p, as.list(q)))
    expect_error(order_multiway_categories(NULL, p, q))
    expect_error(order_multiway_categories(dframe, NULL, q))
    expect_error(order_multiway_categories(dframe, p, NULL))
    expect_error(order_multiway_categories(NA, p, q))
    
    # names specified in arguments are columns in dframe
    p <- "a"
    q <- c("catg1", "catg2")
    expect_error(order_multiway_categories(dframe, p, c("catg1", NA_character_)))
    expect_error(order_multiway_categories(dframe, NA_character_, q))
    
    # arguments after ... must be named
    p <- "metric"
    q <- c("catg1", "catg2")
    expect_error(order_multiway_categories(dframe,
                                    p,
                                    q,
                                    NULL,
                                    ratio_of = NULL))
    expect_error(order_multiway_categories(dframe,
                                    p, 
                                    q,
                                    method = NULL,
                                    NULL))
    
    # percent method requires ratio_of
    p <- "metric"
    q <- c("catg1", "catg2")
    expect_error( 
        order_multiway_categories(dframe,
                           p,
                           q,
                           method = "percent",
                           ratio_of = NULL)
    )
    # ratio_of must be numeric
    expect_error( 
        order_multiway_categories(dframe,
                           p,
                           q,
                           method = "percent",
                           ratio_of = c("catg1", "catg2"))
    )
    
    # optional arguments. NULL method same as median
    p <- "a"
    q <- c("catg1", "catg2")
    expect_equal(
        order_multiway_categories(dframe,
                           p,
                           q,
                           method = "median",
                           ratio_of = NULL),
        order_multiway_categories(dframe,
                           p,
                           q,
                           method = NULL,
                           ratio_of = NULL)
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
    # (order_multiway_categories rounds to one place)
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

    # warning when ratio_of but method is not "percent" 
    p <- "metric"
    q <- c("catg1", "catg2")
    expect_warning(order_multiway_categories(dframe, 
                                      p, 
                                      q, 
                                      method = "median",
                                      ratio_of = c("a", "b")))
    
    # integer metrics unaffected
    p <- "a"
    q <- c("catg1", "catg2")
    temp <- copy(DT)
    temp[, a := as.integer(a)]
    temp <- order_multiway_categories(temp, p, q)
    expect_equal(class(temp$a), "integer")

    # ordering factors does not affect numeric columns
    # inner join to check results
    # median method
    u <- order_multiway_categories(dframe, 
                            quantity = "a", 
                            categories = c("catg1", "catg2"))
    u <- u[, .(catg1, catg2, a)]
    u[, `:=`(catg1 = as.character(catg1), catg2 = as.character(catg2))]
    v <- u[dframe, .(catg1, catg2, a), on = c("catg1", "catg2"), nomatch = NULL]
    expect_equal(u, v)
    
    # percent method
    u <- order_multiway_categories(dframe, 
                            quantity = "metric", 
                            categories = c("catg1", "catg2"), 
                            method = "percent", 
                            ratio_of = c("a", "b"))
    u <- u[, .(catg1, catg2, metric)]
    u[, `:=`(catg1 = as.character(catg1), catg2 = as.character(catg2))]
    v <- u[dframe, .(catg1, catg2, metric), on = c("catg1", "catg2"), nomatch = NULL]
    expect_equal(u, v)

    invisible(NULL)
}

test_order_multiway_categories()



