context("utils")

# ctrl-shift-L to load internal functions
#
# kable2html()
test_that("kable2html() output has expected attributes", {
  x <- midfieldr::cip[1, ]
  y <- kable2html(x)
  z <- attributes(y)
  expect_equal(z$format, "html")
  expect_true(all(z$class %in% c("kableExtra", "knitr_kable")))
})

# filter_char_frame
test_that("filter_char_frame() error if data is NULL", {
  expect_error(
    filter_char_frame(data = NULL),
    "Explicit `data` argument required"
  )
})







# x <- cip[1, ]
# subset_students <- subset_students
# id_set <- subset_students[["id"]][c(5, 10, 15, 20)]
# subset_terms <- subset_terms
# id_set2 <- subset_terms[["id"]][c(1, 3, 5, 7, 11, 13)]
#
#
#
# # term_separate() ------------------------------------
# test_that("Data argument is a data frame or tbl", {
#   expect_error(
#     term_separate(data = runif(10), col = "term"),
#     "term_separate data argument must be a data frame or tbl"
#   )
#   expect_error(
#     term_separate(data = NULL, col = "term"),
#     "term_separate data argument must be a data frame or tbl"
#   )
# })
# test_that("YYYY is correctly extracted from YYYYT", {
#   expect_equal(
#     term_separate(data = subset_terms, col = "term")[["term_year"]],
#     floor(term_separate(data = subset_terms, col = "term")[["term"]] / 10)
#   )
# })
# test_that("Error when col argument is NULL or misnamed", {
#   expect_error(
#     term_separate(data = subset_terms, col = NULL),
#     "term_separate col argument cannot be NULL."
#   )
#   expect_error(
#     term_separate(data = subset_terms, col = "not_term"),
#     "term_separate incorrect value for col argument."
#   )
# })
# test_that("Error if YYYYT has not 5 digits", {
#   x <- subset_terms
#
#   x$term[1] <- 1000
#   expect_error(
#     term_separate(data = x, col = "term"),
#     "term_separate YYYYT values can have 5 digits only."
#   )
#   x$term[1] <- 9999
#   expect_error(
#     term_separate(data = x, col = "term"),
#     "term_separate YYYYT values can have 5 digits only."
#   )
#   x$term[1] <- 100000
#   expect_error(
#     term_separate(data = x, col = "term"),
#     "term_separate YYYYT values can have 5 digits only."
#   )
#
#   x$term[1] <- 999999
#   expect_error(
#     term_separate(data = x, col = "term"),
#     "term_separate YYYYT values can have 5 digits only."
#   )
# })
#
# # id_filter() ---------------------------------
# x <- subset_students
# x_id <- x[["id"]][1:5]
# test_that("Data argument is a data frame or tbl", {
#   expect_error(
#     id_filter(data = NULL, keep_id = x_id),
#     "id_filter. 'data' argument must be a data frame or tbl."
#   )
# })
# test_that("Filter returns the correct records", {
#   expect_equal(
#     x_id,
#     id_filter(x, x_id)[["id"]]
#   )
# })
#
# test_that("Error when `keep_id` argument is NULL", {
#   expect_error(
#     id_filter(data = x, keep_id = NULL),
#     "id_filter. 'keep_id' argument cannot be NULL."
#   )
# })
#
