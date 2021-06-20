test_condition_multiway <- function() {

    # usage
    # condition_multiway(dframe,
    #                    ...,
    #                    details = NULL)

    # Needed for tinytest::build_install_test()
    library("data.table")

    # create a multiway
    catg1 <- rep(c("urban", "rural", "suburb", "village"), each = 2)
    catg2 <- rep(c("men", "women"), times = 4)
    value <- c(0.22, 0.14, 0.43, 0.58, 0.81, 0.46, 0.15, 0.20)
    dframe <- data.frame(catg1, catg2, value)
    mw     <- condition_multiway(dframe)

    # factors converted to characters and then to factors again
    expect_equal(condition_multiway(dframe), condition_multiway(mw))

    # columns have expected class
    expect_equal(class(mw$catg1), "factor")
    expect_equal(class(mw$catg2), "factor")
    expect_equal(class(mw$value), "numeric")

    # input argument class
    expect_error(condition_multiway(catg1))

    # arguments after ... must be named
    expect_error(condition_multiway(dframe, TRUE))

    # details produces correct columns out
    expect_equal(names(condition_multiway(dframe, details = TRUE)),
                 c("catg1", "catg2", "med_catg1", "med_catg2", "value"))
    expect_equal(names(condition_multiway(dframe, details = FALSE)),
                 c("catg1", "catg2", "value"))

    # cat(wrapr::draw_frame(mw))
    # medians correct
    ans <- wrapr::build_frame(
        "catg1"    , "catg2", "med_catg1", "med_catg2", "value" |
            "urban"  , "men"  , 0.18       , 0.325      , 0.22    |
            "urban"  , "women", 0.18       , 0.33       , 0.14    |
            "rural"  , "men"  , 0.505      , 0.325      , 0.43    |
            "rural"  , "women", 0.505      , 0.33       , 0.58    |
            "suburb" , "men"  , 0.635      , 0.325      , 0.81    |
            "suburb" , "women", 0.635      , 0.33       , 0.46    |
            "village", "men"  , 0.175      , 0.325      , 0.15    |
            "village", "women", 0.175      , 0.33       , 0.2     )
    expect_equal(mw$med_catg1, ans$med_catg1)
    expect_equal(mw$med_catg2, ans$med_catg2)

    # incorrect column combinations
    dframe <- data.frame(catg1, catg2, cat3 = paste0(catg1, catg2))
    expect_error(condition_multiway(dframe))

    # integer values converted to numeric
    value <- c(22L, 14L, 43L, 58L, 81L, 46L, 15L, 20L)
    dframe <- data.frame(catg1, catg2, value)
    mw <- condition_multiway(dframe)
    expect_equal(class(mw$catg1), "factor")
    expect_equal(class(mw$catg2), "factor")
    expect_equal(class(mw$value), "numeric")




    invisible(NULL)
}

test_condition_multiway()
