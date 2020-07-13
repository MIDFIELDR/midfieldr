context("get_enrollees")

# for interactive use only
# load("tests/testthat/testing-data/subset_terms.rda")

load(file = get_my_path("subset_terms.rda"))
music_codes <- get_cip(cip, "^5009")[["cip6"]]
subset_codes <- sort(subset_terms$cip6)[1:20]

test_that("Inputs are correct class", {
  expect_error(
    get_enrollees(data = music_codes, codes = music_codes),
    "`data` must be of class data.frame"
  )
  expect_error(
    get_enrollees(data = subset_terms, codes = as.numeric(music_codes)),
    "`codes` must be of class character"
  )
})
test_that("Pipe correctly passes the data argument", {
  expect_equal(
    subset_students %>% get_enrollees(codes = subset_codes),
    get_enrollees(subset_students, codes = subset_codes)
  )
})
test_that("Results are correct", {
  r1 <- get_enrollees(codes = music_codes)
  data.table::setDT(r1)
  r1 <- r1[order(id), ][
    1:10, ]
  data.table::setDF(r1)

  # create r2, paste into test
  # cat(wrapr::draw_frame(r1))
  r2 <- wrapr::build_frame(
    "id"           , "cip6"   |
      "MID25853762", "500903" |
      "MID25854314", "500903" |
      "MID25855043", "500901" |
      "MID25857363", "500901" |
      "MID25857640", "500903" |
      "MID25857640", "500901" |
      "MID25858169", "500903" |
      "MID25861316", "500903" |
      "MID25864037", "500901" |
      "MID25864492", "500901" )
  data.table::setDF(r2)
  expect_equal(r1, r2)
})
