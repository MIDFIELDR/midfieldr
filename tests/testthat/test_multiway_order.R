# run from devtools::test() only, otherwise the rds files are written
# to the project root directory

library(midfieldr)
library(tibble)
library(purrr)
library(dplyr)
library(testthat)
library(rprojroot)

# working directories differ for tests
# During package development (working directory: package root)
# When testing with devtools::test() (working directory: tests/testthat)
# When running R CMD check (working directory: a renamed recursive copy of tests)
# dir(is_testthat$find_file("hierarchy", path = is_r_package$find_file()))

context("multiway_order")

# test data
data("starwars", package = "dplyr")
# Observations: 87
# Variables: 13
# $ name       <chr> "Luke Skywalker", "C-3PO", "R2-D2", "Darth ...
# $ height     <int> 172, 167, 96, 202, 150, 178, 165, 97, 183, ...
# $ mass       <dbl> 77.0, 75.0, 32.0, 136.0, 49.0, 120.0, 75.0,...
# $ hair_color <chr> "blond", NA, NA, "none", "brown", "brown, g...
# $ skin_color <chr> "fair", "gold", "white, blue", "white", "li...
# $ eye_color  <chr> "blue", "yellow", "red", "yellow", "brown",...
# $ birth_year <dbl> 19.0, 112.0, 33.0, 41.9, 19.0, 52.0, 47.0, ...
# $ gender     <chr> "male", NA, NA, "male", "female", "male", "...
# $ homeworld  <chr> "Tatooine", "Tatooine", "Naboo", "Tatooine"...
# $ species    <chr> "Human", "Droid", "Droid", "Human", "Human"...
# $ films      <list> [<"Revenge of the Sith", "Return of the Je...
# $ vehicles   <list> [<"Snowspeeder", "Imperial Speeder Bike">,...
# $ starships  <list> [<"X-wing", "Imperial shuttle">, <>, <>, "...
df1 <- dplyr::select(starwars, name, species, mass)
df2 <- dplyr::select(starwars, name, species, mass) %>%
  dplyr::mutate_if(is.character, as.factor)
df3 <- dplyr::select(starwars, name, species, mass, height)
df4 <- dplyr::select(starwars, name, species, gender, mass)


test_that("Two character variables are converted to factors", {
  expect_equal( # input is character, character, numeric
    unname(purrr::map_chr(multiway_order(df1), class)),
    c("factor", "factor", "numeric")
  )
  expect_equal( # input is factor, factor, numeric
    unname(purrr::map_chr(multiway_order(df2), class)),
    c("factor", "factor", "numeric")
  )
})

test_that("Error for incorrect variable number and type", {
  expect_error(# more than one numeric variable
    multiway_order(df3),
    "value_len == 1 is not TRUE"
  )
  expect_error(# more than two categorical variables
    multiway_order(df4),
    "cat_len == 2 is not TRUE"
  )
})
