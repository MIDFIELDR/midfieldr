context("get_cip")

music_cip   <- get_cip(data = cip, keep_any = "^5009")
music_codes <- music_cip$cip6

test_that("Pipe correctly passes the data argument", {
  expect_equal(
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


