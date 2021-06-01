context("filter_text")

# get_my_path() for data in the testing directory
# ctrl-shift-L to load internal functions

music_cip <- filter_text(cip, keep_text = "^5009")
music_codes <- music_cip$cip6


test_that("Non-character columns ignored", {
  u4 <- copy(music_cip)
  u4$cip2 <- as.numeric(u4$cip2)
  u4$row_num <- as.numeric(rownames(u4))
  u4$logic <- TRUE
  y4 <- filter_text(dframe = u4, keep_text = "^50091")
  y4$cip2 <- as.character(y4$cip2)
  y5 <- filter_text(dframe = music_cip, keep_text = "^50091")
  y5$row_num <- y4$row_num
  y5$logic <- TRUE
  expect_equal(y4, y5)

  u6 <- copy(u4)
  u6$logic[1:5] <- FALSE
  y6 <- filter_text(dframe = u6, keep_text = "TRUE")
  y7 <- filter_text(dframe = u6, keep_text = "^12$")
})
test_that("Class of data frame is preserved", {
  u0 <- copy(cip)
  y0 <- filter_text(dframe = u0, keep_text = "^5009")
  # data.frame
  u1 <- as.data.frame(u0)
  y1 <- as.data.frame(y0)
  expect_setequal(
    class(filter_text(dframe = u1, keep_text = "^5009")),
    class(y1)
  )
  # data.table
  u2 <- copy(u0)
  y2 <- copy(y0)
  expect_setequal(
    class(filter_text(dframe = u2, keep_text = "^5009")),
    class(y2)
  )
  # tibble
  u3 <- as.data.frame(copy(u0))
  y3 <- as.data.frame(copy(y0))
  data.table::setattr(u3, "class", c("tbl", "tbl_df", "data.frame"))
  data.table::setattr(y3, "class", c("tbl", "tbl_df", "data.frame"))
  expect_setequal(
    class(filter_text(dframe = u3, keep_text = "^5009")),
    class(y3)
  )
})
# test_that("Pipe correctly passes the dframe argument", {
#   expect_equivalent(
#     cip %>% filter_text(keep_text = c("^1407", "^1410")),
#     filter_text(cip, keep_text = c("^1407", "^1410"))
#   )
# })
test_that("Argument order works correctly", {
  expect_equal(
    filter_text(cip, keep_text = c("^1407", "^1410")),
    filter_text(cip, c("^1407", "^1410"))
  )
})
test_that("Data returned unaltered if keep and drop are NULL", {
  expect_equal(
    filter_text(music_cip, keep_text = NULL, drop_text = NULL),
    music_cip,
  )
})
test_that("Error if result is empty", {
  expect_error(
    filter_text(cip, keep_text = music_codes, drop_text = music_codes),
    "No CIPs satisfy the search criteria"
  )
  expect_error(
    filter_text(cip, keep_text = "enginerring"),
    "No CIPs satisfy the search criteria"
  )
})
test_that("Message if some keep_texts not found", {
  not_find <- c("Bogus", "111111")
  expect_message(
    filter_text(cip, keep_text = c(music_codes, not_find)),
    "Can't find these terms: Bogus, 111111"
  )
})
