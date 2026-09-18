
# functions used in the test
expect_class_preserved <- function(x, fnc) {
  run_check <- function(x, fnc) {
    z <- fnc(x)
    expect_equal(class(x), class(z))
  }
  x <- copy(x)
  # run check 3 times: data.frame, tibble, data.table
  x <- as.data.frame(x)
  run_check(x, fnc)
  setattr(x, "class", c("tbl_df", "tbl", "data.frame"))
  run_check(x, fnc)
  x <- as.data.table(x)
  run_check(x, fnc)
  # done
  rm(x)
}

test_rm_redundant_cols <- function() {
  
  # usage
  # rm_redundant_cols(dframe)
  
  # Needed for tinytest::build_install_test()
  suppressPackageStartupMessages(require("data.table"))
  
  # ---------- class preserved
  
  expect_class_preserved(toy_student, rm_redundant_cols)
  
  # grouped tibble yields tibble
  x <- copy(toy_student)
  setattr(x, "class", c("grouped_df", "tbl_df", "tbl", "data.frame"))
  y <- select_basic_cols(x)
  expect_equal(class(y), c("tbl_df", "tbl", "data.frame"))
  
  # ---------- correct answers
  
  # set up test dframe
  dframe <- copy(toy_degree)
  dframe <- unique(dframe[4:6, 
                          .(mcid = paste0("mc_", c("01", "02", "03")), 
                            cip6, term = term_degree)])
  
  # no effect if names (after split) are unique and values different
  x <- copy(dframe)
  ans01 <- rm_redundant_cols(x)
  expect_equal(ans01, dframe)
  
  # no effect if names (after split) are unique and values identical
  x <- copy(dframe)
  x[, case.1 := term]
  ans02 <- rm_redundant_cols(x)
  expect_equal(ans02, x)
  
  # no effect if names (after split) are not unique but values different
  x <- copy(dframe)
  x[, term.1 := mcid]
  ans03 <- rm_redundant_cols(x)
  expect_equal(names(ans03), c(names(dframe), "term.1"))
  
  # drop column if names (after split) and values duplicate a previous column
  x <- copy(dframe)
  x[, term.1 := term]
  x[, term.any := term]
  ans04 <- rm_redundant_cols(x)
  expect_equal(ans04, dframe)
  
  # drop multiple duplicates
  x <- copy(dframe)
  x[, case.1 := term]
  x[, case.any := term]
  ans05 <- rm_redundant_cols(x)
  expect_equal(ans05, ans02)
  
  # the only separator used is the period
  x <- copy(dframe)
  x[, term_2 := term]
  ans06 <- rm_redundant_cols(x)
  x[, term.2 := term]
  ans07 <- rm_redundant_cols(x)
  expect_equal(ans06, ans07)
  expect_equal(TRUE, "term_2" %chin% names(ans07))
  expect_equal(FALSE, "term.2" %chin% names(ans07))
  
  # retain the leftmost column even if it has the suffix
  x <- copy(dframe)
  x[, term.1 := term]
  setcolorder(x, "term.1")
  ans08 <- rm_redundant_cols(x)
  expect_equal(TRUE, "term.1" %chin% names(ans08))
  expect_equal(FALSE, "term" %chin% names(ans08))
  

  
  
  
  
  
  # function output not printed
  invisible(NULL)
}

test_rm_redundant_cols()






