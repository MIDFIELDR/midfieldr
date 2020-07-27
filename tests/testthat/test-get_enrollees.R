context("get_enrollees")

# get_my_path() for data in the testing directory
# ctrl-shift-L to load internal functions

load(file = get_my_path("subset_terms.rda"))
music_codes <- get_cip(cip, "^5009")[["cip6"]]
subset_codes <- sort(subset_terms$cip6)[1:20]

test_that("Class of data frame is preserved", {
  u0 <- subset_terms
  y0 <- get_enrollees(data = u0, codes = subset_codes)
  # data.frame
  u1 <- as.data.frame(u0)
  y1 <- as.data.frame(y0)
  expect_setequal(
    class(get_enrollees(data = u1, codes = subset_codes)),
    class(y1)
  )
  # data.table
  u2 <- data.table::as.data.table(u0)
  y2 <- data.table::as.data.table(y0)
  expect_setequal(
    class(get_enrollees(data = u2, codes = subset_codes)),
    class(y2)
  )
  # tibble
  u3 <- as.data.frame(u0)
  y3 <- as.data.frame(y0)
  data.table::setattr(u3, "class", c("tbl", "tbl_df", "data.frame"))
  data.table::setattr(y3, "class", c("tbl", "tbl_df", "data.frame"))
  expect_setequal(
    class(get_enrollees(data = u3, codes = subset_codes)),
    class(y3)
  )
})
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
test_that("inputs are explicit", {
  expect_error(
    get_enrollees(data = subset_terms, codes = NULL),
    "Explicit `codes` argument required"
  )
})
test_that("Required variables are present", {
  alt <- subset_terms
  alt$id <- NULL
  expect_error(
    get_enrollees(data = alt, codes = music_codes),
    "Column name `id` required"
  )
  alt <- subset_terms
  alt$cip6 <- NULL
  expect_error(
    get_enrollees(data = alt, codes = music_codes),
    "Column name `cip6` required"
  )
})
test_that("Pipe correctly passes the data argument", {
  expect_equivalent(
    subset_students %>% get_enrollees(codes = subset_codes),
    get_enrollees(subset_students, codes = subset_codes)
  )
})
test_that("Results are correct", {
  r1 <- get_enrollees(codes = music_codes)
  r1 <- r1[order(id), ][
    1:10,
  ]
  # create r2, paste into test
  # cat(wrapr::draw_frame(r1))
  r2 <- wrapr::build_frame(
    "id"           , "cip6"   |
      "MID25853762", "500903" |
      "MID25854314", "500903" |
      "MID25855043", "500901" |
      "MID25857363", "500901" |
      "MID25857640", "500901" |
      "MID25857640", "500903" |
      "MID25858169", "500903" |
      "MID25861316", "500903" |
      "MID25864037", "500901" |
      "MID25864492", "500901" )
  data.table::setDT(r2)
  expect_equal(r1, r2)
})
