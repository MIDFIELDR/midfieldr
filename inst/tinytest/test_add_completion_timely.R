test_add_completion_timely <- function() {

    # usage
    # add_completion_timely(dframe,
    #                       midfield_degree,
    #                       ...,
    #                       details = NULL)

    # Needed for tinytest::build_install_test()
    library("data.table")

    # create answers
    DT <- toy_student[1:10, .(mcid)]
    DT <- add_institution(DT, midfield_term = toy_term)
    DT <- add_timely_term(DT, midfield_term = toy_term)

    # DT_no_details <- add_completion_timely(
    #     DT,
    #     midfield_degree = toy_degree
    # )
    # DT_with_details <- add_completion_timely(
    #     DT,
    #     midfield_degree = toy_degree,
    #     details = TRUE
    # )
    # cat(wrapr::draw_frame(DT_no_details))
    # cat(wrapr::draw_frame(DT_with_details))

    DT_no_details <- wrapr::build_frame(
        "mcid"         , "institution"  , "timely_term", "completion_timely"|
            "MID25783939", "Institution M", "20053"      , TRUE  |
            "MID25784402", "Institution M", "20103"      , FALSE |
            "MID25805538", "Institution M", "20091"      , FALSE |
            "MID25808099", "Institution M", "19923"      , TRUE  |
            "MID25816437", "Institution M", "20113"      , FALSE |
            "MID25826223", "Institution M", "19913"      , TRUE  |
            "MID25828870", "Institution M", "19933"      , TRUE  |
            "MID25831839", "Institution M", "20123"      , FALSE |
            "MID25839453", "Institution M", "20111"      , FALSE |
            "MID25840802", "Institution M", "19951"      , TRUE  )
    setDT(DT_no_details)
    DT_with_details <- wrapr::build_frame(
        "mcid"         , "institution"  , "timely_term", "term_degree",
        "completion", "completion_timely" |
            "MID25783939", "Institution M", "20053"      , "20031"      ,
        TRUE        , TRUE                |
            "MID25784402", "Institution M", "20103"      , NA_character_,
        FALSE       , FALSE               |
            "MID25805538", "Institution M", "20091"      , NA_character_,
        FALSE       , FALSE               |
            "MID25808099", "Institution M", "19923"      , "19903"      ,
        TRUE        , TRUE                |
            "MID25816437", "Institution M", "20113"      , NA_character_,
        FALSE       , FALSE               |
            "MID25826223", "Institution M", "19913"      , "19901"      ,
        TRUE        , TRUE                |
            "MID25828870", "Institution M", "19933"      , "19923"      ,
        TRUE        , TRUE                |
            "MID25831839", "Institution M", "20123"      , NA_character_,
        FALSE       , FALSE               |
            "MID25839453", "Institution M", "20111"      , NA_character_,
        FALSE       , FALSE               |
            "MID25840802", "Institution M", "19951"      , "19933"      ,
        TRUE        , TRUE                )
    setDT(DT_with_details)

    # correct answers
    expect_equal(
        DT_no_details,
        add_completion_timely(DT, toy_degree)
    )
    expect_equal(
        DT_with_details,
        add_completion_timely(DT, toy_degree, details = TRUE)
    )

    # overwrites existing columns
    expect_equal(
        DT_no_details,
        add_completion_timely(DT_no_details, toy_degree)
    )
    expect_equal(
        DT_with_details,
        add_completion_timely(DT_with_details,
                             toy_degree,
                             details = TRUE)
    )

    # existing term column (if exists) is not over written
    x <- copy(DT_no_details)
    x[, term := timely_term]
    y <- add_completion_timely(x, toy_degree)
    expect_equal(
        setcolorder(x, colnames(y)),
        y
    )

    # midfield_degree argument must be degree or equivalent
    expect_error(
        add_completion_timely(DT, midfield_degree = toy_student)
    )

    # dframe argument requires ID and timely_term columns
    col_missing <- copy(DT)[, mcid := NULL]
    expect_error(
        add_completion_timely(col_missing, midfield_degree = toy_degree)
    )
    col_missing <- copy(DT)[, timely_term := NULL]
    expect_error(
        add_completion_timely(col_missing, midfield_degree = toy_degree)
    )

    # midfield_degree argument requires ID and term columns
    col_missing <- copy(toy_degree)[, mcid := NULL]
    expect_error(
        add_completion_timely(DT, midfield_degree = col_missing)
    )
    col_missing <- copy(toy_degree)[, term := NULL]
    expect_error(
        add_completion_timely(DT, midfield_degree = col_missing)
    )

    # data frame arguments must be data frames
    expect_error(
        add_completion_timely(DT$mcid, toy_degree)
    )
    expect_error(
        add_completion_timely(DT, toy_degree$term)
    )

    # required arguments must be explicit
    expect_error(
        add_completion_timely(NULL, toy_degree)
    )
    expect_error(
        add_completion_timely(DT, NULL)
    )

    # arguments after ... must be named
    expect_error(
        add_completion_timely(DT, toy_degree, TRUE) # details not named
    )

    invisible(NULL)
}

test_add_completion_timely()

