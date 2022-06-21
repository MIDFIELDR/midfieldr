test_filter_match <- function() {

    # usage
    # filter_match(dframe,
    #              match_to,
    #              by_col,
    #              ...,
    #              select = NULL)

    # Needed for tinytest::build_install_test()
    suppressMessages(library("data.table"))

    # example data frame for testing
    dframe <- toy_student[, .(mcid, institution, race, sex)]
    match_to_mcid <- dframe[1:10, .(mcid)]
    
    # create answer
    # cat(wrapr::draw_frame(
    #     filter_match(dframe, match_to_mcid, "mcid")
    # ))
    
    # correct answer
    DT1 <- wrapr::build_frame(
        "mcid"         , "institution"  , "race" , "sex"    |
            "MID25784187", "Institution M", "White", "Male"   |
            "MID25784974", "Institution M", "White", "Male"   |
            "MID25816209", "Institution M", "White", "Male"   |
            "MID25819358", "Institution M", "White", "Male"   |
            "MID25828870", "Institution M", "White", "Male"   |
            "MID25829749", "Institution M", "White", "Female" |
            "MID25841418", "Institution M", "White", "Male"   |
            "MID25845197", "Institution M", "White", "Female" |
            "MID25846316", "Institution M", "White", "Male"   |
            "MID25847220", "Institution M", "White", "Male"   )
    setDT(DT1)
    DT2 <- DT1[, .(mcid, institution)]

    expect_equal(DT1, filter_match(dframe, match_to_mcid, "mcid"))
    expect_equal(DT2, filter_match(dframe, 
                                   match_to_mcid,
                                   "mcid",
                                   select = c("mcid", "institution")))
    expect_equal(nrow(toy_degree),
                 nrow(filter_match(toy_student, toy_degree, "mcid")))

    # arguments after ... must be named
    expect_error(filter_match(dframe, 
                              match_to_mcid,
                              "mcid",
                              c("mcid", "institution"))) # select not named

    # arguments must be data frames
    expect_error(filter_match(dframe$mcid, match_to_mcid, "mcid"))
    expect_error(filter_match(dframe, match_to_mcid$mcid, "mcid"))

    invisible(NULL)
}

test_filter_match()




