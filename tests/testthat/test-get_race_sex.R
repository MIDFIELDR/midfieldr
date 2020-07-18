context("get_race_sex")

# ctrl-shift-L to load internal functions

load(file = get_my_path("subset_students.rda"))
subset_id <- subset_students$id[1:5]

test_that("Inputs exist and are are correct class", {
  expect_error(
    get_race_sex(data = subset_id, keep_id = subset_id),
    "`data` must be of class data.frame"
  )
  expect_error(
    get_race_sex(data = subset_students, keep_id = as.factor(subset_id)),
    "`keep_id` must be of class character"
  )
  expect_error(
    get_race_sex(data = subset_students, keep_id = NULL),
    "Explicit `keep_id` argument required"
  )
})
test_that("Pipe correctly passes the data argument", {
  expect_equal(
    subset_students %>% get_race_sex(keep_id = subset_id),
    get_race_sex(subset_students, keep_id = subset_id)
  )
})
test_that("Required variables are present", {
  alt <- subset_students
  alt$id <- NULL
  expect_error(
    get_race_sex(data = alt, keep_id = subset_id),
    "Column name `id` required"
  )
  alt <- subset_students
  alt$race <- NULL
  expect_error(
    get_race_sex(data = alt, keep_id = subset_id),
    "Column name `race` required"
  )
  alt <- subset_students
  alt$sex <- NULL
  expect_error(
    get_race_sex(data = alt, keep_id = subset_id),
    "Column name `sex` required"
  )
})
test_that("Results are correct", {
  r1 <- get_race_sex(keep_id = subset_id)
  data.table::setDT(r1)
  r1 <- r1[order(id)]
  data.table::setDF(r1)
  # cat(wrapr::draw_frame(r1))
  r2 <- wrapr::build_frame(
    "id"         , "race" , "sex"    |
    "MID25869596", "White", "Female" |
    "MID25912621", "White", "Female" |
    "MID25974990", "White", "Male"   |
    "MID26369225", "Asian", "Male"   |
    "MID26372096", "Black", "Male"   )
  data.table::setDF(r2)
  expect_equal(r1, r2)
})



