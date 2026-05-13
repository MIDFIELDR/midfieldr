test_add_completion_status <- function() {

    # usage
    # add_completion_status(dframe, midfield_degree = degree)

    # Needed for tinytest::build_install_test()
    require("data.table")

    # create answers
    dframe <- toy_student[1:10, .(mcid)]
    dframe <- add_timely_term(dframe, midfield_term = toy_term)
    
    # DT <- add_completion_status(dframe, midfield_degree = toy_degree)
    # cat(wrapr::draw_frame(DT))

    DT <- wrapr::build_frame(
            "mcid"          , "term_i", "level_i"       , "adj_span", "timely_term", "term_degree", "completion_status" |
            "MCID3111146562", "19881" , "01 First-year" , 6         , "19933"      , "19921"      , "timely"            |
            "MCID3111156062", "19891" , "02 Second-year", 5         , "19933"      , "19913"      , "timely"            |
            "MCID3111159982", "19881" , "01 First-year" , 6         , "19933"      , NA_character_, NA_character_       |
            "MCID3111160541", "19881" , "01 First-year" , 6         , "19933"      , "19921"      , "timely"            |
            "MCID3111165512", "19881" , "01 First-year" , 6         , "19933"      , "19921"      , "timely"            |
            "MCID3111165835", "19883" , "02 Second-year", 5         , "19931"      , "19913"      , "timely"            |
            "MCID3111170804", "19883" , "02 Second-year", 5         , "19931"      , "19913"      , "timely"            |
            "MCID3111199777", "19916" , "03 Third-year" , 4         , "19953"      , "19946"      , "timely"            |
            "MCID3111206488", "19893" , "01 First-year" , 6         , "19951"      , "19953"      , "late"              |
            "MCID3111206737", "19923" , "04 Fourth-year", 3         , "19951"      , NA_character_, NA_character_       )
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

