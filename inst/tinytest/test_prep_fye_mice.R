
# function used in the test
expect_class_preserved <- function(df1, df2, df3, fnc) {
    
    run_check <- function(w, x, y, fnc) {
        z <- fnc(w, x, y)
        expect_equal(class(w), class(z))
        expect_equal(class(x), class(z))
        expect_equal(class(y), class(z))
    }

    w <- copy(df1)
    x <- copy(df2)
    y <- copy(df3)
    
    # run check 3 times: data.frame, tibble, data.table
    w <- as.data.frame(w)
    x <- as.data.frame(x)
    y <- as.data.frame(y)
    run_check(w, x, y, fnc)
    
    setattr(w, "class", c("tbl_df", "tbl", "data.frame"))
    setattr(x, "class", c("tbl_df", "tbl", "data.frame"))
    setattr(y, "class", c("tbl_df", "tbl", "data.frame"))
    run_check(w, x, y, fnc)
    
    w <- as.data.table(w)
    x <- as.data.table(x)
    y <- as.data.table(y)
    run_check(w, x, y, fnc)
    
    # done
    rm(w, x, y)
}

test_prep_fye_mice <- function() {
    
    # usage
    # prep_fye_mice(midf_student,     # mcid, race, sex
    #               midf_term,        # mcid, term, institution, cip6
    #               fye_codes = NULL) # institution, fye_cip6
    
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
    fye_cip   <- data.frame(institution = c("A", "B"), 
                            fye_cip6 = c("140102", "140101"))
    correct_ans <- test_data[!proxy %like% "omit", 
                             .(mcid, 
                               institution = factor(institution), 
                               race = factor(race), 
                               sex = factor(sex), 
                               proxy = factor(proxy))] |> unique()
    
    # answer is correct using two FYE CIP codes
    expect_equal(
        correct_ans,
        prep_fye_mice(m_student, m_term, fye_cip)
    )
    
    # check that class is preserved function
    expect_class_preserved(m_student, m_term, fye_cip, prep_fye_mice)
    
    # Results are factors except for ID
    DT <- prep_fye_mice(m_student, m_term, fye_cip)
    expect_equal(class(DT[, mcid]), "character")
    expect_equal(class(DT[, institution]), "factor")
    expect_equal(class(DT[, race]), "factor")
    expect_equal(class(DT[, sex]), "factor")
    expect_equal(class(DT[, proxy]), "factor")
    
    # change Inst from A to J to test default FYE codes
    m_term_2 <- copy(m_term)
    m_term_2[institution == "A", institution := "Institution J"]
    correct_ans_2 <- copy(correct_ans)
    correct_ans_2 <- correct_ans_2[institution != "B"]
    correct_ans_2[, institution := "Institution J"]
    expect_equal(
        correct_ans_2,
        prep_fye_mice(m_student, m_term_2)
    )
    
    # Missing student variable, that ID is dropped
    x <- copy(m_student)
    x <- x[mcid == "A-to-ME", race := NA_character_]
    y <- copy(m_term)
    z <- copy(correct_ans)
    expect_equal(
        z[mcid != "A-to-ME"],
        prep_fye_mice(x, y, fye_cip)
    )
    
    # Missing term variable no effect if contains a duplicated CIP
    x <- copy(m_student)
    y <- copy(m_term)
    y$term[2] <- NA_character_
    expect_equal(
        correct_ans,
        prep_fye_mice(x, y, fye_cip)
    )
    
    # Missing term variable for FYE terms, that ID is dropped
    x <- copy(m_student)
    y <- copy(m_term)
    y$term[1:2] <- NA_character_
    z <- copy(correct_ans)
    expect_equal(
        z[mcid != "A-to-ME"],
        prep_fye_mice(x, y, fye_cip)
    )
    
    # Missing term variable for post-FYE Engng terms, proxy is NA
    x <- copy(m_student)
    y <- copy(m_term)
    y$term[3] <- NA_character_
    z <- copy(correct_ans)
    expect_equal(
        z[1, proxy := NA_character_],
        prep_fye_mice(x, y, fye_cip)
    )

    # Required variables as factors OK, converted to character
    x <- copy(m_student)
    y <- copy(m_term)
    x$race <- as.factor(x$race)
    expect_equal(
        correct_ans,
        prep_fye_mice(x, y, fye_cip)
    )
    
    # ---------- error checks
    
    # Arguments required as data frames
    expect_error(prep_fye_mice(1, m_term, fye_cip))
    expect_error(prep_fye_mice(m_student, 1, fye_cip))
    expect_error(prep_fye_mice(m_student, m_term, 1))
    
    # Missing variables that are required
    expect_error(prep_fye_mice(m_student[, mcid := NULL], m_term, fye_cip))
    expect_error(prep_fye_mice(m_student, m_term[, mcid := NULL], fye_cip))
    expect_error(prep_fye_mice(m_student, m_term, fye_cip[, institution := NULL]))
    
    # Incorrect class of required columns
    expect_error(prep_fye_mice(m_student[, mcid := as.factor(mcid)], m_term, fye_cip))
    
    # Checking values of CIP codes
    # 6 digits required
    y <- copy(m_term)
    y$cip6[1] <- "14010" 
    expect_error(prep_fye_mice(m_student, y, fye_cip))
    # start with 14 required
    y <- copy(m_term)
    y$cip6[1] <- "120102" 
    expect_error(prep_fye_mice(m_student, y, fye_cip))
    # all digits required
    y <- copy(m_term)
    y$cip6[1] <- "14010A" 
    expect_error(prep_fye_mice(m_student, y, fye_cip))
    
    # set.seed(NULL)
    invisible(NULL)
}

test_prep_fye_mice()

