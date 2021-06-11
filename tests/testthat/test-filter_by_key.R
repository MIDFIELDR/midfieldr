context("filter_by_key")

# get_my_path() for data in the testing directory
# ctrl-shift-L to load internal functions

# filter_by_key<- function(dframe,        # data frame
#                          match_to,      # data frame
#                          key_col,       # character scalar
#                          ...,
#                          select = NULL) # column nmaes

load(file = get_my_path("subset_student.rda"))
load(file = get_my_path("subset_degree.rda"))

u1 <- subset_student[1:10, c(11, 12, 13)]

test_that("Inputs are correct class", {
  expect_error(
    filter_by_key(dframe = "wrong",
                  match_to = subset_student,
                  key_col = "mcid",
                  select = c("mcid", "degree")),
   "`dframe` must be of class data.frame"
  )
  expect_error(
    filter_by_key(subset_degree[1:10],
                  match_to = "wrong",
                  key_col = "mcid",
                  select = c("mcid", "degree")),
    "`match_to` must be of class data.frame"
  )
  expect_error(
    filter_by_key(subset_degree[1:10],
                  match_to = subset_student,
                  key_col = 2,
                  select = c("mcid", "degree")),
    "`key_col` must be of class character"
  )
  expect_error(
    filter_by_key(subset_degree[1:10],
                  match_to = subset_student,
                  key_col = "mcid",
                  select = TRUE),
    "`select` must be of class character"
  )
})

test_that("Common key_by column is present", {
  expect_error(
    filter_by_key(subset_degree[1:10],
                  subset_student,
                  "term", #mcid",
                  select = c("mcid", "degree")),
    "Column name `term` is not present in `match_to`"
  )
  expect_error(
    filter_by_key(subset_degree[1:10],
                  subset_student,
                  "race", #mcid",
                  select = c("mcid", "degree")),
    "Column name `race` is not present in `dframe`"
  )

})
