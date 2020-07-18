context("get_status_transfers")

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
  expect_equal(
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
  data.table::setDT(r1)
  r1 <- r1[order(id)]
  data.table::setDF(r1)
  # cat(wrapr::draw_frame(r1))
  r2 <- wrapr::build_frame(
    "id"         , "term_enter", "hours_transfer" |
    "MID25869596", 19911       , 89               |
    "MID25912621", 19951       , 63               |
    "MID25974990", 19931       , 15               |
    "MID26369225", 20001       , 20               |
    "MID26372096", 20031       , 59               )
  data.table::setDF(r2)
  expect_equal(r1, r2)
})

