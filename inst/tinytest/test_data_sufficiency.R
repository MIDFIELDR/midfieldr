
# function used in the test
expect_class_preserved <- function(df1, df2, fnc) {
    
    run_check <- function(x, y, fnc) {
        z <- fnc(x, y)
        expect_equal(class(x), class(z))
        expect_equal(class(y), class(z))
    }
    
    # runs 3 checks: data.frame, tibble, data.table
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

test_data_sufficiency <- function() {
    
    # ---------- usage
    # 
    # data_sufficiency(dframe, midfield_rec = term)
    
    # Needed for build_install_test()
    suppressPackageStartupMessages(require("data.table"))
    
    # testing dataset
    test_DT <- wrapr::build_frame(
        "mcid"        , "term_i", "timely_term", "term" , "institution" |
            "A1_OK"     , "19881" , "19933"      , "19881", "Inst X"      |
            "A1_OK"     , "19881" , "19933"      , "19891", "Inst X"      |
            "A1_OK"     , "19881" , "19933"      , "19901", "Inst X"      |
            "A1_OK"     , "19881" , "19933"      , "19913", "Inst X"      |
            "A2_OK_tfr" , "19881" , "19923"      , "19881", "Inst X"      |
            "A2_OK_tfr" , "19881" , "19923"      , "19891", "Inst X"      |
            "A2_OK_tfr" , "19881" , "19923"      , "19903", "Inst X"      |
            "A3_OK_tfr" , "19891" , "19923"      , "19891", "Inst X"      |
            "A3_OK_tfr" , "19891" , "19923"      , "19903", "Inst X"      |
            "A4_OK_late", "19891" , "19943"      , "19891", "Inst X"      |
            "A4_OK_late", "19891" , "19943"      , "19901", "Inst X"      |
            "A4_OK_late", "19891" , "19943"      , "19911", "Inst X"      |
            "A4_OK_late", "19891" , "19943"      , "19923", "Inst X"      |
            "A4_OK_late", "19891" , "19943"      , "19933", "Inst X"      |
            "A4_OK_late", "19891" , "19943"      , "19943", "Inst X"      |
            "A4_OK_late", "19891" , "19943"      , "19953", "Inst X"      |
            "B1_exclude", "19931" , "19983"      , "19931", "Inst X"      |
            "B1_exclude", "19931" , "19983"      , "19941", "Inst X"      |
            "B1_exclude", "19931" , "19983"      , "19951", "Inst X"      |
            "B1_exclude", "19931" , "19983"      , "19963", "Inst X"      |
            "B2_exclude", "19931" , "19983"      , "19931", "Inst X"      |
            "B2_exclude", "19931" , "19983"      , "19941", "Inst X"      |
            "B3_exclude", "19941" , "19993"      , "19941", "Inst X"      |
            "B3_exclude", "19941" , "19993"      , "19951", "Inst X"      |
            "B3_exclude", "19941" , "19993"      , "19961", "Inst X"      |
            "C1_exclude", "19861" , "19883"      , "19861", "Inst X"      |
            "C1_exclude", "19861" , "19883"      , "19873", "Inst X"      |
            "C2_exclude", "19861" , "19913"      , "19861", "Inst X"      |
            "C2_exclude", "19861" , "19913"      , "19871", "Inst X"      |
            "C2_exclude", "19861" , "19913"      , "19881", "Inst X"      |
            "C2_exclude", "19861" , "19913"      , "19893", "Inst X"      )
    setDT(test_DT)
    dframe <- test_DT[, .(mcid, term_i, timely_term)]
    dframe <- unique(dframe)
    term <- test_DT[, .(mcid, term, institution)]
    term <- unique(term)
    
    # ---------- correct answers
    
    # check that class is preserved function
    expect_class_preserved(dframe, term, data_sufficiency)
    
    # correct answers manually set up
    DT <- data_sufficiency(dframe, term)
    DT <- unique(DT)
    
    expect_equal("include", DT[mcid == "A1_OK", (data_sufficiency)])
    expect_equal("include", DT[mcid == "A2_OK_tfr", (data_sufficiency)])
    expect_equal("include", DT[mcid == "A3_OK_tfr", (data_sufficiency)])
    expect_equal("include", DT[mcid == "A4_OK_late", (data_sufficiency)])
    expect_equal("exclude-upper", DT[mcid == "B1_exclude", (data_sufficiency)])
    expect_equal("exclude-upper", DT[mcid == "B2_exclude", (data_sufficiency)])
    expect_equal("exclude-upper", DT[mcid == "B3_exclude", (data_sufficiency)])
    expect_equal("exclude-lower", DT[mcid == "C1_exclude", (data_sufficiency)])
    expect_equal("exclude-lower", DT[mcid == "C2_exclude", (data_sufficiency)])
    
    # correct columns in place
    dframe_vars <- c("mcid", "term_i", "timely_term")
    added_vars  <- c("institution", "lower_limit", 
                     "upper_limit", "data_sufficiency")
    return_vars <- c(dframe_vars, added_vars)
    expect_equal(return_vars, colnames(DT))
    
    # correct answers naming and not naming arguments
    x <- data_sufficiency(dframe = dframe, midfield_rec = term)
    y <- data_sufficiency(dframe, term)
    expect_equal(x, y)
    rm(x, y)
    
    # ---------- errors
    
    # required column missing
    expect_error(data_sufficiency(dframe[-mcid], term))
    expect_error(data_sufficiency(dframe, term[-mcid]))
    
    # argument types incorrect
    expect_error(data_sufficiency(dframe[["mcid"]], term))
    expect_error(data_sufficiency(dframe, term[["mcid"]])) 
    
    invisible(NULL)
}

test_data_sufficiency()






