context("prepare_fye_mi")

load(file = get_my_path("subset_students.rda"))
load(file = get_my_path("subset_terms.rda"))

test_that("data_terms required variables are present", {
    # id, cip6, term
    alt <- copy(subset_terms)
    alt$id <- NULL
    expect_error(
        prepare_fye_mi(data_terms = alt),
        "Column name `id` required"
    )
    alt <- copy(subset_terms)
    alt$cip6 <- NULL
    expect_error(
        prepare_fye_mi(data_terms = alt),
        "Column name `cip6` required"
    )
    alt <- copy(subset_terms)
    alt$term <- NULL
    expect_error(
        prepare_fye_mi(data_terms = alt),
        "Column name `term` required"
    )
})
test_that("data_terms required variables are correct class", {
    # id, cip6, term
    alt <- copy(subset_terms)
    alt$id <- as.numeric(rownames(alt))
    expect_error(
        prepare_fye_mi(data_terms = alt),
        "`id` must be of class character"
    )
    alt <- copy(subset_terms)
    alt$cip6 <- as.numeric(rownames(alt))
    expect_error(
        prepare_fye_mi(data_terms = alt),
        "`cip6` must be of class character"
    )
    alt <- copy(subset_terms)
    alt$term <- as.character(alt$term)
    expect_error(
        prepare_fye_mi(data_terms = alt),
        "`term` must be of class numeric"
    )
})
test_that("data_students required variables are present", {
    # id, cip6, institution, race, sex
    alt <- copy(subset_students)
    alt$id <- NULL
    expect_error(
        prepare_fye_mi(data_students = alt),
        "Column name `id` required"
    )
    alt <- copy(subset_students)
    alt$institution <- NULL
    expect_error(
        prepare_fye_mi(data_students = alt),
        "Column name `institution` required"
    )
    alt <- copy(subset_students)
    alt$race <- NULL
    expect_error(
        prepare_fye_mi(data_students = alt),
        "Column name `race` required"
    )
    alt <- copy(subset_students)
    alt$sex <- NULL
    expect_error(
        prepare_fye_mi(data_students = alt),
        "Column name `sex` required"
    )
})
test_that("data_students required variables are correct class", {
    # id, cip6, institution, race, sex
    alt <- copy(subset_students)
    alt$id <- as.numeric(rownames(alt))
    expect_error(
        prepare_fye_mi(data_students = alt),
        "`id` must be of class character"
    )
    alt <- copy(subset_students)
    alt$cip6 <- as.numeric(rownames(alt))
    expect_error(
        prepare_fye_mi(data_students = alt),
        "`cip6` must be of class character"
    )
    alt <- copy(subset_students)
    alt$institution <- as.numeric(rownames(alt))
    expect_error(
        prepare_fye_mi(data_students = alt),
        "`institution` must be of class character"
    )
    alt <- copy(subset_students)
    alt$race <- as.numeric(rownames(alt))
    expect_error(
        prepare_fye_mi(data_students = alt),
        "`race` must be of class character"
    )
    alt <- copy(subset_students)
    alt$sex <- as.numeric(rownames(alt))
    expect_error(
        prepare_fye_mi(data_students = alt),
        "`sex` must be of class character"
    )
})
test_that("Input data frames are correct class", {
    expect_error(
        prepare_fye_mi(data_students = NA,
                       data_terms = subset_terms),
        "`data_students` must be of class data.frame"
    )
    expect_error(
        prepare_fye_mi(data_students = subset_students,
                       data_terms = NA),
        "`data_terms` must be of class data.frame"
    )
})
test_that("Output columns are correct type", {
    alt <- prepare_fye_mi()[1:10]
    expect_equal(class(alt$id), "character")
    expect_equal(class(alt$institution), "factor")
    expect_equal(class(alt$race), "factor")
    expect_equal(class(alt$sex), "factor")
    expect_equal(class(alt$cip), "factor")
})
test_that("Output factors have expected levels", {
    alt <- prepare_fye_mi()[1:10]
    expect_equal(sort(levels(alt$institution)),
                 c("Institution B",
                   "Institution F" ,
                   "Institution J",
                   "Institution M"))
    expect_equal(sort(levels(alt$race)),
                 c("Asian",
                   "Black",
                   "Hispanic",
                   "International",
                   "Native American",
                   "Other",
                   "White"))
    expect_equal(sort(levels(alt$sex)), c("Female", "Male"))
})
test_that("Results are correct", {
    alt <- copy(subset_students)
    rows_we_want <- alt$cip6 %chin% c("14XXXX", "14YYYY")
    cols_we_want <- c("id", "cip6", "institution", "race", "sex")
    alt <- alt[rows_we_want, ..cols_we_want]
    r1 <- alt[order(id)]
    # cat(wrapr::draw_frame(r1))
    r2 <- wrapr::build_frame(
            "id"         , "cip6"  , "institution"  , "race"    , "sex"    |
            "MID26359115", "14YYYY", "Institution F", "Asian"   , "Male"   |
            "MID26360012", "14YYYY", "Institution F", "White"   , "Female" |
            "MID26360287", "14YYYY", "Institution F", "White"   , "Male"   |
            "MID26361588", "14YYYY", "Institution F", "White"   , "Female" |
            "MID26362268", "14YYYY", "Institution F", "White"   , "Male"   |
            "MID26371808", "14YYYY", "Institution F", "White"   , "Male"   |
            "MID26383557", "14YYYY", "Institution F", "Hispanic", "Male"   |
            "MID26383660", "14YYYY", "Institution F", "White"   , "Female" |
            "MID26384177", "14YYYY", "Institution F", "Asian"   , "Male"   |
            "MID26385262", "14YYYY", "Institution F", "White"   , "Female" )
    data.table::setDT(r2)
    expect_equal(r1, r2)
})
