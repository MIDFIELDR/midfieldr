context("label_programs")

# ctrl-shift-L to load internal functions

music_cip <- get_cip(cip, "^5009")

test_that("Inputs are correct class", {
  expect_error(
    label_programs(data = NULL, label = "Music"),
    "Explicit `data` argument required"
  )
  expect_equal(
    label_programs(data = music_cip, label = NULL),
    label_programs(data = music_cip, label = "cip4name")
  )
  expect_error(
    label_programs(data = NA, label = "Music"),
    "`data` must be of class data.frame"
  )
  expect_error(
    label_programs(data = music_cip, label = NA),
    "`label` must be of class character"
  )
  alt_cip <- music_cip
  alt_cip$cip2name <- as.factor(alt_cip$cip2name)
  expect_error(
    label_programs(data = alt_cip, label = "cip2name"),
    "Column `cip2name` must be character class"
  )
  alt_cip <- music_cip
  alt_cip$cip4name <- as.factor(alt_cip$cip4name)
  expect_error(
    label_programs(data = alt_cip, label = "cip4name"),
    "Column `cip4name` must be character class"
  )
  alt_cip <- music_cip
  alt_cip$cip6 <- as.factor(alt_cip$cip6)
  expect_error(
    label_programs(data = alt_cip, label = "cip6name"),
    "Columns `cip6` and `cip6name` must be character class"
  )
  alt_cip <- music_cip
  alt_cip$cip6name <- as.factor(alt_cip$cip6name)
  expect_error(
    label_programs(data = alt_cip, label = "cip6name"),
    "Columns `cip6` and `cip6name` must be character class"
  )
})
test_that("Pipe correctly passes the data argument", {
  expect_equal(
    music_cip %>% label_programs(label = "Music"),
    label_programs(music_cip, label = "Music")
  )
})
test_that("Results are correct", {
  r1 <- label_programs(data = music_cip, label = "Music")
  data.table::setDT(r1)
  r1 <- r1[order(cip6)][
    1:10
  ]
  data.table::setDF(r1)
  # cat(wrapr::draw_frame(r1))
  r2 <- wrapr::build_frame(
    "cip6"    , "cip6name"                            , "program" |
      "500901", "Music, General"                      , "Music"   |
      "500902", "Music History, Literature and Theory", "Music"   |
      "500903", "Music Performance, General"          , "Music"   |
      "500904", "Music Theory and Composition"        , "Music"   |
      "500905", "Musicology and Ethnomusicology"      , "Music"   |
      "500906", "Conducting"                          , "Music"   |
      "500907", "Piano and Organ"                     , "Music"   |
      "500908", "Voice and Opera"                     , "Music"   |
      "500909", "Music Management and Merchandising"  , "Music"   |
      "500910", "Jazz, Jazz Studies"                  , "Music"   )
  data.table::setDF(r2)
  expect_equal(r1, r2)
})
test_that("Extra columns in data have no effect", {
  alt_cip <- music_cip
  alt_cip$extra <- "extra"
  expect_equal(
    label_programs(music_cip, label = "Music"),
    label_programs(alt_cip, label = "Music")
  )
})
test_that("label argument options create expected results", {
  expect_equal(
    label_programs(music_cip, label = "cip2name"),
    label_programs(music_cip, label = "Visual and Performing Arts")
  )
  expect_equal(
    label_programs(music_cip, label = "cip6name")["cip6name"],
    music_cip["cip6name"]
  )
})
test_that("Error if program variable already exists", {
  alt_cip <- music_cip
  alt_cip$program <- "Music"
  expect_error(
    label_programs(data = alt_cip, label = "Music"),
    "`data` may not include an existing `program` column"
  )
})
test_that("Required variables are present", {
  alt <- music_cip
  alt$cip6 <- NULL
  expect_error(
    label_programs(data = alt, label = "Music"),
    "Column name `cip6` required"
  )
  alt <- music_cip
  alt$cip6name <- NULL
  expect_error(
    label_programs(data = alt, label = "Music"),
    "Column name `cip6name` required"
  )
  alt <- music_cip
  alt$cip2name <- NULL
  expect_error(
    label_programs(data = alt, label = "cip2name"),
    "Column name `cip2name` required when `label = cip2name`"
  )
  alt <- music_cip
  alt$cip4name <- NULL
  expect_error(
    label_programs(data = alt, label = "cip4name"),
    "Column name `cip4name` required when `label = cip4name` or NULL"
  )
  alt <- music_cip
  alt$cip4name <- NULL
  expect_error(
    label_programs(data = alt, label = NULL),
    "Column name `cip4name` required when `label = cip4name` or NULL"
  )
})
