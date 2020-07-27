context("get_institution_limits")

# get_my_path() for data in the testing directory
# ctrl-shift-L to load internal functions

load(file = get_my_path("subset_terms.rda"))

test_that("Inputs are correct class", {
  expect_error(
    get_institution_limits(data = 6, span = 6),
    "`data` must be of class data.frame"
  )
  expect_error(
    get_institution_limits(data = subset_terms, span = "6"),
    "`span` must be of class numeric"
  )
})
test_that("Pipe correctly passes the data argument", {
  expect_equivalent(
    subset_terms %>% get_institution_limits(span = 6),
    get_institution_limits(data = subset_terms, span = 6)
  )
})
test_that("Required variables are present", {
  alt <- subset_terms
  alt$institution <- NULL
  expect_error(
    get_institution_limits(data = alt),
    "Column name `institution` required"
  )
  alt <- subset_terms
  alt$term <- NULL
  expect_error(
    get_institution_limits(data = alt),
    "Column name `term` required"
  )
})
test_that("Results are correct", {
  r1 <- get_institution_limits(subset_terms)
  # create r2, paste into test
  # cat(wrapr::draw_frame(r1))
  r2 <- wrapr::build_frame(
    "institution"     , "matric_limit", "data_limit" |
      "Institution B" , 20041         , 20093        |
      "Institution C" , 20091         , 20143        |
      "Institution F" , 19991         , 20044        )
  data.table::setDT(r2)
  expect_equal(r1, r2)
})
