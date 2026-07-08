test_order_multiway <- function() {
    
    # usage 
    # order_multiway(dframe,
    #              quantity,
    #              categories,
    #              ..., 
    #              method = NULL,
    #              ratio_of = NULL)
    
    # Needed for tinytest::build_install_test()
    # library(tinytest, checkmate)
    suppressPackageStartupMessages(require("data.table"))
    
    # create a multiway data.frame
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
    DT <- copy(dframe)
    setDT(DT)
    DT[, pct := round(a / b, 2)]
    
    # apply the conditioning function
    mw_med <- order_multiway(DT, 
                             quantity = "a", 
                             categories = c("catg1", "catg2"), 
                             method = "median")
    mw_pct <- order_multiway(DT, 
                             quantity = "pct", 
                             categories = c("catg1", "catg2"), 
                             method = "percent", 
                             ratio_of = c("a", "b"))
    
    # Begin tests
    # input can be data.frame or data.table
    # expect_equivalent(
    #     as.data.frame(mw_med),
    #     order_multiway(dframe,
    #                    quantity = "a",
    #                    categories = c("catg1", "catg2"),
    #                    method = "median")
    # )
    
    # categories can be characters or factors
    expect_equivalent(
        order_multiway(DT[, .(catg1, catg2, a)],
                       quantity = "a", 
                       categories = c("catg1", "catg2"), 
                       method = "median"), 
        order_multiway(mw_med[, .(catg1, catg2, a)],
                       quantity = "a", 
                       categories = c("catg1", "catg2"), 
                       method = "median")
    )
    
    # overwrites default median columns
    expect_equivalent(
        order_multiway(DT,
                       quantity = "a", 
                       categories = c("catg1", "catg2"), 
                       method = "median"), 
        order_multiway(mw_med,
                       quantity = "a", 
                       categories = c("catg1", "catg2"), 
                       method = "median")
    )
    
    # columns have expected class
    expect_equal(class(mw_med[["catg1"]]), "factor")
    expect_equal(class(mw_med[["catg2"]]), "factor")
    expect_equal(class(mw_med[["a"]]), "numeric")
    expect_equal(class(mw_med[["catg1_median"]]), "numeric")
    expect_equal(class(mw_med[["catg2_median"]]), "numeric")
    
    
    # error when input arguments wrong class, NA, or NULL
    p <- "a"
    q <- c("catg1", "catg2")
    expect_error(order_multiway(as.list(dframe), p, q))
    expect_error(order_multiway(dframe, as.list(p), q))
    expect_error(order_multiway(dframe, p, as.list(q)))
    expect_error(order_multiway(NULL, p, q))
    expect_error(order_multiway(dframe, NULL, q))
    expect_error(order_multiway(dframe, p, NULL))
    expect_error(order_multiway(NA, p, q))
    
    # names specified in arguments are columns in dframe
    p <- "a"
    q <- c("catg1", "catg2")
    expect_error(order_multiway(dframe, p, c("catg1", NA_character_)))
    expect_error(order_multiway(dframe, NA_character_, q))
    
    # arguments after ... must be named
    p <- "pct"
    q <- c("catg1", "catg2")
    expect_error(order_multiway(dframe,
                                p,
                                q,
                                NULL,
                                ratio_of = NULL))
    expect_error(order_multiway(dframe,
                                p, 
                                q,
                                method = NULL,
                                NULL))
    
    # percent method requires ratio_of
    p <- "pct"
    q <- c("catg1", "catg2")
    expect_error( 
        order_multiway(dframe,
                       p,
                       q,
                       method = "percent",
                       ratio_of = NULL)
    )
    # ratio_of must be numeric
    expect_error( 
        order_multiway(dframe,
                       p,
                       q,
                       method = "percent",
                       ratio_of = c("catg1", "catg2"))
    )
    
    # optional arguments. NULL method same as median
    p <- "a"
    q <- c("catg1", "catg2")
    expect_equal(
        order_multiway(dframe,
                       p,
                       q,
                       method = "median",
                       ratio_of = NULL),
        order_multiway(dframe,
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
    # (order_multiway rounds to one place)
    temp <- DT[, lapply(.SD, sum), .SDcols = c("a", "b"), by = c("catg1")]
    temp[, catg1_pct := round(100 * a / b, 1)]
    expect_equal(
        temp[, .(catg1_pct)], 
        unique(mw_pct[, .(catg1_pct)])
    )
    temp <- DT[, lapply(.SD, sum), .SDcols = c("a", "b"), by = c("catg2")]
    temp[, catg2_pct := round(100 * a / b, 1)]
    expect_equal(
        temp[, .(catg2_pct)], 
        unique(mw_pct[, .(catg2_pct)])
    )
    
    # warning when ratio_of but method is not "percent" 
    p <- "pct"
    q <- c("catg1", "catg2")
    expect_warning(order_multiway(DT, 
                                  p, 
                                  q, 
                                  method = "median",
                                  ratio_of = c("a", "b")))
    
    # integer metrics made double
    p <- "a"
    q <- c("catg1", "catg2")
    temp <- copy(DT)
    temp[, a := as.integer(a)]
    temp <- order_multiway(temp, p, q)
    expect_equal(class(temp$a), "numeric")
    
    # ordering factors does not affect numeric columns
    # inner join to check results
    # median method
    u <- order_multiway(DT,
                        quantity = "a",
                        categories = c("catg1", "catg2"))
    u <- u[, .(catg1, catg2, a)]
    u[, `:=`(catg1 = as.character(catg1), catg2 = as.character(catg2))]
    v <- u[dframe, .(catg1, catg2, a), on = c("catg1", "catg2"), nomatch = NULL]
    expect_equal(u, v)
    
    # percent method
    u <- order_multiway(DT,
                        quantity = "pct",
                        categories = c("catg1", "catg2"),
                        method = "percent",
                        ratio_of = c("a", "b"))
    u <- u[, .(catg1, catg2, pct)]
    u[, `:=`(catg1 = as.character(catg1), catg2 = as.character(catg2))]
    v <- u[dframe, .(catg1, catg2, pct), on = c("catg1", "catg2"), nomatch = NULL]
    expect_equal(u, v)
    
    invisible(NULL)
}

test_order_multiway()



