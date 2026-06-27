
# functions used in the test

run_check <- function(x, y, fnc) {
    
    z <- fnc(x, y)
    expect_equal(class(x), class(z))
    expect_equal(class(y), class(z))
    
    rm(z)
}

expect_class_preserved <- function(df1, df2, fnc) {
    
    x <- copy(df1)
    y <- copy(df2)
    
    x <- as.data.frame(x)
    y <- as.data.frame(y)
    run_check(x, y, fnc)
    
    setattr(x, "class", c("tbl_df", "tbl", "data.frame"))
    setattr(y, "class", c("tbl_df", "tbl", "data.frame"))
    run_check(x, y, fnc)
    
    x <- as.data.table(x)
    y <- as.data.table(y)
    run_check(x, y, fnc)
    
    rm(x, y)
}

test_add_data_sufficiency <- function() {

    # usage
    # add_data_sufficiency(dframe, midfield_term = term)

    # Needed for tinytest::build_install_test()
    suppressPackageStartupMessages(require("data.table"))

    # create answers
    dframe <- toy_student[c(1:3, 91:97), .(mcid)]
    dframe <- add_timely_term(dframe, midfield_term = toy_term)
    check_df <- copy(dframe)
    dframe <- add_data_sufficiency(dframe, midfield_term = toy_term)
    # cat(wrapr::draw_frame(dframe))

    DT <- wrapr::build_frame(
        "mcid"            , "level_i"      , "adj_span", "timely_term", "term_i", "lower_limit", "upper_limit", "data_sufficiency" |
            "MCID3111158953", "01 First-year", 6         , "19933"      , "19881" , "19881"      , "20096"      , "exclude-lower"    |
            "MCID3111159270", "01 First-year", 6         , "19933"      , "19881" , "19881"      , "20096"      , "exclude-lower"    |
            "MCID3111160513", "01 First-year", 6         , "19933"      , "19881" , "19881"      , "20096"      , "exclude-lower"    |
            "MCID3112142848", "01 First-year", 6         , "20093"      , "20041" , "19881"      , "20181"      , "include"          |
            "MCID3112150160", "01 First-year", 6         , "20093"      , "20041" , "19901"      , "20153"      , "include"          |
            "MCID3112150739", "01 First-year", 6         , "20093"      , "20041" , "19901"      , "20153"      , "include"          |
            "MCID3112166810", "01 First-year", 6         , "20101"      , "20043" , "19881"      , "20181"      , "include"          |
            "MCID3112169393", "01 First-year", 6         , "20103"      , "20051" , "19881"      , "20096"      , "exclude-upper"    |
            "MCID3112169971", "01 First-year", 6         , "20103"      , "20051" , "19881"      , "20096"      , "exclude-upper"    |
            "MCID3112172059", "01 First-year", 6         , "20103"      , "20051" , "19881"      , "20096"      , "exclude-upper"    )
    setDT(DT)

    # ---------- start tests
    
    # check that class is preserved function
    expect_class_preserved(check_df, toy_term, add_data_sufficiency)
    
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






