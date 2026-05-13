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
    require("data.table")

    # create case
    # library("midfieldr")
    x <- toy_student[1:10, .(mcid)]
    y <- add_timely_term(x, toy_term)
    # DT <- cat(wrapr::draw_frame(y))
    DT <- wrapr::build_frame(
        "mcid"            , "term_i", "level_i"       , "adj_span", "timely_term" |
            "MCID3111146562", "19881" , "01 First-year" , 6         , "19933"       |
            "MCID3111156062", "19891" , "02 Second-year", 5         , "19933"       |
            "MCID3111159982", "19881" , "01 First-year" , 6         , "19933"       |
            "MCID3111160541", "19881" , "01 First-year" , 6         , "19933"       |
            "MCID3111165512", "19881" , "01 First-year" , 6         , "19933"       |
            "MCID3111165835", "19883" , "02 Second-year", 5         , "19931"       |
            "MCID3111170804", "19883" , "02 Second-year", 5         , "19931"       |
            "MCID3111199777", "19916" , "03 Third-year" , 4         , "19953"       |
            "MCID3111206488", "19893" , "01 First-year" , 6         , "19951"       |
            "MCID3111206737", "19923" , "04 Fourth-year", 3         , "19951"       )
    setDT(DT)
   
    # correct answers, add optional arguments in combinations
    x <- toy_student[1:10, .(mcid)]
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
