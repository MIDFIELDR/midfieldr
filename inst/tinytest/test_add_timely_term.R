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
    # 
    x <- toy_student[1:10, .(mcid)]
    y <- add_timely_term(x, toy_term)
    
    # DT <- cat(wrapr::draw_frame(y))
    
    
    DT <- wrapr::build_frame(
        "mcid"            , "term_i", "level_i"      , "adj_span", "timely_term" |
            "MCID3111145992", "19881" , "01 First-year", 6         , "19933"       |
            "MCID3111159270", "19881" , "01 First-year", 6         , "19933"       |
            "MCID3111160219", "19881" , "01 First-year", 6         , "19933"       |
            "MCID3111160513", "19881" , "01 First-year", 6         , "19933"       |
            "MCID3111162677", "19881" , "01 First-year", 6         , "19933"       |
            "MCID3111164287", "19881" , "01 First-year", 6         , "19933"       |
            "MCID3111166148", "19881" , "01 First-year", 6         , "19933"       |
            "MCID3111170298", "19881" , "01 First-year", 6         , "19933"       |
            "MCID3111170338", "19881" , "01 First-year", 6         , "19933"       |
            "MCID3111213943", "19891" , "01 First-year", 6         , "19943"       )
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
