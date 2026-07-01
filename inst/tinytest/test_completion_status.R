
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

test_completion_status <- function() {
    
    # ---------- usage
    #
    # completion_status(dframe, midfield_rec = degree)
    
    # Needed for tinytest::build_install_test()
    suppressPackageStartupMessages(require("data.table"))
    
    # testing dataset
    test_DT <- wrapr::build_frame(
        "mcid"        , "timely_term", "term_degree" |
            "A1_OK"     , "19933"      , "19913"       |
            "A2_OK_tfr" , "19923"      , "19903"       |
            "A3_OK_tfr" , "19923"      , "19903"       |
            "A4_OK_late", "19943"      , "19953"       |
            "B1_exclude", "19983"      , "19963"       |
            "B2_exclude", "19983"      , NA_character_ |
            "B3_exclude", "19993"      , NA_character_ |
            "C1_exclude", "19883"      , "19873"       |
            "C2_exclude", "19913"      , "19893"       )
    setDT(test_DT)
    dframe <- test_DT[, .(mcid, timely_term)]
    dframe <- unique(dframe)
    degree <- test_DT[, .(mcid, term_degree)]
    degree <- unique(degree)
    
    # ---------- correct answers
    
    # check that class is preserved function
    expect_class_preserved(dframe, degree, completion_status)
    
    # correct answers manually set up
    DT <- completion_status(dframe, degree)
    DT <- unique(DT)
    
    expect_equal("timely", DT[mcid == "A1_OK", (completion_status)])
    expect_equal("timely", DT[mcid == "A2_OK_tfr", (completion_status)])
    expect_equal("timely", DT[mcid == "A3_OK_tfr", (completion_status)])
    expect_equal("late", DT[mcid == "A4_OK_late", (completion_status)])
    expect_equal("timely", DT[mcid == "B1_exclude", (completion_status)])
    expect_equal(NA_character_, DT[mcid == "B2_exclude", (completion_status)])
    expect_equal(NA_character_, DT[mcid == "B3_exclude", (completion_status)])
    expect_equal("timely", DT[mcid == "C1_exclude", (completion_status)])
    expect_equal("timely", DT[mcid == "C2_exclude", (completion_status)])
    
    # correct columns in place
    dframe_vars <- c("mcid", "timely_term")
    added_vars  <- c("term_degree", "completion_status")
    return_vars <- c(dframe_vars, added_vars)
    expect_equal(return_vars, colnames(DT))
    
    # correct answers naming and not naming arguments
    x <- completion_status(dframe = dframe, midfield_rec = degree)
    y <- completion_status(dframe, degree)
    expect_equal(x, y)
    rm(x, y)
    
    # ---------- errors
    
    # required column missing
    expect_error(completion_status(dframe[-mcid], degree))
    expect_error(completion_status(dframe, degree[-mcid]))
    
    # argument types incorrect
    expect_error(completion_status(dframe[["mcid"]], degree))
    expect_error(completion_status(dframe, degree[["mcid"]])) 
    
    invisible(NULL)
}

test_completion_status()

