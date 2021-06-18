test_add_race_sex <- function() {

    library("tinytest")
    library("checkmate")
    using("checkmate")

    # function arguments
    # add_race_sex <- function(dframe, midfield_table)


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

    # overwrites existing race and sex columns
    expect_equal(DT,
                 add_race_sex(dframe = DT, midfield_table = toy_student))

    # joins to itself (equivalent due to key)
    expect_equivalent(DT, add_race_sex(DT, midfield_table = DT))

    # midfield_table argument must student or equivalent
    expect_error(add_race_sex(DT, midfield_table = toy_degree))

    # ID column required in both data frames
    missing_column <- copy(DT)[, mcid := NULL]
    expect_error(add_race_sex(DT, missing_column))
    expect_error(add_race_sex(missing_column, DT))

    # race and sex columns required in midfield_table argument
    missing_column <- copy(DT)[, race := NULL]
    expect_error(add_race_sex(DT, missing_column))
    missing_column <- copy(DT)[, sex := NULL]
    expect_error(add_race_sex(DT, missing_column))

    # arguments must be data frames
    expect_error(add_race_sex(NULL, midfield_table = toy_student))
    expect_error(add_race_sex(DT$mcid, midfield_table = toy_student))
    expect_error(add_race_sex(DT, midfield_table = NULL))
    expect_error(add_race_sex(DT, midfield_table = toy_student$race))

    invisible(NULL)
}

test_add_race_sex()


