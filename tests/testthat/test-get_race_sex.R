context("get_race_sex")

# for interactive use only
# load("tests/testthat/testing-data/subset_students.rda")

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







# music_codes <- get_cip(cip, "^5009")[["cip6"]]
# student_id  <- get_enrollees(codes = music_codes)[["id"]]
# subset_id   <- sort(subset_students$id)[1:20]
#


# test_that("data must be data frame", {
#   expect_error(
#     get_race_sex(data = music_codes),
#     "`data` must be a data.frame"
#   )
# })
# test_that("keep_id is an atomic character vector", {
#   expect_error(
#     get_race_sex(keep_id = list("MID25853762", "MID25854314")),
#     "`keep_id` must be a character vector"
#   )
#   expect_error(
#     get_race_sex(keep_id = 500903),
#     "`keep_id` must be a character vector"
#   )
#   expect_error(
#     get_race_sex(keep_id = list("500903")),
#     "`keep_id` must be a character vector"
#   )
#   expect_error(
#     get_race_sex(),
#     "Can't find a `keep_id` argument"
#   )
# })
