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
            "MCID3112328521", "Asian"        , "Female", "Institution J", NA_character_ |
            "MCID3111452065", "Black"        , "Female", "Institution J", NA_character_ |
            "MCID3111566004", "Black"        , "Female", "Institution J", NA_character_ |
            "MCID3111992957", "International", "Female", "Institution J", NA_character_ |
            "MCID3112266585", "Other/Unknown", "Female", "Institution J", NA_character_ |
            "MCID3111301718", "White"        , "Female", "Institution J", NA_character_ |
            "MCID3111408816", "White"        , "Female", "Institution J", NA_character_ |
            "MCID3111625298", "White"        , "Female", "Institution J", NA_character_ |
            "MCID3111658234", "White"        , "Female", "Institution J", NA_character_ |
            "MCID3111855934", "White"        , "Female", "Institution J", NA_character_ |
            "MCID3112325226", "White"        , "Female", "Institution J", NA_character_ |
            "MCID3112381538", "White"        , "Female", "Institution J", NA_character_ |
            "MCID3112382861", "White"        , "Female", "Institution J", NA_character_ |
            "MCID3112383166", "White"        , "Female", "Institution J", NA_character_ |
            "MCID3112383176", "White"        , "Female", "Institution J", NA_character_ |
            "MCID3111697452", "Asian"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112265642", "Asian"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112317750", "Asian"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112266077", "Hispanic"     , "Male"  , "Institution J", NA_character_ |
            "MCID3112320270", "Hispanic"     , "Male"  , "Institution J", NA_character_ |
            "MCID3112320295", "Hispanic"     , "Male"  , "Institution J", NA_character_ |
            "MCID3112320393", "Hispanic"     , "Male"  , "Institution J", NA_character_ |
            "MCID3112379886", "Hispanic"     , "Male"  , "Institution J", NA_character_ |
            "MCID3112380099", "Hispanic"     , "Male"  , "Institution J", NA_character_ |
            "MCID3112320559", "International", "Male"  , "Institution J", NA_character_ |
            "MCID3112447552", "International", "Male"  , "Institution J", NA_character_ |
            "MCID3112123176", "Other/Unknown", "Male"  , "Institution J", NA_character_ |
            "MCID3112266592", "Other/Unknown", "Male"  , "Institution J", NA_character_ |
            "MCID3112380659", "Other/Unknown", "Male"  , "Institution J", NA_character_ |
            "MCID3111158724", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111163443", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111164659", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111165208", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111208924", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111246563", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111296595", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111412771", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111413518", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111523185", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111524817", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111580337", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111585561", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111656553", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111716841", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111789588", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111790191", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111864654", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111999514", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112074509", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112075167", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112075197", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112268500", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112269550", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112269697", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112322575", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112323687", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112324635", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112325316", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112378802", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112381457", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112381488", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112382065", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112382120", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112382756", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112382807", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112383954", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112384277", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112384523", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3112447663", "White"        , "Male"  , "Institution J", NA_character_ |
            "MCID3111793283", "White"        , "Female", "Institution J", "140201"      |
            "MCID3112320374", "Hispanic"     , "Male"  , "Institution J", "140201"      |
            "MCID3112322943", "White"        , "Male"  , "Institution J", "140201"      |
            "MCID3112322988", "White"        , "Male"  , "Institution J", "140201"      |
            "MCID3112324662", "White"        , "Male"  , "Institution J", "140201"      |
            "MCID3112267696", "White"        , "Male"  , "Institution J", "140301"      |
            "MCID3112319668", "Asian"        , "Female", "Institution J", "140701"      |
            "MCID3112217827", "White"        , "Female", "Institution J", "140701"      |
            "MCID3112269126", "White"        , "Male"  , "Institution J", "140701"      |
            "MCID3112323008", "White"        , "Male"  , "Institution J", "140701"      |
            "MCID3112383099", "White"        , "Male"  , "Institution J", "140701"      |
            "MCID3111981962", "Other/Unknown", "Male"  , "Institution J", "140801"      |
            "MCID3112266542", "Other/Unknown", "Male"  , "Institution J", "140801"      |
            "MCID3112270138", "White"        , "Male"  , "Institution J", "140801"      |
            "MCID3112325173", "White"        , "Male"  , "Institution J", "140801"      |
            "MCID3112388822", "White"        , "Female", "Institution J", "140901"      |
            "MCID3112266140", "Hispanic"     , "Male"  , "Institution J", "140901"      |
            "MCID3112214437", "Other/Unknown", "Male"  , "Institution J", "140901"      |
            "MCID3111254412", "White"        , "Male"  , "Institution J", "140901"      |
            "MCID3111589406", "White"        , "Male"  , "Institution J", "140901"      |
            "MCID3112324963", "White"        , "Male"  , "Institution J", "140901"      |
            "MCID3112328548", "Hispanic"     , "Female", "Institution J", "141001"      |
            "MCID3111908614", "International", "Female", "Institution J", "141001"      |
            "MCID3111356171", "White"        , "Male"  , "Institution J", "141001"      |
            "MCID3111562218", "White"        , "Male"  , "Institution J", "141001"      |
            "MCID3111986635", "White"        , "Male"  , "Institution J", "141001"      |
            "MCID3112269084", "White"        , "Male"  , "Institution J", "141001"      |
            "MCID3112269415", "White"        , "Male"  , "Institution J", "141001"      |
            "MCID3112269532", "White"        , "Male"  , "Institution J", "141001"      |
            "MCID3112328622", "White"        , "Male"  , "Institution J", "141001"      |
            "MCID3112211555", "Asian"        , "Male"  , "Institution J", "141901"      |
            "MCID3112165543", "Other/Unknown", "Male"  , "Institution J", "141901"      |
            "MCID3111447797", "White"        , "Male"  , "Institution J", "141901"      |
            "MCID3111460403", "White"        , "Male"  , "Institution J", "141901"      |
            "MCID3111701868", "White"        , "Male"  , "Institution J", "141901"      |
            "MCID3111722964", "White"        , "Male"  , "Institution J", "141901"      |
            "MCID3111832009", "White"        , "Male"  , "Institution J", "141901"      |
            "MCID3111911746", "White"        , "Male"  , "Institution J", "141901"      |
            "MCID3112008884", "White"        , "Male"  , "Institution J", "141901"      |
            "MCID3112174290", "White"        , "Male"  , "Institution J", "141901"      |
            "MCID3112322571", "White"        , "Male"  , "Institution J", "141901"      |
            "MCID3112324274", "White"        , "Male"  , "Institution J", "141901"      |
            "MCID3112215058", "White"        , "Female", "Institution J", "142101"      |
            "MCID3112323893", "White"        , "Female", "Institution J", "142101"      |
            "MCID3112168643", "Other/Unknown", "Male"  , "Institution J", "142101"      |
            "MCID3112267788", "White"        , "Male"  , "Institution J", "143301"      |
            "MCID3112321615", "White"        , "Male"  , "Institution J", "143301"      |
            "MCID3112265788", "Asian"        , "Female", "Institution J", "143501"      |
            "MCID3112321979", "White"        , "Male"  , "Institution J", "143501"      )
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

    

    # set.seed(NULL)
    invisible(NULL)
}

test_prep_fye_mice()

