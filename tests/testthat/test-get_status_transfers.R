context("get_status_transfers")

# get_my_path() for data in the testing directory
# ctrl-shift-L to load internal functions

load(file = get_my_path("subset_students.rda"))
subset_id <- subset_students$id[1:5]

test_that("Inputs exist and are are correct class", {
  expect_error(
    get_status_transfers(data = subset_id, keep_id = subset_id),
    "`data` must be of class data.frame"
  )
  expect_error(
    get_status_transfers(data = subset_students, keep_id = as.factor(subset_id)),
    "`keep_id` must be of class character"
  )
  expect_error(
    get_status_transfers(data = subset_students, keep_id = NULL),
    "Explicit `keep_id` argument required"
  )
})
test_that("Pipe correctly passes the data argument", {
  expect_equivalent(
    subset_students %>% get_status_transfers(keep_id = subset_id),
    get_status_transfers(subset_students, keep_id = subset_id)
  )
})
test_that("Required variables are present", {
  alt <- subset_students
  alt$id <- NULL
  expect_error(
    get_status_transfers(data = alt, keep_id = subset_id),
    "Column name `id` required"
  )
  alt <- subset_students
  alt$term_enter <- NULL
  expect_error(
    get_status_transfers(data = alt, keep_id = subset_id),
    "Column name `term_enter` required"
  )
  alt <- subset_students
  alt$hours_transfer <- NULL
  expect_error(
    get_status_transfers(data = alt, keep_id = subset_id),
    "Column name `hours_transfer` required"
  )
})
test_that("Results are correct", {
  r1 <- get_status_transfers(keep_id = subset_id)
  # cat(wrapr::draw_frame(r1))
  r2 <- wrapr::build_frame(
    "id"         , "term_enter", "hours_transfer" |
    "MID25855262", 20041       , 30               |
    "MID25860597", 20041       , 33               |
    "MID25864174", 20051       , 30               |
    "MID25869725", 19911       , 51               |
    "MID25875576", 19971       , 62               )
  data.table::setDT(r2)
  expect_equivalent(r1, r2)
})

