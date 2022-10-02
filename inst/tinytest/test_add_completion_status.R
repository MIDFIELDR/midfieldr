test_add_completion_status <- function() {

    # usage
    # add_completion_status(dframe, midfield_degree = degree)

    # Needed for tinytest::build_install_test()
    suppressPackageStartupMessages(library("data.table"))

    # create answers
    dframe <- toy_student[1:10, .(mcid)]
    dframe <- add_timely_term(dframe, midfield_term = toy_term)
    
    # DT <- add_completion_status(dframe, midfield_degree = toy_degree)
    # cat(wrapr::draw_frame(DT))

    DT <- wrapr::build_frame(
        "mcid"         , "term_i", "level_i"     , "adj_span", "timely_term", "term_degree"  , "completion_status" |
            "MID25784187", "19885" , "01 Freshman" , 6         , "19943"      , "19946"      , "late"              |
            "MID25784974", "19883" , "02 Sophomore", 5         , "19931"      , NA_character_, NA_character_       |
            "MID25816209", "19881" , "02 Sophomore", 5         , "19923"      , NA_character_, NA_character_       |
            "MID25819358", "19946" , "02 Sophomore", 5         , "19993"      , "19963"      , "timely"            |
            "MID25828870", "19881" , "01 Freshman" , 6         , "19933"      , "19923"      , "timely"            |
            "MID25829749", "19995" , "03 Junior"   , 4         , "20033"      , NA_character_, NA_character_       |
            "MID25841418", "19981" , "03 Junior"   , 4         , "20013"      , "19993"      , "timely"            |
            "MID25845197", "19905" , "03 Junior"   , 4         , "19943"      , "19921"      , "timely"            |
            "MID25846316", "19911" , "01 Freshman" , 6         , "19963"      , "19951"      , "timely"            |
            "MID25847220", "19891" , "01 Freshman" , 6         , "19943"      , "19933"      , "timely"            )
    setDT(DT)

    # correct answers
    expect_equal(
        DT,
        add_completion_status(dframe, toy_degree)
    )

    # overwrites existing columns
    expect_equal(
        DT,
        add_completion_status(DT, toy_degree)
    )


    # midfield_degree argument must be degree or equivalent
    expect_error(
        add_completion_status(DT, midfield_degree = toy_student)
    )

    # dframe argument requires ID and timely_term columns
    col_missing <- copy(DT)[, mcid := NULL]
    expect_error(
        add_completion_status(col_missing, midfield_degree = toy_degree)
    )
    col_missing <- copy(DT)[, timely_term := NULL]
    expect_error(
        add_completion_status(col_missing, midfield_degree = toy_degree)
    )

    # midfield_degree argument requires ID and term columns
    col_missing <- copy(toy_degree)[, mcid := NULL]
    expect_error(
        add_completion_status(DT, midfield_degree = col_missing)
    )
    col_missing <- copy(toy_degree)[, term_degree := NULL]
    expect_error(
        add_completion_status(DT, midfield_degree = col_missing)
    )

    # data frame arguments must be data frames
    expect_error(
        add_completion_status(DT$mcid, toy_degree)
    )
    expect_error(
        add_completion_status(DT, toy_degree$term)
    )

    # required arguments must be explicit
    expect_error(
        add_completion_status(NULL, toy_degree)
    )
    expect_error(
        add_completion_status(DT, NULL)
    )

    invisible(NULL)
}

test_add_completion_status()

