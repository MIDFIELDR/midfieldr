context("completion_feasible")

# get_my_path() for data in the testing directory
# ctrl-shift-L to load internal functions

load(file = get_my_path("subset_students.rda"))
id <- subset_students$id

test_that("Inputs are correct class", {
  expect_error(
    completion_feasible(id = as.factor(id)),
    "`id` must be of class character"
  )
  expect_error(
    completion_feasible(id = id, span = TRUE),
    "`span` must be of class numeric"
  )
  expect_error(
    completion_feasible(id = id, data_students = id),
    "`data_students` must be of class data.frame"
  )
  expect_error(
    completion_feasible(id = id, data_terms = id),
    "`data_terms` must be of class data.frame"
  )
  expect_error(
    completion_feasible(id = id, data_degrees = id),
    "`data_degrees` must be of class data.frame"
  )
})
test_that("Pipe correctly passes the first argument", {
  expect_equal(
    completion_feasible(id = id),
    id %>% completion_feasible(.)
  )
})
test_that("Results are correct", {
  midfid <- sort(completion_feasible(id = id))
  midfid <- as.data.frame(midfid)
  midfid <- midfid[c(1:10), , drop = FALSE]
  # create r2, paste into test
  # cat(wrapr::draw_frame(midfid))
  midfid2 <- wrapr::build_frame(
    "midfid"      |
      "MID25858162" |
      "MID25859329" |
      "MID25865775" |
      "MID25869596" |
      "MID25870903" |
      "MID25875567" |
      "MID25877186" |
      "MID25878105" |
      "MID25881203" |
      "MID25881216" )
  data.table::setDF(midfid2)
  expect_equal(midfid, midfid2)
})
