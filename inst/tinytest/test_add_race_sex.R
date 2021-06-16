test_add_race_sex <- function() {

    # function arguments
    # add_race_sex <- function(dframe,
    #                          midfield_table)


    library(data.table)
    options(datatable.print.nrows = 10, datatable.print.class = TRUE)

    # create an answer
    # DT <- toy_degree[1:10, .(mcid, cip6)]
    # DT <- add_race_sex(dframe = DT, midfield_table = toy_student)
    # cat(wrapr::draw_frame(DT))

    DT <- wrapr::build_frame(
            "mcid"       , "cip6"  , "race"         , "sex"    |
            "MID25783939", "010901", "White"        , "Female" |
            "MID25808099", "521401", "White"        , "Female" |
            "MID25826223", "131202", "White"        , "Female" |
            "MID25840802", "520201", "White"        , "Female" |
            "MID25845841", "520201", "White"        , "Female" |
            "MID25851790", "143501", "White"        , "Male"   |
            "MID25853332", "450601", "International", "Male"   |
            "MID25877946", "451001", "White"        , "Female" |
            "MID25880643", "260101", "White"        , "Female" |
            "MID25887008", "140401", "Other/Unknown", "Male"   )
    setDT(DT)

    # answer is correct
    expect_equal(DT,
                 add_race_sex(dframe = toy_degree[1:10, .(mcid, cip6)],
                              midfield_table = toy_student))






    invisible(NULL)
}

test_add_race_sex()






