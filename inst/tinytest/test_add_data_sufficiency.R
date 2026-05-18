test_add_data_sufficiency <- function() {

    # usage
    # add_data_sufficiency(dframe, midfield_term = term)

    # Needed for tinytest::build_install_test()
    require("data.table")

    # create answers
    dframe <- toy_student[1:10, .(mcid)]
    dframe <- add_timely_term(dframe, midfield_term = toy_term)
    dframe <- add_data_sufficiency(dframe, midfield_term = toy_term)
    # cat(wrapr::draw_frame(dframe))

    DT <- wrapr::build_frame(
        "mcid"            , "level_i"      , "adj_span", "timely_term", "term_i", "lower_limit", "upper_limit", "data_sufficiency" |
            "MCID3111145992", "01 First-year", 6         , "19933"      , "19881" , "19881"      , "20096"      , "exclude-lower"    |
            "MCID3111159270", "01 First-year", 6         , "19933"      , "19881" , "19881"      , "20096"      , "exclude-lower"    |
            "MCID3111160219", "01 First-year", 6         , "19933"      , "19881" , "19881"      , "20096"      , "exclude-lower"    |
            "MCID3111160513", "01 First-year", 6         , "19933"      , "19881" , "19881"      , "20096"      , "exclude-lower"    |
            "MCID3111162677", "01 First-year", 6         , "19933"      , "19881" , "19881"      , "20096"      , "exclude-lower"    |
            "MCID3111164287", "01 First-year", 6         , "19933"      , "19881" , "19881"      , "20096"      , "exclude-lower"    |
            "MCID3111166148", "01 First-year", 6         , "19933"      , "19881" , "19881"      , "20096"      , "exclude-lower"    |
            "MCID3111170298", "01 First-year", 6         , "19933"      , "19881" , "19881"      , "20181"      , "exclude-lower"    |
            "MCID3111170338", "01 First-year", 6         , "19933"      , "19881" , "19881"      , "20181"      , "exclude-lower"    |
            "MCID3111213943", "01 First-year", 6         , "19943"      , "19891" , "19881"      , "20181"      , "include"          )
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






