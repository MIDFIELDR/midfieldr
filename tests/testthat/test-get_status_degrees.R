context("get_status_degrees")

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
  expect_error(
    get_status_degrees(data = subset_degrees, keep_id = NULL),
    "Explicit `keep_id` argument required"
  )
})
test_that("Pipe correctly passes the data argument", {
  expect_equal(
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
  data.table::setDT(r1)
  r1 <- r1[order(id)]
  data.table::setDF(r1)
  # cat(wrapr::draw_frame(r1))
  r2 <- wrapr::build_frame(
    "id"           , "institution"  , "degree"              |
      "MID25869596", "Institution B", "Bachelor's Degree"   |
      "MID26057424", "Institution C", "Bachelor of Arts"    |
      "MID26682769", "Institution L", "Bachelor of Science" |
      "MID26686782", "Institution L", "Bachelor of Science" |
      "MID26687287", "Institution L", "Bachelor of Science" )
  data.table::setDF(r2)
  expect_equal(r1, r2)
})

