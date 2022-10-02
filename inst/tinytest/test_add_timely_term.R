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
    suppressPackageStartupMessages(library("data.table"))

    # create case
    # library("midfieldr")
    # x <- toy_student[1:10, .(mcid)]
    # y <- add_timely_term(x, toy_term)
    # DT <- cat(wrapr::draw_frame(y))
    DT <- wrapr::build_frame(
        "mcid"         , "term_i", "level_i"     , "adj_span", "timely_term" |
            "MID25784187", "19885" , "01 Freshman" , 6         , "19943"       |
            "MID25784974", "19883" , "02 Sophomore", 5         , "19931"       |
            "MID25816209", "19881" , "02 Sophomore", 5         , "19923"       |
            "MID25819358", "19946" , "02 Sophomore", 5         , "19993"       |
            "MID25828870", "19881" , "01 Freshman" , 6         , "19933"       |
            "MID25829749", "19995" , "03 Junior"   , 4         , "20033"       |
            "MID25841418", "19981" , "03 Junior"   , 4         , "20013"       |
            "MID25845197", "19905" , "03 Junior"   , 4         , "19943"       |
            "MID25846316", "19911" , "01 Freshman" , 6         , "19963"       |
            "MID25847220", "19891" , "01 Freshman" , 6         , "19943"       )
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
