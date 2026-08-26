
# function used in the test
expect_class_preserved <- function(df1, df2, fnc) {
    
    run_check <- function(x, y, fnc) {
        z <- fnc(x, y)
        expect_equal(class(x), class(z))
        expect_equal(class(y), class(z))
    }
    
    x <- copy(df1)
    y <- copy(df2)
    
    # run check 3 times: data.frame, tibble, data.table
    x <- as.data.frame(x)
    y <- as.data.frame(y)
    run_check(x, y, fnc)
    
    setattr(x, "class", c("tbl_df", "tbl", "data.frame"))
    setattr(y, "class", c("tbl_df", "tbl", "data.frame"))
    run_check(x, y, fnc)
    
    x <- as.data.table(x)
    y <- as.data.table(y)
    run_check(x, y, fnc)
    
    # done
    rm(x, y)
}

test_prep_fye_mice <- function() {
    
    # usage: prep_fye_mice(m_student,
    #                      m_term,
    #                      fye_cip = NULL,
    #                      ..., 
    #                      alt_fye = NULL)
    
    # Needed for tinytest::build_install_test()
    require("data.table")
    
    # test data
    test_data <- wrapr::build_frame(
        "mcid"           , "race"    , "sex"    , "term" , "cip6"  , "institution", "proxy"       |
            "A-to-ME"      , "Asian"   , "Male"   , "20011", "140102", "A"          , "141901"      |
            "A-to-ME"      , "Asian"   , "Male"   , "20013", "140102", "A"          , "141901"      |
            "A-to-ME"      , "Asian"   , "Male"   , "20021", "141901", "A"          , "141901"      |
            "B-to-EE"      , "Black"   , "Female" , "20021", "140102", "A"          , "141001"      |
            "B-to-EE"      , "Black"   , "Female" , "20023", "140102", "A"          , "141001"      |
            "B-to-EE"      , "Black"   , "Female" , "20031", "141001", "A"          , "141001"      |
            "C-to-HSSA"    , "Hispanic", "Unknown", "20041", "140101", "B"          , NA_character_ |
            "C-to-HSSA"    , "Hispanic", "Unknown", "20043", "540101", "B"          , NA_character_ |
            "D-to-unknown" , "White"   , "Male"   , "20051", "140101", "B"          , NA_character_ |
            "E-twice"      , "Asian"   , "Female" , "20061", "140102", "A"          , "141901"      |
            "E-twice"      , "Asian"   , "Female" , "20063", "540101", "A"          , "141901"      |
            "E-twice"      , "Asian"   , "Female" , "20071", "540101", "A"          , "141901"      |
            "E-twice"      , "Asian"   , "Female" , "20073", "140102", "A"          , "141901"      |
            "E-twice"      , "Asian"   , "Female" , "20081", "141901", "A"          , "141901"      |
            "F-late-entry" , "Black"   , "Male"   , "20091", "540101", "B"          , "141001"      |
            "F-late-entry" , "Black"   , "Male"   , "20093", "540101", "B"          , "141001"      |
            "F-late-entry" , "Black"   , "Male"   , "20101", "140101", "B"          , "141001"      |
            "F-late-entry" , "Black"   , "Male"   , "20103", "140101", "B"          , "141001"      |
            "F-late-entry" , "Black"   , "Male"   , "20111", "141001", "B"          , "141001"      |
            "G-ENGR-before", "Hispanic", "Female" , "20123", "141901", "A"          , "141901"      |
            "G-ENGR-before", "Hispanic", "Female" , "20131", "140102", "A"          , "141901"      |
            "G-ENGR-before", "Hispanic", "Female" , "20133", "140102", "A"          , "141901"      |
            "G-ENGR-before", "Hispanic", "Female" , "20141", "540101", "A"          , "141901"      |
            "H-never"      , "White"   , "Male"   , "20011", "540101", "B"          , "omit"        |
            "H-never"      , "White"   , "Male"   , "20013", "540101", "B"          , "omit"        |
            "I-to-HSSA"    , "Asian"   , "Unknown", "20041", "140102", "A"          , NA_character_ |
            "I-to-HSSA"    , "Asian"   , "Unknown", "20043", "140102", "A"          , NA_character_ |
            "I-to-HSSA"    , "Asian"   , "Unknown", "20051", "540101", "A"          , NA_character_ )
    setDT(test_data)
    
    m_student <- test_data[, .(mcid, race, sex)] |> unique()
    m_term    <- test_data[, .(mcid, institution, term, cip6)] |> unique()
    fye_cip   <- "140102"
    alt_fye   <- data.frame(institution = c("B"), 
                            alt_cip = c("140101"))
    
    # check that class is preserved
    expect_class_preserved(m_student, m_term, prep_fye_mice)
    
    # answer is correct with alternate FYE CIP codes
    correct_ans <- test_data[!proxy %like% "omit", 
                             .(mcid, 
                               institution = factor(institution), 
                               race = factor(race), 
                               sex = factor(sex), 
                               proxy = factor(proxy))] |> unique()
    expect_equal(
        correct_ans,
        prep_fye_mice(m_student, m_term, alt_fye = alt_fye)
    )
    
    # ---------- for remaining tests, change "140101" to "140102"
    m_term <- copy(m_term)
    m_term[cip6 == "140101", cip6 := "140102"]
    
    # answer is correct with all standard CIP codes
    expect_equal(
        correct_ans,
        prep_fye_mice(m_student, m_term)
    )
    
    # ans is correct for all FYE codes changed
    temp_alt_fye <- data.frame(institution = c("A", "B", "C"), 
                               alt_cip = c("140101"))
    temp_m_term <- copy(m_term)[cip6 == "140102", cip6 := "140101"]
    expect_equal(
        correct_ans,
        prep_fye_mice(m_student, temp_m_term, alt_fye = temp_alt_fye)
    )
    
    # institution in alt_fye not present in term, no effect
    x <- data.frame(institution = c("X"), alt_cip = c("140101"))
    expect_equal(
        correct_ans,
        prep_fye_mice(m_student, m_term, alt_fye = x)
    )
    
    # Results are factors except for ID
    DT <- prep_fye_mice(m_student, m_term)
    expect_equal(class(DT[, mcid]), "character")
    expect_equal(class(DT[, institution]), "factor")
    expect_equal(class(DT[, race]), "factor")
    expect_equal(class(DT[, sex]), "factor")
    expect_equal(class(DT[, proxy]), "factor")
    
    # Missing student variable, that ID is dropped
    x <- copy(m_student)
    x <- x[mcid == "A-to-ME", race := NA_character_]
    y <- copy(m_term)
    z <- copy(correct_ans)
    expect_equal(
        z[mcid != "A-to-ME"],
        prep_fye_mice(x, y)
    )
    
    # Missing term value no effect if its CIP is duplicated in another row
    x <- copy(m_student)
    y <- copy(m_term)
    y$term[2] <- NA_character_
    expect_equal(
        correct_ans,
        prep_fye_mice(x, y)
    )
    
    # Missing term value for FYE terms, that ID is dropped
    x <- copy(m_student)
    y <- copy(m_term)
    y$term[1:2] <- NA_character_
    z <- copy(correct_ans)
    expect_equal(
        z[mcid != "A-to-ME"],
        prep_fye_mice(x, y)
    )
    
    # Missing term value for post-FYE Engng terms, proxy is NA
    x <- copy(m_student)
    y <- copy(m_term)
    y$term[3] <- NA_character_
    z <- copy(correct_ans)
    expect_equal(
        z[1, proxy := NA_character_],
        prep_fye_mice(x, y)
    )
    
    # Required variables as factors OK, converted to character
    x <- copy(m_student)
    y <- copy(m_term)
    x$race <- as.factor(x$race)
    expect_equal(
        correct_ans,
        prep_fye_mice(x, y)
    )
    
    # ---------- error checks
    
    # Arguments required as data frames
    expect_error(prep_fye_mice(1, m_term))
    expect_error(prep_fye_mice(m_student, 1))
    expect_error(prep_fye_mice(m_student, m_term, fye_cip = 1))
    expect_error(prep_fye_mice(m_student, m_term, alt_fye = 1))
    
    # Missing variables that are required in data frams
    expect_error(prep_fye_mice(m_student[, mcid := NULL], m_term))
    expect_error(prep_fye_mice(m_student, m_term[, mcid := NULL]))
    expect_error(prep_fye_mice(m_student, 
                               m_term, 
                               alt_fye = alt_fye[, institution := NULL]))
    
    # Incorrect class of required columns
    expect_error(prep_fye_mice(m_student[, mcid := as.factor(mcid)], m_term))
    
    # Checking values of CIP codes
    
    # -- 6 digits required
    y <- copy(m_term)
    y$cip6[1] <- "14010"
    expect_error(prep_fye_mice(m_student, y))
    
    # -- start with 14 required
    y <- copy(m_term)
    y$cip6[1] <- "120102"
    expect_error(prep_fye_mice(m_student, y))
    
    # -- all digits required
    y <- copy(m_term)
    y$cip6[1] <- "14010A"
    expect_error(prep_fye_mice(m_student, y))
    
    # -- error in alt CIP
    x <- data.frame(institution = c("B"), alt_cip = c("14010"))
    expect_error(prep_fye_mice(m_student, m_term, alt_fye = x))
    x <- data.frame(institution = c("B"), alt_cip = c("120102"))
    expect_error(prep_fye_mice(m_student, m_term, alt_fye = x))
    x <- data.frame(institution = c("B"), alt_cip = c("14010A"))
    expect_error(prep_fye_mice(m_student, m_term, alt_fye = x))
    
    
    
    # set.seed(NULL)
    invisible(NULL)
}

test_prep_fye_mice()

