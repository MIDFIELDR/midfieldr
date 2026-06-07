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
    # set.seed(20260513)
    # DT <- prep_fye_mice(toy_student, toy_term)
    # cat(wrapr::draw_frame(DT))

    # test case
    DT <- wrapr::build_frame(
        "mcid"            , "race"         , "sex"   , "institution"  , "proxy"       |
            "MCID3111775049", "Black"        , "Female", "Institution J", NA_character_ |
            "MCID3111587881", "White"        , "Female", "Institution J", NA_character_ |
            "MCID3112382701", "White"        , "Female", "Institution J", NA_character_ |
            "MCID3111914993", "Asian"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112061482", "Asian"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112265753", "Asian"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112273754", "Other/Unknown", "Male"  , "Institution J", NA_character_ |
            "MCID3111160513", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111250695", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111304195", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111413518", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111580991", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111648099", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111652280", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111782447", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112008110", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112172401", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112382065", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112382653", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112384278", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112388922", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111931819", "White"        , "Male"  , "Institution J", "140201"      |
            "MCID3111933160", "White"        , "Male"  , "Institution J", "140201"      |
            "MCID3112172059", "White"        , "Male"  , "Institution J", "140201"      |
            "MCID3111162677", "White"        , "Female", "Institution J", "140701"      |
            "MCID3112216887", "White"        , "Female", "Institution J", "140701"      |
            "MCID3111357512", "White"        , "Male"  , "Institution J", "140701"      |
            "MCID3112169393", "White"        , "Female", "Institution J", "140801"      |
            "MCID3111354376", "White"        , "Male"  , "Institution J", "140801"      |
            "MCID3111460368", "White"        , "Male"  , "Institution J", "140801"      |
            "MCID3111656207", "White"        , "Male"  , "Institution J", "140801"      |
            "MCID3111860947", "White"        , "Male"  , "Institution J", "140801"      |
            "MCID3112267967", "White"        , "Male"  , "Institution J", "140801"      |
            "MCID3112268235", "White"        , "Male"  , "Institution J", "140801"      |
            "MCID3111909377", "Other/Unknown", "Male"  , "Institution J", "140901"      |
            "MCID3111248941", "White"        , "Male"  , "Institution J", "140901"      |
            "MCID3111355374", "White"        , "Male"  , "Institution J", "140901"      |
            "MCID3111648837", "White"        , "Male"  , "Institution J", "140901"      |
            "MCID3111842661", "White"        , "Male"  , "Institution J", "140901"      |
            "MCID3111358440", "White"        , "Female", "Institution J", "141001"      |
            "MCID3111159270", "White"        , "Male"  , "Institution J", "141001"      |
            "MCID3111164287", "White"        , "Male"  , "Institution J", "141001"      |
            "MCID3111406464", "White"        , "Male"  , "Institution J", "141001"      |
            "MCID3111584951", "White"        , "Male"  , "Institution J", "141401"      |
            "MCID3112169971", "White"        , "Female", "Institution J", "141801"      |
            "MCID3111503953", "Asian"        , "Male"  , "Institution J", "141901"      |
            "MCID3112174233", "Hispanic"     , "Male"  , "Institution J", "141901"      |
            "MCID3111253227", "White"        , "Male"  , "Institution J", "141901"      |
            "MCID3111355464", "White"        , "Male"  , "Institution J", "141901"      |
            "MCID3111356562", "White"        , "Male"  , "Institution J", "141901"      |
            "MCID3111786826", "White"        , "Male"  , "Institution J", "141901"      |
            "MCID3112323623", "White"        , "Female", "Institution J", "143501"      |
            "MCID3111573067", "Black"        , "Male"  , "Institution J", "143501"      |
            "MCID3111454125", "International", "Male"  , "Institution J", "143501"      )
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
    #                       fye_codes = c("140101", "140102", "149999"))
    # cat(wrapr::draw_frame(DT))
    
    DT <- wrapr::build_frame(
        "mcid"            , "race"         , "sex"   , "institution"  , "proxy"       |
            "MCID3111871132", "Black"        , "Female", "Institution B", "140901"      |
            "MCID3111802941", "White"        , "Female", "Institution C", NA_character_ |
            "MCID3111282492", "Hispanic"     , "Male"  , "Institution C", "140801"      |
            "MCID3111775049", "Black"        , "Female", "Institution J", NA_character_ |
            "MCID3111587881", "White"        , "Female", "Institution J", NA_character_ |
            "MCID3112382701", "White"        , "Female", "Institution J", NA_character_ |
            "MCID3111914993", "Asian"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112061482", "Asian"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112265753", "Asian"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112273754", "Other/Unknown", "Male"  , "Institution J", NA_character_ |
            "MCID3111160513", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111250695", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111304195", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111413518", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111580991", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111648099", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111652280", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111782447", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112008110", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112172401", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112382065", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112382653", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112384278", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112388922", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111931819", "White"        , "Male"  , "Institution J", "140201"      |
            "MCID3111933160", "White"        , "Male"  , "Institution J", "140201"      |
            "MCID3112172059", "White"        , "Male"  , "Institution J", "140201"      |
            "MCID3111162677", "White"        , "Female", "Institution J", "140701"      |
            "MCID3112216887", "White"        , "Female", "Institution J", "140701"      |
            "MCID3111357512", "White"        , "Male"  , "Institution J", "140701"      |
            "MCID3112169393", "White"        , "Female", "Institution J", "140801"      |
            "MCID3111354376", "White"        , "Male"  , "Institution J", "140801"      |
            "MCID3111460368", "White"        , "Male"  , "Institution J", "140801"      |
            "MCID3111656207", "White"        , "Male"  , "Institution J", "140801"      |
            "MCID3111860947", "White"        , "Male"  , "Institution J", "140801"      |
            "MCID3112267967", "White"        , "Male"  , "Institution J", "140801"      |
            "MCID3112268235", "White"        , "Male"  , "Institution J", "140801"      |
            "MCID3111909377", "Other/Unknown", "Male"  , "Institution J", "140901"      |
            "MCID3111248941", "White"        , "Male"  , "Institution J", "140901"      |
            "MCID3111355374", "White"        , "Male"  , "Institution J", "140901"      |
            "MCID3111648837", "White"        , "Male"  , "Institution J", "140901"      |
            "MCID3111842661", "White"        , "Male"  , "Institution J", "140901"      |
            "MCID3111358440", "White"        , "Female", "Institution J", "141001"      |
            "MCID3111159270", "White"        , "Male"  , "Institution J", "141001"      |
            "MCID3111164287", "White"        , "Male"  , "Institution J", "141001"      |
            "MCID3111406464", "White"        , "Male"  , "Institution J", "141001"      |
            "MCID3111584951", "White"        , "Male"  , "Institution J", "141401"      |
            "MCID3112169971", "White"        , "Female", "Institution J", "141801"      |
            "MCID3111503953", "Asian"        , "Male"  , "Institution J", "141901"      |
            "MCID3112174233", "Hispanic"     , "Male"  , "Institution J", "141901"      |
            "MCID3111253227", "White"        , "Male"  , "Institution J", "141901"      |
            "MCID3111355464", "White"        , "Male"  , "Institution J", "141901"      |
            "MCID3111356562", "White"        , "Male"  , "Institution J", "141901"      |
            "MCID3111786826", "White"        , "Male"  , "Institution J", "141901"      |
            "MCID3112323623", "White"        , "Female", "Institution J", "143501"      |
            "MCID3111573067", "Black"        , "Male"  , "Institution J", "143501"      |
            "MCID3111454125", "International", "Male"  , "Institution J", "143501"      )
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

    # set.seed(NULL)
    invisible(NULL)
}

test_prep_fye_mice()

