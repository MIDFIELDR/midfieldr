context("order_multiway")

# ctrl-shift-L to load internal functions

# to create df, paste into test
# set.seed(20200710)
# cat1 <- rep(c("urban", "rural", "suburb", "village"), each = 2)
# cat2 <- rep(c("men", "women"), times = 4)
# val  <- round(runif(n = 8), 2)
# df1 <- data.frame(cat1, cat2, val)
# cat(wrapr::draw_frame(df1))
df1 <- wrapr::build_frame(
  "cat1"     , "cat2" , "val" |
    "urban"  , "men"  , 0.22  |
    "urban"  , "women", 0.14  |
    "rural"  , "men"  , 0.43  |
    "rural"  , "women", 0.58  |
    "suburb" , "men"  , 0.81  |
    "suburb" , "women", 0.46  |
    "village", "men"  , 0.15  |
    "village", "women", 0.2   )

test_that("Pipe correctly passes the data argument", {
  expect_equal(
    df1 %>% order_multiway(),
    order_multiway(df1)
  )
  expect_equal(
    df1 %>% order_multiway() %>% order_multiway(),
    order_multiway(df1)
  )
})
test_that("Results are correct type", {
  df2 <- order_multiway(df1)
  expect_type(df1$cat1, "character")
  expect_type(df2$cat1, "integer")
  expect_type(df1$val, "double")
  expect_type(df2$val, "double")
  expect_equal(nlevels(df2$cat1), 4)
  expect_equal(nlevels(df2$cat2), 2)
})
test_that("data argument has correct form", {
  expect_error(
    order_multiway(),
    "Explicit `data` argument required"
  )
  expect_error(
    order_multiway(df1[["cat1"]]),
    "`data` must be of class data.frame"
  )
  expect_error(
    order_multiway(df1[, c("cat1", "val")]),
    "`data` must have exactly three columns"
  )
  df3 <- df1
  df3$val <- as.character(df3$val)
  expect_error(
    order_multiway(df3),
    paste(
      "`data` must have one numeric column",
      "and two character columns"
    )
  )
  df4 <- df1[, c("cat1", "val")]
  df4$val2 <- 2.5
  expect_error(
    order_multiway(df4),
    paste(
      "`data` must have one numeric column",
      "and two character columns"
    )
  )
})
