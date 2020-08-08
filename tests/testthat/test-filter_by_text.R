context("filter_by_text")

# get_my_path() for data in the testing directory
# ctrl-shift-L to load internal functions

music_cip <- filter_by_text(data = cip, keep_text = "^5009")
music_codes <- music_cip$cip6

test_that("Class of data frame is preserved", {
  u0 <- cip
  y0 <- filter_by_text(data = u0, keep_text = "^5009")
  # data.frame
  u1 <- as.data.frame(u0)
  y1 <- as.data.frame(y0)
  expect_setequal(
    class(filter_by_text(data = u1, keep_text = "^5009")),
    class(y1)
  )
  # data.table
  u2 <- data.table::as.data.table(u0)
  y2 <- data.table::as.data.table(y0)
  expect_setequal(
    class(filter_by_text(data = u2, keep_text = "^5009")),
    class(y2)
  )
  # tibble
  u3 <- as.data.frame(u0)
  y3 <- as.data.frame(y0)
  data.table::setattr(u3, "class", c("tbl", "tbl_df", "data.frame"))
  data.table::setattr(y3, "class", c("tbl", "tbl_df", "data.frame"))
  expect_setequal(
    class(filter_by_text(data = u3, keep_text = "^5009")),
    class(y3)
  )
})
test_that("Pipe correctly passes the data argument", {
  expect_equivalent(
    cip %>% filter_by_text(keep_text = c("^1407", "^1410")),
    filter_by_text(cip, keep_text = c("^1407", "^1410"))
  )
})
test_that("Argument order works correctly", {
  expect_equal(
    filter_by_text(cip, keep_text = c("^1407", "^1410")),
    filter_by_text(cip, c("^1407", "^1410"))
  )
})
test_that("Data returned unaltered if keep and drop are NULL", {
  expect_equal(
    filter_by_text(music_cip, keep_text = NULL, drop_text = NULL),
    music_cip,
  )
})
test_that("Error if result is empty", {
  expect_error(
    filter_by_text(cip, keep_text = music_codes, drop_text = music_codes),
    "No CIPs satisfy the search criteria"
  )
  expect_error(
    filter_by_text(cip, keep_text = "enginerring"),
    "No CIPs satisfy the search criteria"
  )
})
test_that("Message if some patterns not found", {
  not_find <- c("Bogus", "111111")
  expect_message(
    filter_by_text(cip, keep_text = c(music_codes, not_find)),
    "Can't find these terms: Bogus, 111111"
  )
})
