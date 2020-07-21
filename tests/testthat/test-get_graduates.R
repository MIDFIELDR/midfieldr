context("get_graduates")

# get_my_path() for data in the testing directory
# ctrl-shift-L to load internal functions

load(file = get_my_path("subset_degrees.rda"))

music_codes <- get_cip(cip, "^5009")[["cip6"]]
subset_codes <- sort(subset_degrees$cip6)[1:20]

test_that("inputs are correct class", {
  expect_error(
    get_graduates(data = music_codes, codes = music_codes),
    "`data` must be of class data.frame"
  )
  expect_error(
    get_graduates(data = subset_terms, codes = as.numeric(music_codes)),
    "`codes` must be of class character"
  )
})
test_that("inputs are explicit", {
  expect_error(
    get_graduates(data = subset_terms, codes = NULL),
    "Explicit `codes` argument required"
  )
})
test_that("Pipe correctly passes the data argument", {
  expect_equal(
    subset_degrees %>% get_graduates(codes = subset_codes),
    get_graduates(subset_degrees, codes = subset_codes)
  )
})
test_that("Required variables are present", {
  alt <- subset_degrees
  alt$id <- NULL
  expect_error(
    get_graduates(data = alt, codes = subset_codes),
    "Column name `id` required"
  )
  alt <- subset_degrees
  alt$cip6 <- NULL
  expect_error(
    get_graduates(data = alt, codes = subset_codes),
    "Column name `cip6` required"
  )
  alt <- subset_degrees
  alt$term_degree <- NULL
  expect_error(
    get_graduates(data = alt, codes = subset_codes),
    "Column name `term_degree` required"
  )
})
test_that("results are correct", {
  r1 <- get_graduates(codes = music_codes)
  data.table::setDT(r1)
  r1 <- r1[order(id), ][
    1:10,
  ]
  data.table::setDF(r1)

  # create r2, paste into test
  # cat(wrapr::draw_frame(r1))
  r2 <- wrapr::build_frame(
    "id"         , "cip6"   |
    "MID25854314", "500903" |
    "MID25855043", "500901" |
    "MID25858169", "500903" |
    "MID25861316", "500903" |
    "MID25867030", "500903" |
    "MID25869125", "500901" |
    "MID25873501", "500903" |
    "MID25873568", "500903" |
    "MID25878870", "500903" |
    "MID25880315", "500901" )

  data.table::setDF(r2)
  expect_equal(r1, r2)
})
