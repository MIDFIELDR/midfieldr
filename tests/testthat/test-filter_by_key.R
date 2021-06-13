context("filter_match")

# get_my_path() for data in the testing directory
# ctrl-shift-L to load internal functions

# filter_match<- function(dframe,        # data frame
#                          to,      # data frame
#                          by,       # character scalar
#                          ...,
#                          select = NULL) # column nmaes

load(file = get_my_path("subset_student.rda"))
load(file = get_my_path("subset_degree.rda"))

u1 <- subset_student[1:10, c(11, 12, 13)]

test_that("Inputs are correct class", {
  expect_error(
    filter_match(dframe = "wrong",
                  to = subset_student,
                  by = "mcid",
                  select = c("mcid", "degree")),
   "`dframe` must be of class data.frame"
  )
  expect_error(
    filter_match(subset_degree[1:10],
                  to = "wrong",
                  by = "mcid",
                  select = c("mcid", "degree")),
    "`to` must be of class data.frame"
  )
  expect_error(
    filter_match(subset_degree[1:10],
                  to = subset_student,
                  by = 2,
                  select = c("mcid", "degree")),
    "`by` must be of class character"
  )
  expect_error(
    filter_match(subset_degree[1:10],
                  to = subset_student,
                  by = "mcid",
                  select = TRUE),
    "`select` must be of class character"
  )
})

test_that("Common key_by column is present", {
  expect_error(
    filter_match(subset_degree[1:10],
                  subset_student,
                  "term", #mcid",
                  select = c("mcid", "degree")),
    "Column name `term` is not present in `to`"
  )
  expect_error(
    filter_match(subset_degree[1:10],
                  subset_student,
                  "race", #mcid",
                  select = c("mcid", "degree")),
    "Column name `race` is not present in `dframe`"
  )

})
