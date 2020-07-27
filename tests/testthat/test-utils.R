context("utils")

# get_my_path() for data in the testing directory
# ctrl-shift-L to load internal functions

load(file = get_my_path("subset_terms.rda"))

# ------------------------------------------------------------------------

# kable2html()
test_that("kable2html() output has expected attributes", {
  x <- midfieldr::cip[1, ]
  y <- kable2html(x)
  z <- attributes(y)
  expect_equal(z$format, "html")
  expect_true(all(z$class %in% c("kableExtra", "knitr_kable")))
})

# filter_char_frame()
test_that("filter_char_frame() error if data is NULL", {
  expect_error(
    filter_char_frame(data = NULL),
    "Explicit `data` argument required"
  )
})

# ------------------------------------------------------------------------

# round_term()
iterm  <- c(1, 1, 3, 3, 3, 3)
output <- as.data.frame(iterm)

test_that("Term rounding is correct", {
  iterm  <- seq(1, 6)
  input  <- as.data.frame(iterm)
  r1 <- round_term(data = input, iterm_col = "iterm")
  r2 <- output
  expect_equal(r1$iterm, r2$iterm)
})
test_that("Data frame extensions are preserved", {
  # data.frame
  iterm  <- seq(1, 6)
  input  <- as.data.frame(iterm)
  r1 <- round_term(data = input, iterm_col = "iterm")
  r2 <- output
  expect_equivalent(class(r1), class(r2))
  # tibble
  iterm  <- seq(1, 6)
  input  <- as.data.frame(iterm)
  tibble_class <- c("tbl_df", "tbl", "data.frame")
  data.table::setattr(input, "class", tibble_class)
  r1 <- round_term(data = input, iterm_col = "iterm")
  expect_equivalent(class(r1), tibble_class)
  # data.table
  iterm  <- seq(1, 6)
  input <- data.table::as.data.table(as.data.frame(iterm))
  r1 <- round_term(data = input, iterm_col = "iterm")
  r2 <- data.table::as.data.table(output)
  expect_equivalent(class(r1), class(r2))
})

# ------------------------------------------------------------------------



