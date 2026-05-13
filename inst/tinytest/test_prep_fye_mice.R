test_prep_fye_mice <- function() {

    # usage
    # prep_fye_mice(midfield_student,   # mcid, race, sex
    #               midfield_term,      # term, institution
    #               ...,
    #               fye_codes = NULL)   # default 140102

    # CTRL-L to load midfieldr
    
    # Needed for tinytest::build_install_test()
    require("data.table")

    # create an answer
    set.seed(20260513)

    # DT <- prep_fye_mice(toy_student, toy_term)
    # cat(wrapr::draw_frame(DT))

    # test case
    DT <- wrapr::build_frame(
        "mcid"            , "race"         , "sex"   , "institution"  , "proxy"       |
            "MCID3112320786", "Other/Unknown", "Female", "Institution J", NA_character_ |
            "MCID3112172220", "White"        , "Female", "Institution J", NA_character_ |
            "MCID3111443737", "White"        , "Female", "Institution J", NA_character_ |
            "MCID3111412392", "White"        , "Female", "Institution J", NA_character_ |
            "MCID3112215217", "White"        , "Female", "Institution J", NA_character_ |
            "MCID3111722690", "White"        , "Female", "Institution J", NA_character_ |
            "MCID3112379513", "Asian"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111705927", "Black"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111238499", "Black"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112447536", "Hispanic"     , "Male"  , "Institution J", NA_character_ |
            "MCID3111864010", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111357501", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111199777", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112322564", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112007534", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111721256", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111159982", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112324262", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111248383", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111412721", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111165835", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111932471", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111206488", "White"        , "Male"  , "Institution J", NA_character_ )
    setDT(DT)
    DT <- DT[, c("race", "sex", "institution", "proxy") :=
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
        "mcid"            , "race"         , "sex"   , "institution"  , "proxy"       |
            "MCID3112320786", "Other/Unknown", "Female", "Institution J", NA_character_ |
            "MCID3112172220", "White"        , "Female", "Institution J", NA_character_ |
            "MCID3111443737", "White"        , "Female", "Institution J", NA_character_ |
            "MCID3111412392", "White"        , "Female", "Institution J", NA_character_ |
            "MCID3112215217", "White"        , "Female", "Institution J", NA_character_ |
            "MCID3111722690", "White"        , "Female", "Institution J", NA_character_ |
            "MCID3112379513", "Asian"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111705927", "Black"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111238499", "Black"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112447536", "Hispanic"     , "Male"  , "Institution J", NA_character_ |
            "MCID3111864010", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111357501", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111199777", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112322564", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112007534", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111721256", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111159982", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112324262", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111248383", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111412721", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111165835", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111932471", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111206488", "White"        , "Male"  , "Institution J", NA_character_ )
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

    set.seed(NULL)
    invisible(NULL)
}

test_prep_fye_mice()

