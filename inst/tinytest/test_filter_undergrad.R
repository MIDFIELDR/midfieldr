
# function used in the test
expect_class_preserved <- function(x, y, fnc) {
  
  run_check <- function(x, y, fnc) {
    z <- fnc(x, y)
    expect_equal(class(x), class(z))
    expect_equal(class(y), class(z))
  }
  
  x <- copy(x)
  y <- copy(y)
  
  # run check 3 times: data.frame, tibble, data.table
  x <- as.data.frame(x)
  y <- as.data.frame(y)
  run_check(x, y, fnc)
  
  setattr(x, "class", c("tbl_df", "tbl", "data.frame"))
  setattr(y, "class", c("tbl_df", "tbl", "data.frame"))
  run_check(x, y, fnc)
  
  x <- as.data.table(x)
  y <- as.data.table(y)
  run_check(x, y, fnc)
  
  # done
  rm(x, y)
}

test_filter_undergrad <- function() {
  
  # usage
  # filter_undergrad(dframe, midf_table = degree)
  
  # ---------- setup
  
  # Needed for tinytest::build_install_test()
  suppressPackageStartupMessages(require("data.table"))
  
  # column names to be added (optional)
  new_cols <- c("bacc_term")
  
  # ---------- start tests
  
  # check that class is preserved function
  expect_class_preserved(toy_term, toy_degree, filter_undergrad)
  
  # check for incorrect input class / required variables
  expect_error(filter_undergrad(1))
  expect_error(filter_undergrad(toy_term, "sat"))
  expect_error(filter_undergrad(toy_student, toy_degree))
  expect_error(filter_undergrad(toy_degree, toy_student))
  
  # with/without add_bacc_term option
  x <- copy(toy_term)
  y <- copy(toy_degree)
  w <- filter_undergrad(x, y, add_bacc_term = FALSE)
  z <- filter_undergrad(x, y, add_bacc_term = TRUE)
  
  # added column when option TRUE
  expect_equal(new_cols, setdiff(colnames(z), colnames(x)))

  # manually filter, result should match default
  z <- z[bacc_term >= term | is.na(bacc_term)]
  z[, bacc_term := NULL]
  expect_equal(w, z)
  
  # ---------- repeat for course table
  # with/without add_bacc_term option
  x <- copy(toy_course)
  y <- copy(toy_degree)
  w <- filter_undergrad(x, y, add_bacc_term = FALSE)
  z <- filter_undergrad(x, y, add_bacc_term = TRUE)
  
  # added column when option TRUE
  expect_equal(new_cols, setdiff(colnames(z), colnames(x)))
  
  # manually filter, result should match default
  z <- z[bacc_term >= term_course | is.na(bacc_term)]
  z[, bacc_term := NULL]
  expect_equal(w, z)
  
  # ---------- repeat for degree table
  # with/without add_bacc_term option
  x <- copy(toy_degree)
  y <- copy(toy_degree)
  w <- filter_undergrad(x, y, add_bacc_term = FALSE)
  z <- filter_undergrad(x, y, add_bacc_term = TRUE)
  
  # added column when option TRUE
  expect_equal(new_cols, setdiff(colnames(z), colnames(x)))
  
  # manually filter, result should match default
  z <- z[bacc_term >= term_degree | is.na(bacc_term)]
  z[, bacc_term := NULL]
  expect_equal(w, z)
  
  # confirm NO changes by reference
  term <- copy(toy_term)
  degr <- copy(toy_degree)
  z <- filter_undergrad(term, degr)
  expect_true(check_equiv_frames(term, toy_term))
  expect_true(check_equiv_frames(degr, toy_degree))
 expect_equal(x[["idx"]], y[["idx"]])
  
  
  
  
  
  
  # check filter results are correct
  # dframe required variables: mcid, term (or term_course or term_degree)
  # degree required variables: mcid, term_degree
  
  x_term <- wrapr::build_frame(
    "mcid", "term" |
      "1", "20011" | # pre-degree
      "1", "20013" | # first-degree
      "1", "20021" | # post-first-degree (drop 3, post)
      
      "2", "20023" | # pre-degree
      "2", "20031" | # first-degree
      
      "3", "20033" | # pre-degree
      "3", "20041" | # first-degree
      "3", "20041" | # first-degree (drop 8, duplicate)
      
      "4", "20043" | # pre-degree
      "4", "20051" | # first-degree
      "4", "20053" | # post-first-degree (drop 11, post)
      
      "5", "20061" | # pre-degree
      "5", "20063"   # pre-degree
  )
  setDT(x_term)
  x_degr <- wrapr::build_frame(
    "mcid", "term_degree" |
      "1", "20013"  |
      "2", "20031"  |
      "3", "20041"  |
      "4", "20051"  |
      "4", "20053"
  )
  setDT(x_degr)
  ans01 <- filter_undergrad(x_term, x_degr)
  expected_ans01 <- x_term[-c(3, 8, 11)]
  expect_equal(ans01, expected_ans01)
  
  # `add_bacc_term` yields correct data frame
  ans02 <- filter_undergrad(x_term, x_degr, add_bacc_term = TRUE)
  
  # construct correct answer manually 
  first_degree <- x_degr[, .SD[1L], by = "mcid"]
  expected_ans02 <- first_degree[x_term, on = "mcid"]
  expected_ans02 <- unique(expected_ans02)[, .(mcid, term, bacc_term = term_degree)]
  expect_equal(ans02, expected_ans02)
  
  # manually filter
  ans03 <- ans02[bacc_term >= term | is.na(bacc_term)]
  ans03[, bacc_term := NULL]
  expect_equal(ans01, ans03)
  
  

  
  
  
  
  # function output not printed
  invisible(NULL)
}

test_filter_undergrad()






