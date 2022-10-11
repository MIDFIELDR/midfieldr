test_prep_fye_mice <- function() {

    # usage
    # prep_fye_mice(midfield_student,   # mcid, race, sex
    #               midfield_term,      # term, institution
    #               ...,
    #               fye_codes = NULL)   # default 140102

    # Needed for tinytest::build_install_test()
    data("toy_student")
    data("toy_term")
    suppressPackageStartupMessages(library("data.table"))
    options(
        datatable.print.nrows = 8,
        datatable.print.topn = 8,
        datatable.print.class = TRUE
    )

    # create an answer
    # DT <- prep_fye_mice(toy_student, toy_term)
    # cat(wrapr::draw_frame(DT))

    # test case
    DT <- wrapr::build_frame(
        "mcid"         , "race"  , "sex"   , "institution"  , "proxy"       |
            "MID26060301", "Asian" , "Female", "Institution C", NA_character_ |
            "MID25995980", "Latine", "Female", "Institution C", NA_character_ |
            "MID25997636", "Latine", "Female", "Institution C", NA_character_ |
            "MID26086310", "Latine", "Female", "Institution C", NA_character_ |
            "MID26000057", "White" , "Female", "Institution C", NA_character_ |
            "MID26614720", "Asian" , "Male"  , "Institution J", NA_character_ |
            "MID26593796", "White" , "Male"  , "Institution J", NA_character_ |
            "MID25848589", "White" , "Male"  , "Institution M", "143501"      |
            "MID25846316", "White" , "Male"  , "Institution M", "143501"      |
            "MID25847220", "White" , "Male"  , "Institution M", "143501"      |
            "MID25828870", "White" , "Male"  , "Institution M", "149999"      )
    setDT(DT)
    DT[, c("race", "sex", "institution", "proxy") :=
           list(as.factor(race),
                as.factor(sex),
                as.factor(institution),
                as.factor(proxy)
           )]
    # DT[]

    # Correct answer
    expect_equal(
        DT,
        prep_fye_mice(toy_student, toy_term)
    )

    # Results are factors except for ID
    DT <- prep_fye_mice(toy_student, toy_term)
    expect_equal(class(DT[, mcid]), "character")
    expect_equal(class(DT[, institution]), "factor")
    expect_equal(class(DT[, race]), "factor")
    expect_equal(class(DT[, sex]), "factor")
    expect_equal(class(DT[, proxy]), "factor")

    # specific names of columns
     expect_equivalent(
        names(DT),
        c("mcid", "race", "sex", "institution", "proxy")
    )

     # extra columns are dropped, add column for cip6
     DT <- prep_fye_mice(toy_student, toy_term)
     expect_equal(
         names(DT),
         c("mcid", "race", "sex", "institution", "proxy")
     )

    # CIPs must be 6-digit, number characters only, start with 14
    x <- toy_student[, .(mcid, race, sex)]
    expect_error(
        prep_fye_mice(x, toy_term, fye_codes = c("14", "1410", "143501"))
    )
    expect_error(
        prep_fye_mice(x, toy_term, fye_codes = c("^14350", "143501"))
    )
    expect_error(
        prep_fye_mice(x, toy_term, fye_codes = c("543501", "143501"))
    )

    # multiple CIP codes starting with 14 can be assigned to FYE
    # create an answer
    # DT <- prep_fye_mice(toy_student, toy_term,
    #                     fye_codes = c("140101", "140102", "149999"))
    # cat(wrapr::draw_frame(DT))
    DT <- wrapr::build_frame(
        "mcid"         , "race"  , "sex"   , "institution"  , "proxy"       |
            "MID25977316", "White" , "Male"  , "Institution B", NA_character_ |
            "MID26060301", "Asian" , "Female", "Institution C", NA_character_ |
            "MID25995980", "Latine", "Female", "Institution C", NA_character_ |
            "MID25997636", "Latine", "Female", "Institution C", NA_character_ |
            "MID26086310", "Latine", "Female", "Institution C", NA_character_ |
            "MID26000057", "White" , "Female", "Institution C", NA_character_ |
            "MID26231601", "White" , "Female", "Institution E", NA_character_ |
            "MID26171165", "Latine", "Male"  , "Institution E", NA_character_ |
            "MID26614720", "Asian" , "Male"  , "Institution J", NA_character_ |
            "MID26593796", "White" , "Male"  , "Institution J", NA_character_ |
            "MID25828870", "White" , "Male"  , "Institution M", "140801"      |
            "MID25848589", "White" , "Male"  , "Institution M", "143501"      |
            "MID25846316", "White" , "Male"  , "Institution M", "143501"      |
            "MID25847220", "White" , "Male"  , "Institution M", "143501"      )
    setDT(DT)
    DT[, c("race", "sex", "institution", "proxy") :=
           list(as.factor(race),
                as.factor(sex),
                as.factor(institution),
                as.factor(proxy)
           )]

    # Correct answer
    expect_equal(
        DT,
        prep_fye_mice(toy_student, toy_term, fye_codes = c("140101", "140102", "149999"))
    )
    
    # CIP must start with 14
    expect_error(
        prep_fye_mice(toy_student, toy_term, fye_codes = c("140101", "140102", "999999"))
    )

    invisible(NULL)
}

test_prep_fye_mice()

