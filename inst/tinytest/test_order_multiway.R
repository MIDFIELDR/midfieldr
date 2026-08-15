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
        "catg1"      , "catg2", "a"  , "b"   |
            "urban"  , "men"  , 112  , 153   |
            "urban"  , "women", 214  , 1267  |
            "rural"  , "men"  , 310  , 361   |
            "rural"  , "women", 420  , 1472  |
            "suburb" , "men"  , 513  , 549   |
            "suburb" , "women", 615  , 1646  |
            "village", "men"  , 732  , 766   |
            "village", "women", 814  , 1881)
    DT <- copy(dframe)
    setDT(DT)
    
    # median version
    DT_med <- copy(DT)
    DT_med[, c("b") := NULL]
    setnames(DT_med, old = "a", new = "metric")
    mw_med <- order_multiway(DT_med, 
                             quantity = "metric", 
                             categories = c("catg1", "catg2"), 
                             method = "median")
    
    # percent version
    DT_pct <- copy(DT)
    DT_pct[, metric := round(100 * a / b, 2)]
    setnames(DT_pct, old = c("a", "b"), new = c("num", "den"))
    mw_pct <- order_multiway(DT_pct, 
                             quantity = "metric", 
                             categories = c("catg1", "catg2"), 
                             method = "percent", 
                             ratio_of = c("num", "den"))
    
    # ---------- correct answers
    
    # overwrite prevention works
    x <- copy(DT_med)
    x[, idx := as.character(.I)]
    y <- order_multiway(x, 
                        quantity = "metric", 
                        categories = c("catg1", "catg2"), 
                        method = "median")
    expect_equal(x[["idx"]], y[["idx"]])
    
    x <- copy(DT_pct)
    x[, idx := as.character(.I)]
    y <- order_multiway(x, 
                        quantity = "metric", 
                        categories = c("catg1", "catg2"), 
                        method = "percent", 
                        ratio_of = c("num", "den"))
    expect_equal(x[["idx"]], y[["idx"]])
    
    # categories can be characters or factors
    x <- copy(DT_med)
    y <- mw_med[, 1:3]
    expect_equivalent(
        order_multiway(x,
                       quantity = "metric",
                       categories = c("catg1", "catg2"),
                       method = "median"),
        order_multiway(y,
                       quantity = "metric",
                       categories = c("catg1", "catg2"),
                       method = "median")
    )
    
    x <- copy(DT_pct)
    y <- mw_pct[, 1:5]
    expect_equivalent(
        order_multiway(x, 
                       quantity = "metric", 
                       categories = c("catg1", "catg2"), 
                       method = "percent", 
                       ratio_of = c("num", "den")),
        order_multiway(y, 
                       quantity = "metric", 
                       categories = c("catg1", "catg2"), 
                       method = "percent", 
                       ratio_of = c("num", "den"))
    )
    
    # existing result columns overwritten
    expect_equivalent(
        order_multiway(DT_med,
                       quantity = "metric",
                       categories = c("catg1", "catg2"),
                       method = "median"),
        order_multiway(mw_med,
                       quantity = "metric",
                       categories = c("catg1", "catg2"),
                       method = "median")
    )
    expect_equivalent(
        order_multiway(DT_pct,
                       quantity = "metric", 
                       categories = c("catg1", "catg2"), 
                       method = "percent", 
                       ratio_of = c("num", "den")),
        order_multiway(mw_pct,
                       quantity = "metric", 
                       categories = c("catg1", "catg2"), 
                       method = "percent", 
                       ratio_of = c("num", "den"))
    )

    # columns have expected class
    expect_equal(class(mw_med[["catg1"]]), "factor")
    expect_equal(class(mw_med[["catg2"]]), "factor")
    expect_equal(class(mw_med[["metric"]]), "numeric")
    expect_equal(class(mw_med[["catg1_median"]]), "numeric")
    expect_equal(class(mw_med[["catg2_median"]]), "numeric")
    
    expect_equal(class(mw_pct[["catg1"]]), "factor")
    expect_equal(class(mw_pct[["catg2"]]), "factor")
    expect_equal(class(mw_pct[["metric"]]), "numeric")
    expect_equal(class(mw_pct[["catg1_metric"]]), "numeric")
    expect_equal(class(mw_pct[["catg2_metric"]]), "numeric")
    
    # median method produces correct answers
    x <- DT_med[, catg1_median := median(metric), by = c("catg1")]
    expect_equal(x[, .(catg1_median)], mw_med[, .(catg1_median)])
    
    x <- DT_med[, catg2_median := median(metric), by = c("catg2")]
    expect_equal(x[, .(catg2_median)], mw_med[, .(catg2_median)])
    
    # percent method produces correct answers
    x <- DT_pct[, catg1_metric := round(100 * sum(num) / sum(den), 1), by = "catg1"]
    expect_equal(x[, .(catg1_metric)], mw_pct[, .(catg1_metric)])
    
    x <- DT_pct[, catg2_metric := round(100 * sum(num) / sum(den), 1), by = "catg2"]
    expect_equal(x[, .(catg2_metric)], mw_pct[, .(catg2_metric)])
    
    # NULL method same as median
    expect_equivalent(
        order_multiway(DT_med,
                       quantity = "metric",
                       categories = c("catg1", "catg2")),
        order_multiway(DT_med,
                       quantity = "metric",
                       categories = c("catg1", "catg2"),
                       method = "median")
    )
    
    invisible(NULL)
}

test_order_multiway()



