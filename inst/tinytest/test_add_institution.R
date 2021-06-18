test_add_institution <- function() {

    # function arguments
    # add_institution <- function(dframe, midfield_table)

    library("midfieldr")
    library("data.table")
    library("tinytest")
    options(datatable.print.class = TRUE)

    # correct answer
    id_inst <- toy_student[, .(mcid, institution)]
    id <- id_inst[, .(mcid)]
    DT <- add_institution(dframe = id, midfield_table = toy_term)
    expect_equal(id_inst, DT)

    # repeat using degree IDs
    id_inst <- toy_degree[, .(mcid, institution)]
    id <- id_inst[, .(mcid)]
    expect_equal(id_inst,
                 add_institution(dframe = id,
                                 midfield_table = toy_term))

    # joins to itself
    expect_equivalent(DT, add_institution(DT, midfield_table = toy_term))

    # overwrites existing institution column
    # showed that dframe must not be updated by reference
    expect_equal(id_inst,
                 add_institution(dframe = id_inst,
                                 midfield_table = toy_term))

    # midfield_table argument must term or equivalent
    expect_error(add_institution(DT, midfield_table = toy_student))

    # ID column required in both data frames
    # missing_column <- copy(DT)[, mcid := NULL]
    # expect_error(add_race_sex(DT, missing_column))
    # expect_error(add_race_sex(missing_column, DT))













    invisible(NULL)
}

test_add_institution()


# example
# id <- toy_student[, .(mcid)]
# DT1 <- add_institution(id, midfield_table = toy_term)
# head(DT1)
#
# DT2 <- add_institution(DT1, midfield_table = toy_term)
# all.equal(DT1, DT2)

