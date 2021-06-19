test_add_timely_term <- function() {

    # add_timely_term <- function(dframe,
    #                             midfield_term,
    #                             ...,
    #                             details = NULL,
    #                             span = NULL)

    library("midfieldr")
    library("data.table")
    options(datatable.print.class = TRUE)

    # create case
    # x <- toy_student[1:10, .(mcid)]
    # y <- add_timely_term(x, toy_term, details = TRUE)
    # DTout <- cat(wrapr::draw_frame(y))
    DT_details <- wrapr::build_frame(
        "mcid"         , "term_i", "level_i"     , "adj_span", "timely_term" |
            "MID25783939", "20031" , "04 Senior"   , 3         , "20053"       |
            "MID25784402", "20081" , "04 Senior"   , 3         , "20103"       |
            "MID25805538", "20043" , "02 Sophomore", 5         , "20091"       |
            "MID25808099", "19871" , "01 Freshman" , 6         , "19923"       |
            "MID25816437", "20071" , "02 Sophomore", 5         , "20113"       |
            "MID25826223", "19885" , "04 Senior"   , 3         , "19913"       |
            "MID25828870", "19881" , "01 Freshman" , 6         , "19933"       |
            "MID25831839", "20081" , "02 Sophomore", 5         , "20123"       |
            "MID25839453", "20083" , "04 Senior"   , 3         , "20111"       |
            "MID25840802", "19913" , "03 Junior"   , 4         , "19951"       )
    setDT(DT_details)
    DT_no_details <- copy(DT_details)[, c("term_i", "level_i", "adj_span") := NULL]

    # correct answers, add optional arguments in combinations
    x <- toy_student[1:10, .(mcid)]
    # without details
    expect_equal(
        DT_no_details,
        add_timely_term(x, toy_term)
    )
    expect_equal(
        DT_no_details,
        add_timely_term(x, toy_term, span = 6)
    )
    expect_equal(
        DT_no_details,
        add_timely_term(x, toy_term, details = NULL, span = NULL)
    )
    # with details
    expect_equal(
        DT_details,
        add_timely_term(x, toy_term, details = TRUE)
    )
    expect_equal(
        DT_details,
        add_timely_term(x, toy_term, details = TRUE, span = 6)
    )

    # arguments must be data frames
    expect_error(add_timely_term(toy_student$mcid, toy_term))
    expect_error(add_timely_term(toy_student[, mcid], toy_term$term))

    # arguments after ... must be named
    expect_error(add_timely_term(x,
                                 toy_term,
                                 TRUE)) # details not named
    expect_error(add_timely_term(x,
                                 toy_term,
                                 details = FALSE,
                                 6)) # span not named

    # details must be true or false
    expect_error(
        add_timely_term(x, toy_term, details = 1)
        )
    expect_error(
        add_timely_term(x, toy_term, details = NA)
    )

    # relationships between span and sched_span
    expect_error(
        add_timely_term(x, toy_term, span = NA)
    )
    expect_error(
        add_timely_term(x, toy_term, span = 2)
    )
    expect_error(
        add_timely_term(x, toy_term, span = 0, sched_span = 1)
    )

    invisible(NULL)
}

test_add_timely_term()
