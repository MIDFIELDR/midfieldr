test_add_completion_status <- function() {

    # usage
    # add_completion_status(dframe, midfield_degree = degree)

    # Needed for tinytest::build_install_test()
    require("data.table")
    
    # manually uncomment    or Ctrl-Shift-L
    # require("midfieldr")
    
    # create answers
    dframe <- toy_student[11:20, .(mcid)]
    dframe <- add_timely_term(dframe, midfield_term = toy_term)
    
    # DT <- add_completion_status(dframe, midfield_degree = toy_degree)
    # cat(wrapr::draw_frame(DT))

    DT <- wrapr::build_frame(
        "mcid"            , "term_i", "level_i"      , "adj_span", "timely_term", "term_degree", "completion_status" |
            "MCID3111253227", "19901" , "01 First-year", 6         , "19953"      , "19951"      , "timely"            |
            "MCID3111258790", "19901" , "01 First-year", 6         , "19953"      , "19954"      , "late"              |
            "MCID3111263510", "19901" , "01 First-year", 6         , "19953"      , "19933"      , "timely"            |
            "MCID3111272687", "19901" , "01 First-year", 6         , "19953"      , NA_character_, NA_character_       |
            "MCID3111282492", "19904" , "01 First-year", 6         , "19963"      , "19991"      , "late"              |
            "MCID3111304195", "19911" , "01 First-year", 6         , "19963"      , NA_character_, NA_character_       |
            "MCID3111315508", "19911" , "01 First-year", 6         , "19963"      , "19961"      , "timely"            |
            "MCID3111316435", "19911" , "01 First-year", 6         , "19963"      , "19964"      , "late"              |
            "MCID3111316936", "19911" , "01 First-year", 6         , "19963"      , "19953"      , "timely"            |
            "MCID3111354376", "19921" , "01 First-year", 6         , "19973"      , "19953"      , "timely"            )
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

