test_add_data_sufficiency <- function() {

    # usage
    # add_data_sufficiency(dframe, midfield_term = term)

    # Needed for tinytest::build_install_test()
    suppressPackageStartupMessages(library("data.table"))

    # create answers
    library(midfieldr)
    dframe <- toy_student[1:10, .(mcid)]
    dframe <- add_timely_term(dframe, midfield_term = toy_term)
    dframe <- add_data_sufficiency(dframe, midfield_term = toy_term)
    # cat(wrapr::draw_frame(dframe))

    DT <- wrapr::build_frame(
        "mcid"         , "level_i"     , "adj_span", "timely_term", "term_i", "lower_limit", "upper_limit", "data_sufficiency" |
            "MID25784187", "01 Freshman" , 6         , "19943"      , "19885" , "19881"      , "19995"      , "include"          |
            "MID25784974", "02 Sophomore", 5         , "19931"      , "19883" , "19881"      , "19995"      , "include"          |
            "MID25816209", "02 Sophomore", 5         , "19923"      , "19881" , "19881"      , "19995"      , "exclude-lower"    |
            "MID25819358", "02 Sophomore", 5         , "19993"      , "19946" , "19881"      , "19995"      , "include"          |
            "MID25828870", "01 Freshman" , 6         , "19933"      , "19881" , "19881"      , "19995"      , "exclude-lower"    |
            "MID25829749", "03 Junior"   , 4         , "20033"      , "19995" , "19881"      , "19995"      , "exclude-upper"    |
            "MID25841418", "03 Junior"   , 4         , "20013"      , "19981" , "19881"      , "19995"      , "exclude-upper"    |
            "MID25845197", "03 Junior"   , 4         , "19943"      , "19905" , "19881"      , "19995"      , "include"          |
            "MID25846316", "01 Freshman" , 6         , "19963"      , "19911" , "19881"      , "19995"      , "include"          |
            "MID25847220", "01 Freshman" , 6         , "19943"      , "19891" , "19881"      , "19995"      , "include"          )
    setDT(DT)

    # correct answers
    expect_equal(
        DT,
        add_data_sufficiency(dframe, midfield_term = toy_term)
    )

    # overwrites existing columns
    expect_equal(
        DT,
        add_data_sufficiency(DT, midfield_term = toy_term)
    )

    # midfield_term argument must be term or equivalent
    expect_error(
        add_data_sufficiency(DT, midfield_term = toy_student)
        )

    # dframe argument requires institution and timely_term columns
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

    invisible(NULL)
}

test_add_data_sufficiency()






