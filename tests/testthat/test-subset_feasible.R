context("subset_feasible")

# get_my_path() for data in the testing directory
# ctrl-shift-L to load internal functions

load(file = get_my_path("subset_students.rda"))
id <- subset_students$id

test_that("Inputs are correct class", {
  expect_error(
    subset_feasible(id = as.factor(id)),
    "`id` must be of class character"
  )
  expect_error(
    subset_feasible(id = id, span = TRUE),
    "`span` must be of class numeric"
  )
  expect_error(
    subset_feasible(id = id, data_students = id),
    "`data` must be of class data.frame"
  )
  expect_error(
    subset_feasible(id = id, data_terms = id),
    "`data` must be of class data.frame"
  )
  expect_error(
    subset_feasible(id = id, data_degrees = id),
    "`data` must be of class data.frame"
  )
})
test_that("Pipe correctly passes the first argument", {
  expect_equivalent(
    subset_feasible(id = id),
    id %>% subset_feasible()
  )
})
test_that("Results are correct when everyone graduates", {
  r1 <- subset_feasible(id = id)
  r1 <- r1[1:10]
  r2 <- c("MID25855262",
               "MID25860597",
               "MID25864174",
               "MID25869725",
               "MID25875576",
               "MID25880493",
               "MID25886223",
               "MID25886894",
               "MID25888828",
               "MID25889468")
  expect_equal(r1, r2)
})
test_that("Results are correct when no one graduates", {
  testcase <- midfielddata::midfielddegrees[is.na(degree), .(id, institution)]
  testcase <- testcase[order(id)][1:20]
  id <- testcase$id
  r1 <- subset_feasible(id = id)
  r2 <- c("MID25783135",
          "MID25783147",
          "MID25783156",
          "MID25783220",
          "MID25783223",
          "MID25783226",
          "MID25783227",
          "MID25783284",
          "MID25783290",
          "MID25783301",
          "MID25783306",
          "MID25783344")
  expect_equal(r1, r2)
})




