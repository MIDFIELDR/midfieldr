test_filter_match <- function() {

    library("midfieldr")
    library("data.table")


    toy_student <- toy_student[, .(mcid, institution, race, sex)]

    # create answer
    # cat(wrapr::draw_frame(
    #     filter_match(toy_student, study_students, "mcid")
    #     ))

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

    # Gives correct answer
    expect_equal(DT1,
                 filter_match(toy_student,
                              study_students,
                              "mcid"))
    expect_equal(DT2,
                 filter_match(toy_student,
                              study_students,
                              "mcid",
                              select = c("mcid", "institution")))


    invisible(NULL)
}

test_filter_match()

# example

# # subset degree table
# library("midfieldr")
# library("data.table")
# options(datatable.print.nrows = 10, datatable.print.class = TRUE)
#
# # small sample of student data
# toy_student
#
# # filter for students who earn a degree
# x_student <- filter_match(toy_student,
#              match_to = toy_degree,
#              by_col   = "mcid")
# x_student
#
# # repeat and select columns
# x_student <- filter_match(toy_student,
#              match_to = toy_degree,
#              by_col   = "mcid",
#              select   = c("mcid", "race", "sex"))
# x_student
#
# # engineers in the toy term data
# engr_term <- toy_term[grepl("^14", cip6)]
# engr_term
#
# # What are their admissions information
# x_student <- filter_match(toy_student,
#                    match_to = engr_term,
#                    by_col   = "mcid",
#                    select   = c("mcid", "institution", "transfer"))
#
# x_student
#
# # can use ID to match but exclude it from select, only unique rows returned
# x_student <- filter_match(toy_student,
#                            match_to = engr_term,
#                            by_col   = "mcid",
#                            select   = c("institution", "transfer", "sex"))
#
# x_student


