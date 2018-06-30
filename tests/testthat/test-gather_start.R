context("gather_start")

library(dplyr)

cip_group <- cip_filter(cip, series = "^54")
cip_group <- cip_label(cip_group, program = "cip2name")
starters <- gather_start(cip_group = cip_group)
startersplus <- gather_start(cip_group = cip_group, transfer = TRUE)
minus_program <- select(cip_group, -program)
cip6_start <- mutate(cip_group, start = cip6)

df <- midfielddata::midfieldstudents
df <- rename(df, start = cip6)
df_starters <- gather_start(df, cip_group = cip_group)

test_that("gather_start produces correct output", {
  expect_equal(unique(starters[["start"]]), c("540101", "540104"))
  expect_equal(dim(starters), c(561, 2))
  expect_equal(starters, df_starters)
})

test_that("Error if argument not a data frame", {
  x <- runif(10)
  expect_error(
    gather_start(x, cip_group = cip_group),
    "midfieldr::gather_start() arguments must be a data frame or tbl",
    fixed = TRUE
  )
  expect_error(
    gather_start(cip_group = x),
    "midfieldr::gather_start() arguments must be a data frame or tbl",
    fixed = TRUE
  )
})

test_that("Transfer student TRUE works correctly", {
  expect_equal(dim(startersplus), c(857, 2))
})

test_that("Error cip_group variable mistakes", {
  # expect_error(
  # 	gather_start(cip_group = minus_program),
  # 	"midfieldr::gather_start() data frame must include a `program` variable",
  # 	fixed = TRUE
  # 	)
  expect_error(
    gather_start(cip_group = cip6_start),
    "midfieldr::gather_start() data frame must not include both a `cip6` and 'start' variable",
    fixed = TRUE
  )
})
