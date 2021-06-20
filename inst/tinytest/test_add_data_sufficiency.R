test_add_data_sufficiency <- function() {

    # usage
    # add_data_sufficiency(dframe
    #                      midfield_term,
    #                      ...,
    #                      details = NULL)

    # Needed for tinytest::build_install_test()
    library("data.table")

    # create answers
    DT <- toy_student[1:10, .(mcid)]
    DT <- add_institution(DT, midfield_term = toy_term)
    DT <- add_timely_term(DT, midfield_term = toy_term)

    # DT_no_details <- add_data_sufficiency(DT,
    #                                       midfield_term = toy_term)
    # DT_with_details <- add_data_sufficiency(DT,
    #                                         midfield_term = toy_term,
    #                                         details = TRUE)
    # cat(wrapr::draw_frame(DT_no_details))
    # cat(wrapr::draw_frame(DT_with_details))

    DT_no_details <- wrapr::build_frame(
        "mcid"         , "institution"  , "timely_term", "data_sufficiency"|
            "MID25783939", "Institution M", "20053"      , TRUE  |
            "MID25784402", "Institution M", "20103"      , FALSE |
            "MID25805538", "Institution M", "20091"      , TRUE  |
            "MID25808099", "Institution M", "19923"      , TRUE  |
            "MID25816437", "Institution M", "20113"      , FALSE |
            "MID25826223", "Institution M", "19913"      , TRUE  |
            "MID25828870", "Institution M", "19933"      , TRUE  |
            "MID25831839", "Institution M", "20123"      , FALSE |
            "MID25839453", "Institution M", "20111"      , FALSE |
            "MID25840802", "Institution M", "19951"      , TRUE  )
    setDT(DT_no_details)

    DT_with_details <- wrapr::build_frame(
        "mcid"         , "institution"  , "timely_term", "inst_limit",
        "data_sufficiency" |
            "MID25783939", "Institution M", "20053"      , "20093"     ,
        TRUE               |
            "MID25784402", "Institution M", "20103"      , "20093"     ,
        FALSE              |
            "MID25805538", "Institution M", "20091"      , "20093"     ,
        TRUE               |
            "MID25808099", "Institution M", "19923"      , "20093"     ,
        TRUE               |
            "MID25816437", "Institution M", "20113"      , "20093"     ,
        FALSE              |
            "MID25826223", "Institution M", "19913"      , "20093"     ,
        TRUE               |
            "MID25828870", "Institution M", "19933"      , "20093"     ,
        TRUE               |
            "MID25831839", "Institution M", "20123"      , "20093"     ,
        FALSE              |
            "MID25839453", "Institution M", "20111"      , "20093"     ,
        FALSE              |
            "MID25840802", "Institution M", "19951"      , "20093"     ,
        TRUE               )
    setDT(DT_with_details)

    # correct answers
    expect_equal(
        DT_no_details,
        add_data_sufficiency(DT, midfield_term = toy_term)
    )
    expect_equal(
        DT_with_details,
        add_data_sufficiency(DT, midfield_term = toy_term, details = TRUE)
    )

    # overwrites existing columns
    expect_equal(
        DT_no_details,
        add_data_sufficiency(DT_no_details, midfield_term = toy_term)
    )
    expect_equal(
        DT_with_details,
        add_data_sufficiency(DT_with_details,
                             midfield_term = toy_term,
                             details = TRUE)
    )

    # midfield_term argument must be term or equivalent
    expect_error(
        add_data_sufficiency(DT, midfield_term = toy_student)
        )

    # dframe argument requires institution and timely_term columns
    col_missing <- copy(DT)[, institution := NULL]
    expect_error(
        add_data_sufficiency(col_missing, midfield_term = toy_term)
        )
    col_missing <- copy(DT)[, timely_term := NULL]
    expect_error(
        add_data_sufficiency(col_missing, midfield_term = toy_term)
        )

    # midfield_term argument requires institution and term columns
    col_missing <- copy(toy_term)[, institution := NULL]
    expect_error(
        add_data_sufficiency(DT, midfield_term = col_missing)
        )
    col_missing <- copy(toy_term)[, term := NULL]
    expect_error(
        add_data_sufficiency(DT, midfield_term = col_missing)
        )

    # data frame arguments must be data frames
    expect_error(
        add_data_sufficiency(DT$mcid, toy_term)
        )
    expect_error(
        add_data_sufficiency(DT, toy_term$term)
        )

    # required arguments must be explicit
    expect_error(
        add_data_sufficiency(NULL, toy_term)
        )
    expect_error(
        add_data_sufficiency(DT, NULL)
        )

    # arguments after ... must be named
    expect_error(
        add_data_sufficiency(DT, toy_term, TRUE) # details not named
        )

    invisible(NULL)
}

test_add_data_sufficiency()






