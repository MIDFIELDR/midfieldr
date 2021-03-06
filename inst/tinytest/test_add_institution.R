test_add_institution <- function() {

    # usage
    # add_institution(dframe, midfield_term)

    # Needed for tinytest::build_install_test()
    library("data.table")

    # correct answer
    id_inst <- toy_student[, .(mcid, institution)]
    id <- id_inst[, .(mcid)]
    DT <- add_institution(dframe = id, midfield_term = toy_term)
    expect_equal(id_inst, DT)

    # repeat using degree IDs
    id_inst <- toy_degree[, .(mcid, institution)]
    id <- id_inst[, .(mcid)]
    expect_equal(id_inst,
                 add_institution(dframe = id,
                                 midfield_term = toy_term))

    # joins to itself
    expect_equivalent(DT, add_institution(DT, midfield_term = toy_term))

    # overwrites existing institution column
    # showed that dframe must not be updated by reference
    expect_equal(id_inst,
                 add_institution(dframe = id_inst,
                                 midfield_term = toy_term))

    # midfield_term argument must be term or equivalent
    expect_error(add_institution(DT, midfield_term = toy_student))

    # ID column required in both data frames
    missing_column <- copy(toy_term)[, mcid := NULL]
    expect_error(add_institution(DT, missing_column))
    expect_error(add_institution(missing_column, DT))

    # institution and term columns required in midfield_term argument
    missing_column <- copy(toy_term)[, institution := NULL]
    expect_error(add_institution(DT, missing_column))
    missing_column <- copy(toy_term)[, term := NULL]
    expect_error(add_institution(DT, missing_column))

    # arguments must be data frames
    expect_error(add_institution(DT$mcid, midfield_term = toy_term))
    expect_error(add_institution(DT, midfield_term = toy_term$term))

    # arguments must be explicit
    expect_error(add_institution(NULL, midfield_term = toy_term))
    expect_error(add_institution(DT, midfield_term = NULL))


    # create an answer with NA in column?




    invisible(NULL)
}

test_add_institution()


# example
# id <- toy_student[, .(mcid)]
# DT1 <- add_institution(id, midfield_term = toy_term)
# head(DT1)
#
# DT2 <- add_institution(DT1, midfield_term = toy_term)
# all.equal(DT1, DT2)

