test_condition_fye <- function() {

    # usage
    # condition_fye(midfield_student,   # mcid, race, sex
    #               midfield_term,      # term
    #               ...,
    #               fye_codes = NULL)   # default 140102

    # Needed for tinytest::build_install_test()
    data("toy_student")
    data("toy_term")
    suppressMessages(library("data.table"))
    options(
        datatable.print.nrows = 8,
        datatable.print.topn = 8,
        datatable.print.class = TRUE
    )

    # create an answer
    # DT <- condition_fye(toy_student, toy_term)
    # cat(wrapr::draw_frame(DT))

    # test case
    DT <- wrapr::build_frame(
        "mcid"         , "institution"  , "race"           , "sex"   , "cip6"        |
            "MID26060301", "Institution C", "Asian"          , "Female", NA_character_ |
            "MID25995980", "Institution C", "Hispanic/Latinx", "Female", NA_character_ |
            "MID25997636", "Institution C", "Hispanic/Latinx", "Female", NA_character_ |
            "MID26086310", "Institution C", "Hispanic/Latinx", "Female", NA_character_ |
            "MID26000057", "Institution C", "White"          , "Female", NA_character_ |
            "MID26614720", "Institution J", "Asian"          , "Male"  , NA_character_ |
            "MID26593796", "Institution J", "White"          , "Male"  , NA_character_ |
            "MID25846316", "Institution M", "White"          , "Male"  , "143501"      |
            "MID25847220", "Institution M", "White"          , "Male"  , "143501"      |
            "MID25848589", "Institution M", "White"          , "Male"  , "143501"      |
            "MID25828870", "Institution M", "White"          , "Male"  , "149999"      )
    setDT(DT)
    DT[, c("race", "sex", "institution", "cip6") :=
           list(as.factor(race),
                as.factor(sex),
                as.factor(institution),
                as.factor(cip6)
           )]

    # Correct answer
    expect_equal(
        DT,
        condition_fye(toy_student, toy_term)
    )

    # Results are factors except for ID
    DT <- condition_fye(toy_student, toy_term)
    expect_equal(class(DT[, mcid]), "character")
    expect_equal(class(DT[, institution]), "factor")
    expect_equal(class(DT[, race]), "factor")
    expect_equal(class(DT[, sex]), "factor")
    expect_equal(class(DT[, cip6]), "factor")

    # specific names of columns
     expect_equivalent(
        names(DT),
        c("mcid", "institution", "race", "sex", "cip6")
    )

     # extra columns are dropped, add column for cip6
     DT <- condition_fye(toy_student, toy_term)
     expect_equal(
         names(DT),
         c("mcid", "institution", "race", "sex", "cip6")
     )

    # CIPs must be 6-digit, number characters only, start with 14
    x <- toy_student[, .(mcid, race, sex)]
    expect_error(
        condition_fye(x, toy_term, fye_codes = c("14", "1410", "143501"))
    )
    expect_error(
        condition_fye(x, toy_term, fye_codes = c("^14350", "143501"))
    )
    expect_error(
        condition_fye(x, toy_term, fye_codes = c("543501", "143501"))
    )

    # multiple CIP codes starting with 14 can be assigned to FYE
    # create an answer
    # DT <- condition_fye(toy_student, toy_term,
    #                     fye_codes = c("140101", "140102", "149999"))
    # cat(wrapr::draw_frame(DT))
    DT <- wrapr::build_frame(
        "mcid"         , "institution"  , "race"           , "sex"   , "cip6"        |
            "MID25977316", "Institution B", "White"          , "Male"  , NA_character_ |
            "MID26060301", "Institution C", "Asian"          , "Female", NA_character_ |
            "MID25995980", "Institution C", "Hispanic/Latinx", "Female", NA_character_ |
            "MID25997636", "Institution C", "Hispanic/Latinx", "Female", NA_character_ |
            "MID26086310", "Institution C", "Hispanic/Latinx", "Female", NA_character_ |
            "MID26000057", "Institution C", "White"          , "Female", NA_character_ |
            "MID26231601", "Institution E", "White"          , "Female", NA_character_ |
            "MID26171165", "Institution E", "Hispanic/Latinx", "Male"  , NA_character_ |
            "MID26614720", "Institution J", "Asian"          , "Male"  , NA_character_ |
            "MID26593796", "Institution J", "White"          , "Male"  , NA_character_ |
            "MID25828870", "Institution M", "White"          , "Male"  , "140801"      |
            "MID25846316", "Institution M", "White"          , "Male"  , "143501"      |
            "MID25847220", "Institution M", "White"          , "Male"  , "143501"      |
            "MID25848589", "Institution M", "White"          , "Male"  , "143501"      )
    setDT(DT)
    DT[, c("race", "sex", "institution", "cip6") :=
           list(as.factor(race),
                as.factor(sex),
                as.factor(institution),
                as.factor(cip6)
           )]

    # Correct answer
    expect_equal(
        DT,
        condition_fye(toy_student, toy_term, fye_codes = c("140101", "140102", "149999"))
    )
    
    # CIP must start with 14
    expect_error(
        condition_fye(toy_student, toy_term, fye_codes = c("140101", "140102", "999999"))
    )

    invisible(NULL)
}

test_condition_fye()

