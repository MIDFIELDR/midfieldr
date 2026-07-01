
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

# tinytest function
test_timely_term <- function() {
    
    # ---------- usage
    # 
    # timely_term(
    #     dframe,
    #     midfield_rec = term,
    #     ...,
    #     sched_span = NULL, 
    #     span = NULL
    # )
    
    # for tinytest::build_install_test()
    suppressPackageStartupMessages(require("data.table"))
    
    # testing dataset
    test_DT <- wrapr::build_frame(
        "mcid"        , "term" , "level"              |
            "A1_OK"     , "19881", "01 First-year"      |
            "A1_OK"     , "19891", "02 Second-year"     |
            "A1_OK"     , "19901", "03 Third-year"      |
            "A1_OK"     , "19913", "04 Fourth-year"     |
            "A2_OK_tfr" , "19881", "02 Second-year"     |
            "A2_OK_tfr" , "19891", "03 Third-year"      |
            "A2_OK_tfr" , "19903", "04 Fourth-year"     |
            "A3_OK_tfr" , "19891", "03 Third-year"      |
            "A3_OK_tfr" , "19903", "04 Fourth-year"     |
            "A4_OK_late", "19891", "01 First-year"      |
            "A4_OK_late", "19901", "02 Second-year"     |
            "A4_OK_late", "19911", "03 Third-year"      |
            "A4_OK_late", "19923", "04 Fourth-year"     |
            "A4_OK_late", "19933", "05 Fifth-year Plus" |
            "A4_OK_late", "19943", "05 Fifth-year Plus" |
            "A4_OK_late", "19953", "05 Fifth-year Plus" |
            "B1_exclude", "19931", "01 First-year"      |
            "B1_exclude", "19941", "02 Second-year"     |
            "B1_exclude", "19951", "03 Third-year"      |
            "B1_exclude", "19963", "04 Fourth-year"     |
            "B2_exclude", "19931", "01 First-year"      |
            "B2_exclude", "19941", "02 Second-year"     |
            "B3_exclude", "19941", "01 First-year"      |
            "B3_exclude", "19951", "02 Second-year"     |
            "B3_exclude", "19961", "03 Third-year"      |
            "C1_exclude", "19861", "03 Third-year"      |
            "C1_exclude", "19873", "04 Fourth-year"     |
            "C2_exclude", "19861", "01 First-year"      |
            "C2_exclude", "19871", "02 Second-year"     |
            "C2_exclude", "19881", "03 Third-year"      |
            "C2_exclude", "19893", "04 Fourth-year"     )
    setDT(test_DT)
    dframe <- unique(test_DT[, .(mcid)])
    term <- unique(test_DT[, .(mcid, term, level)])
    
    # ---------- correct answers
    
    # check that class is preserved function
    expect_class_preserved(dframe, term, timely_term)
    
    # correct answers manually set up
    DT <- timely_term(dframe, term)
    
    expect_equal("19933", DT[mcid == "A1_OK", (timely_term)])
    expect_equal("19923", DT[mcid == "A2_OK_tfr", (timely_term)])
    expect_equal("19923", DT[mcid == "A3_OK_tfr", (timely_term)])
    expect_equal("19943", DT[mcid == "A4_OK_late", (timely_term)])
    expect_equal("19983", DT[mcid == "B1_exclude", (timely_term)])
    expect_equal("19983", DT[mcid == "B2_exclude", (timely_term)])
    expect_equal("19993", DT[mcid == "B3_exclude", (timely_term)])
    expect_equal("19893", DT[mcid == "C1_exclude", (timely_term)])
    expect_equal("19913", DT[mcid == "C2_exclude", (timely_term)])
    
    # correct answers with different span
    DT <- timely_term(dframe, term, span = 5)
    
    expect_equal("19923", DT[mcid == "A1_OK", (timely_term)])
    expect_equal("19913", DT[mcid == "A2_OK_tfr", (timely_term)])
    expect_equal("19913", DT[mcid == "A3_OK_tfr", (timely_term)])
    expect_equal("19973", DT[mcid == "B1_exclude", (timely_term)])
    expect_equal("19973", DT[mcid == "B2_exclude", (timely_term)])
    expect_equal("19983", DT[mcid == "B3_exclude", (timely_term)])
    expect_equal("19883", DT[mcid == "C1_exclude", (timely_term)])
    expect_equal("19903", DT[mcid == "C2_exclude", (timely_term)])
    
    # optional arguments, NA same as NULL
    expect_equal(
        timely_term(dframe, term),
        timely_term(dframe, term, span = NA)
    )
    expect_equal(
        timely_term(dframe, term),
        timely_term(dframe, term, span = NULL)
    )
    
    # correct columns in place
    dframe_vars <- c("mcid")
    added_vars  <- c("term_i", "level_i", "adj_span", "timely_term")
    return_vars <- c(dframe_vars, added_vars)
    expect_equal(return_vars, colnames(DT))
    
    # correct answers naming and not naming arguments
    x <- timely_term(dframe = dframe, midfield_rec = term)
    y <- timely_term(dframe, term)
    expect_equal(x, y)
    rm(x, y)
    
    # ---------- errors
    
    # required column missing
    expect_error(timely_term(dframe[-mcid], term))
    expect_error(timely_term(dframe, term[-mcid]))
    
    # arguments after ... must be named
    expect_error(timely_term(dframe, term, 4))
    
    # argument types incorrect
    expect_error(timely_term(dframe[["mcid"]], term))
    expect_error(timely_term(dframe, term[["mcid"]])) 
    expect_error(timely_term(dframe, term, sched_span = TRUE))
    expect_error(timely_term(dframe, term, span = TRUE))
    
    # span must be >=  sched_span
    expect_error(timely_term(dframe, term, span = 2))
    
    invisible(NULL)
}

test_timely_term()
