
# functions used in the test

run_check <- function(x, y, fnc) {
  
  z <- fnc(x, y)
  expect_equal(class(x), class(z))
  
  rm(z)
}

expect_class_preserved <- function(df1, df2, fnc) {

  x <- copy(df1)
  y <- copy(df2)

  x <- as.data.frame(x)
  y <- as.data.frame(y)
  run_check(x, y, fnc)

  setattr(x, "class", c("tbl_df", "tbl", "data.frame"))
  setattr(y, "class", c("tbl_df", "tbl", "data.frame"))
  run_check(x, y, fnc)

  x <- as.data.table(x)
  y <- as.data.table(y)
  run_check(x, y, fnc)
  
  rm(x, y)
}

test_add_term_cluster <- function() {
  
  # usage
  # add_term_cluster(dframe, midfield_degree = degree)
  
  # ---------- setup
  
  # Needed for tinytest::build_install_test()
  suppressPackageStartupMessages(require("data.table"))
  
  # column names to be added
  new_cols <- c("first_degree_term", "term_cluster")
  
  # ---------- start tests
  
  # check that class is preserved function
  expect_class_preserved(toy_term, toy_degree, add_term_cluster)
  
  # check for incorrect input class / required variables
  expect_error(add_term_cluster(1))
  expect_error(add_term_cluster(toy_term, "sat"))
  expect_error(add_term_cluster(toy_student, toy_degree))
  expect_error(add_term_cluster(toy_degree, toy_student))
  
  # term added columns correct
  x <- copy(toy_term)
  y <- copy(toy_degree)
  z <- add_term_cluster(x, y)
  expect_equal(new_cols, setdiff(colnames(z), colnames(x)))
  
  # course added columns correct
  x <- copy(toy_course)
  z <- add_term_cluster(x, y)
  expect_equal(new_cols, setdiff(colnames(z), colnames(x)))
  
  # degree added columns correct
  x <- copy(toy_degree)
  z <- add_term_cluster(x, y)
  expect_equal(new_cols, setdiff(colnames(z), colnames(x)))
  
  # confirm NO changes by reference
  term <- copy(toy_term)
  degr <- copy(toy_degree)
  z <- add_term_cluster(term, degr)
  expect_true(check_equiv_frames(term, toy_term))
  expect_true(check_equiv_frames(degr, toy_degree))
  
  
  # check term-cluster labels are correct
  # dframe required variables: mcid, term (or term_course or term_degree)
  # degree required variables: mcid, term_degree
  
  x_term <- wrapr::build_frame(
    "mcid", "term" |
      "1", "20011" | # pre-degree
      "1", "20013" | # first-degree
      "1", "20021" | # post-first-degree
      
      "2", "20023" | # pre-degree
      "2", "20031" | # first-degree
      
      "3", "20033" | # pre-degree
      "3", "20041" | # first-degree
      "3", "20041" | # first-degree
      
      "4", "20043" | # pre-degree
      "4", "20051" | # first-degree
      "4", "20053" | # post-first-degree
      
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
  ans <- add_term_cluster(x_term, x_degr)[["term_cluster"]]
  expected_ans <- c("pre-degree", "first-degree", "post-first-degree", 
                    "pre-degree", "first-degree", 
                    "pre-degree", "first-degree", "first-degree", 
                    "pre-degree", "first-degree", "post-first-degree", 
                    "pre-degree", "pre-degree")
  expect_equal(ans, expected_ans)
  
  
  
  
  
  
  # function output not printed
  invisible(NULL)
}

test_add_term_cluster()






