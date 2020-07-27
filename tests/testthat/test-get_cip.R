context("get_cip")

# get_my_path() for data in the testing directory
# ctrl-shift-L to load internal functions

music_cip <- get_cip(data = cip, keep_any = "^5009")
music_codes <- music_cip$cip6

test_that("Class of data frame is preserved", {
  u0 <- cip
  y0 <- get_cip(data = u0, keep_any = "^5009")
  # data.frame
  u1 <- as.data.frame(u0)
  y1 <- as.data.frame(y0)
  expect_setequal(
    class(get_cip(data = u1, keep_any = "^5009")),
    class(y1)
  )
  # data.table
  u2 <- data.table::as.data.table(u0)
  y2 <- data.table::as.data.table(y0)
  expect_setequal(
    class(get_cip(data = u2, keep_any = "^5009")),
    class(y2)
  )
  # tibble
  u3 <- as.data.frame(u0)
  y3 <- as.data.frame(y0)
  data.table::setattr(u3, "class", c("tbl", "tbl_df", "data.frame"))
  data.table::setattr(y3, "class", c("tbl", "tbl_df", "data.frame"))
  expect_setequal(
    class(get_cip(data = u3, keep_any = "^5009")),
    class(y3)
  )
})
test_that("Pipe correctly passes the data argument", {
  expect_equivalent(
    cip %>% get_cip(keep_any = c("^1407", "^1410")),
    get_cip(cip, keep_any = c("^1407", "^1410"))
  )
})
test_that("Argument order works correctly", {
  expect_equal(
    get_cip(keep_any = c("^1407", "^1410")),
    get_cip(cip, c("^1407", "^1410"))
  )
})
test_that("Data returned unaltered if keep and drop are NULL", {
  expect_equal(
    get_cip(music_cip, keep_any = NULL, drop_any = NULL),
    music_cip,
  )
})
test_that("Error if result is empty", {
  expect_error(
    get_cip(data = cip, keep_any = music_codes, drop_any = music_codes),
    "No CIPs satisfy the search criteria"
  )
  expect_error(
    get_cip(data = cip, keep_any = "enginerring"),
    "No CIPs satisfy the search criteria"
  )
})
test_that("Message if some patterns not found", {
  not_find <- c("Bogus", "111111")
  expect_message(
    get_cip(data = cip, keep_any = c(music_codes, not_find)),
    "Can't find these terms: Bogus, 111111"
  )
})
