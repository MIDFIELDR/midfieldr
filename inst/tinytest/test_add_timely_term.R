
# functions used in the test

run_check <- function(x, y, fnc) {
    
    z <- fnc(x, y)
    expect_equal(class(x), class(z))
    
    rm(z)
}

expect_class_preserved <- function(df1, df2, fnc) {
    
    x <- copy(df1)
    y <- copy(df2)
    
    x <- as.data.frame(x)
    y <- as.data.frame(y)
    run_check(x, y, fnc)
    
    setattr(x, "class", c("tbl_df", "tbl", "data.frame"))
    setattr(y, "class", c("tbl_df", "tbl", "data.frame"))
    run_check(x, y, fnc)
    
    x <- as.data.table(x)
    y <- as.data.table(y)
    run_check(x, y, fnc)
    
    rm(x, y)
}

test_add_timely_term <- function() {

    # usage
    # add_timely_term(
    #     dframe,
    #     midfield_term = term,
    #     ...,
    #     span = NULL,
    #     sched_span = NULL
    # )

    # Needed for tinytest::build_install_test()
    suppressPackageStartupMessages(require("data.table"))
    

    # create case
    # library("midfieldr")
    # 
    x <- toy_student[11:20, .(mcid)]
    y <- add_timely_term(x, toy_term)
    
    # DT <- cat(wrapr::draw_frame(y))
    
    
    DT <- wrapr::build_frame(
        "mcid"            , "term_i", "level_i"      , "adj_span", "timely_term" |
            "MCID3111253227", "19901" , "01 First-year", 6         , "19953"       |
            "MCID3111258790", "19901" , "01 First-year", 6         , "19953"       |
            "MCID3111263510", "19901" , "01 First-year", 6         , "19953"       |
            "MCID3111272687", "19901" , "01 First-year", 6         , "19953"       |
            "MCID3111282492", "19904" , "01 First-year", 6         , "19963"       |
            "MCID3111304195", "19911" , "01 First-year", 6         , "19963"       |
            "MCID3111315508", "19911" , "01 First-year", 6         , "19963"       |
            "MCID3111316435", "19911" , "01 First-year", 6         , "19963"       |
            "MCID3111316936", "19911" , "01 First-year", 6         , "19963"       |
            "MCID3111354376", "19921" , "01 First-year", 6         , "19973"       )
    setDT(DT)
   
    
    
    # ---------- start tests
    
    # check that class is preserved function
    expect_class_preserved(x, toy_term, add_timely_term)
    
    
    
    # correct answers, add optional arguments in combinations
    x <- toy_student[11:20, .(mcid)]
    # without detail
    expect_equal(
        DT,
        add_timely_term(x, toy_term)
    )
    expect_equal(
        DT,
        add_timely_term(x, toy_term, span = 6)
    )

    # arguments must be data frames
    expect_error(add_timely_term(toy_student$mcid, toy_term))
    expect_error(add_timely_term(toy_student[, mcid], toy_term$term))

    # arguments after ... must be named
    expect_error(add_timely_term(x,
                                 toy_term,
                                 detail = FALSE,
                                 6)) # span not named

    # optional arguments are specific types
    expect_error(
        add_timely_term(x, toy_term, span = TRUE)
    )

    # optional arguments, NA same as NULL
    expect_equal(
        add_timely_term(x, toy_term, span = 6),
        add_timely_term(x, toy_term, span = NA)
    )

    # span must be >=  sched_span
    expect_error(
        add_timely_term(x, toy_term, span = 2)
    )
    expect_error(
        add_timely_term(x, toy_term, span = 0, sched_span = 1)
    )

    invisible(NULL)
}

test_add_timely_term()
