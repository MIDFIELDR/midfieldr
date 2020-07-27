context("get_institution_hours_term")

# get_my_path() for data in the testing directory
# ctrl-shift-L to load internal functions

load(file = get_my_path("subset_terms.rda"))

test_that("Class of data frame is preserved", {
  u0 <- subset_terms
  u0_id <- subset_terms$id
  y0 <- get_institution_hours_term(data = u0, keep_id = u0_id)
  # data.frame
  u1 <- as.data.frame(u0)
  y1 <- as.data.frame(y0)
  expect_setequal(
    class(get_institution_hours_term(data = u1, keep_id = u0_id)),
    class(y1)
  )
  # data.table
  u2 <- data.table::as.data.table(u0)
  y2 <- data.table::as.data.table(y0)
  expect_setequal(
    class(get_institution_hours_term(data = u2, keep_id = u0_id)),
    class(y2)
  )
  # tibble
  u3 <- as.data.frame(u0)
  y3 <- as.data.frame(y0)
  data.table::setattr(u3, "class", c("tbl", "tbl_df", "data.frame"))
  data.table::setattr(y3, "class", c("tbl", "tbl_df", "data.frame"))
  expect_setequal(
    class(get_institution_hours_term(data = u3, keep_id = u0_id)),
    class(y3)
  )
})
test_that("Results are correct", {
  r1_id <- sort(subset_terms$id)
  r1 <- get_institution_hours_term(data = subset_terms, keep_id = r1_id)

  # create r2, paste into test
  # cat(wrapr::draw_frame(r1))
  r2 <- wrapr::build_frame(
    "institution"     , "median_hr_per_term" |
      "Institution B" , 13                   |
      "Institution C" , 14                   |
      "Institution F" , 14                   )
  data.table::setDT(r2)
  expect_equal(r1, r2)
})

