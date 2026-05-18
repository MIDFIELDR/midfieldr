test_add_completion_status <- function() {

    # usage
    # add_completion_status(dframe, midfield_degree = degree)

    # Needed for tinytest::build_install_test()
    require("data.table")
    
    # manually uncomment
    # require("midfieldr")
    
    # create answers
    dframe <- toy_student[1:10, .(mcid)]
    dframe <- add_timely_term(dframe, midfield_term = toy_term)
    
    # DT <- add_completion_status(dframe, midfield_degree = toy_degree)
    # cat(wrapr::draw_frame(DT))

    DT <- wrapr::build_frame(
        "mcid"            , "term_i", "level_i"      , "adj_span", "timely_term", "term_degree", "completion_status" |
            "MCID3111145992", "19881" , "01 First-year", 6         , "19933"      , NA_character_, NA_character_       |
            "MCID3111159270", "19881" , "01 First-year", 6         , "19933"      , "19913"      , "timely"            |
            "MCID3111160219", "19881" , "01 First-year", 6         , "19933"      , "19913"      , "timely"            |
            "MCID3111160513", "19881" , "01 First-year", 6         , "19933"      , NA_character_, NA_character_       |
            "MCID3111162677", "19881" , "01 First-year", 6         , "19933"      , "19913"      , "timely"            |
            "MCID3111164287", "19881" , "01 First-year", 6         , "19933"      , "19913"      , "timely"            |
            "MCID3111166148", "19881" , "01 First-year", 6         , "19933"      , "19913"      , "timely"            |
            "MCID3111170298", "19881" , "01 First-year", 6         , "19933"      , "19904"      , "timely"            |
            "MCID3111170338", "19881" , "01 First-year", 6         , "19933"      , "19903"      , "timely"            |
            "MCID3111213943", "19891" , "01 First-year", 6         , "19943"      , "19903"      , "timely"            )
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

