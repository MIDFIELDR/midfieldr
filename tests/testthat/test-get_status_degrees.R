context("get_status_degrees")

# get_my_path() for data in the testing directory
# ctrl-shift-L to load internal functions

load(file = get_my_path("subset_degrees.rda"))
subset_id <- subset_degrees$id[1:5]

test_that("Inputs exist and are are correct class", {
  expect_error(
    get_status_degrees(data = subset_id, keep_id = subset_id),
    "`data` must be of class data.frame"
  )
  expect_error(
    get_status_degrees(data = subset_degrees, keep_id = as.factor(subset_id)),
    "`keep_id` must be of class character"
  )
})
test_that("Pipe correctly passes the data argument", {
  expect_equivalent(
    subset_degrees %>% get_status_degrees(keep_id = subset_id),
    get_status_degrees(subset_degrees, keep_id = subset_id)
  )
})
test_that("Required variables are present", {
  alt <- subset_degrees
  alt$institution <- NULL
  expect_error(
    get_status_degrees(data = alt, keep_id = subset_id),
    "Column name `institution` required"
  )
  alt <- subset_degrees
  alt$id <- NULL
  expect_error(
    get_status_degrees(data = alt, keep_id = subset_id),
    "Column name `id` required"
  )
  alt <- subset_degrees
  alt$degree <- NULL
  expect_error(
    get_status_degrees(data = alt, keep_id = subset_id),
    "Column name `degree` required"
  )
})
test_that("Results are correct", {
  r1 <- get_status_degrees(keep_id = subset_id)
  # cat(wrapr::draw_frame(r1))
  r2 <- wrapr::build_frame(
    "id"           , "institution"  , "degree"            |
      "MID25855262", "Institution B", "Bachelor's Degree" |
      "MID25860597", "Institution B", "Bachelor's Degree" |
      "MID25864174", "Institution B", "Bachelor's Degree" |
      "MID25869725", "Institution B", "Bachelor's Degree" |
      "MID25875576", "Institution B", "Bachelor's Degree" )
  data.table::setDT(r2)
  expect_equal(r1, r2)
})

