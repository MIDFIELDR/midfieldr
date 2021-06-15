test_filter_match <- function() {

    library("midfieldr")
    library("data.table")
    data(study_students)

    # obtain the student subset
    load("../extdata/subset_student.rda")

    # for interactive use only
    load("inst/extdata/subset_student.rda")
    load("inst/extdata/subset_course.rda")
    load("inst/extdata/subset_term.rda")
    load("inst/extdata/subset_degree.rda")

       subset_student <- subset_student[, .(mcid, institution, race, sex)]

    # create answer
    # cat(wrapr::draw_frame(
    #     filter_match(subset_student, study_students, "mcid")
    #     ))

    DT1 <- wrapr::build_frame(
        "mcid"         , "institution"  , "race"           , "sex"    |
            "MID25853054", "Institution B", "International"  , "Male"   |
            "MID25855484", "Institution B", "White"          , "Female" |
            "MID25865076", "Institution B", "White"          , "Male"   |
            "MID25865971", "Institution B", "International"  , "Male"   |
            "MID25867435", "Institution B", "White"          , "Male"   |
            "MID25868987", "Institution B", "White"          , "Female" |
            "MID25869725", "Institution B", "White"          , "Male"   |
            "MID25879386", "Institution B", "White"          , "Male"   |
            "MID25885535", "Institution B", "Hispanic/Latinx", "Male"   )
    setDT(DT1)
    DT2 <- DT1[, .(mcid, institution)]


    # Gives correct answer
    expect_equal(DT1,
                 filter_match(subset_student,
                              study_students,
                              "mcid"))
    expect_equal(DT2,
                 filter_match(subset_student,
                              study_students,
                              "mcid",
                              select = c("mcid", "institution")))



    invisible(NULL)
}

test_filter_match()

# # example
# library("midfielddata")
# data(degree)
#
# # subset degree table
# filter_match(degree,
#              match_to = study_programs,
#              by_col   = "cip6",
#              select   = c("mcid", "institution", "cip6"))

