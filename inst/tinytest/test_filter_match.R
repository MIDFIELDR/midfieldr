test_filter_match <- function() {

    # usage
    # filter_match(dframe,
    #              match_to,
    #              by_col,
    #              ...,
    #              select = NULL)

    # Needed for tinytest::build_install_test()
    library("data.table")

    # example data frame for testing
    toy_student <- toy_student[, .(mcid, institution, race, sex)]

    # create answer
    # cat(wrapr::draw_frame(
    #     filter_match(toy_student, study_students, "mcid")
    #     ))

    # Gives correct answer
    DT1 <- wrapr::build_frame(
        "mcid"         , "institution"  , "race" , "sex"    |
            "MID25828870", "Institution M", "White", "Male"   |
            "MID25845841", "Institution M", "White", "Female" |
            "MID25846316", "Institution M", "White", "Male"   |
            "MID25847220", "Institution M", "White", "Male"   |
            "MID25848589", "Institution M", "White", "Male"   |
            "MID25982250", "Institution B", "White", "Female" |
            "MID26319252", "Institution E", "White", "Male"   |
            "MID26439623", "Institution H", "White", "Male"   |
            "MID26577489", "Institution J", "White", "Male"   )
    setDT(DT1)
    DT2 <- DT1[, .(mcid, institution)]
    expect_equal(DT1,
                 filter_match(toy_student,
                              study_students,
                              "mcid"))
    expect_equal(DT2,
                 filter_match(toy_student,
                              study_students,
                              "mcid",
                              select = c("mcid", "institution")))
    expect_equal(nrow(toy_degree),
                 nrow(filter_match(toy_student, toy_degree, "mcid")))

    # arguments after ... must be named
    expect_error(filter_match(toy_student,
                              study_students,
                              "mcid",
                              c("mcid", "institution"))) # select not named

    # arguments must be data frames
    expect_error(filter_match(toy_student$mcid,
                              study_students,
                              "mcid"))
    expect_error(filter_match(toy_student,
                              study_students$mcid,
                              "mcid"))



    invisible(NULL)
}

test_filter_match()


# filter_match(toy_student,
#              toy_student,
#              c("mcid", "institution"))
