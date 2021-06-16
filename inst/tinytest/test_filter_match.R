test_filter_match <- function() {

    library("midfieldr")
    library("data.table")

    # function arguments
    # filter_match <- function(dframe,
    #                          match_to,
    #                          by_col,
    #                          ...,
    #                          select = NULL)

    # example data frame for testing
    toy_student <- toy_student[, .(mcid, institution, race, sex)]

    # create answer
    # cat(wrapr::draw_frame(
    #     filter_match(toy_student, study_students, "mcid")
    #     ))

    # Gives correct answer
    DT1 <- wrapr::build_frame(
        "mcid"         , "institution"  , "race" , "sex"    |
            "MID25845841", "Institution M", "White", "Female" |
            "MID25851790", "Institution M", "White", "Male"   |
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

    invisible(NULL)
}

test_filter_match()



