context("filter_char_frame")

music_cip   <- get_cip(data = cip, keep_any = "^5009")
music_codes <- music_cip$cip6

test_that("data must be data frame and not NULL", {
  expect_error(
    filter_char_frame(data = NULL),
    "`data` can't be NULL"
  )
  expect_error(
    filter_char_frame(data = music_codes),
    "`data` must be of class data.frame"
  )
})



