
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

test_pre_or_post_bacc <- function() {
  
  # usage
  # pre_or_post_bacc(dframe, midf_table = degree)
  
  # ---------- setup
  
  # Needed for tinytest::build_install_test()
  suppressPackageStartupMessages(require("data.table"))
  
  # column names to be added (optional)
  new_cols <- c("bacc_term", "pre_or_post")
  
  # ---------- correct answers
  
  # check that class is preserved function
  expect_class_preserved(toy_term, toy_degree, pre_or_post_bacc)
  
  # dframe required variables: mcid, term (or term_course or term_degree)
  # degree required variables: mcid, term_degree
  
  x_term <- wrapr::build_frame(
    "mcid", "term" |
      "1", "20011" | # pre-degree
      "1", "20013" | # first-degree
      "1", "20021" | # post-first-degree (drop)
      
      "2", "20023" | # pre-degree
      "2", "20031" | # first-degree
      
      "3", "20033" | # pre-degree
      "3", "20041" | # first-degree
      "3", "20041" | # first-degree (drop duplic)
      
      "4", "20043" | # pre-degree
      "4", "20051" | # first-degree
      "4", "20053" | # post-first-degree (drop)
      
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
  ans01 <- pre_or_post_bacc(x_term, x_degr)
  
  # answer is correct
  ans02 <- copy(ans01)
  ans02 <- ans02[pre_or_post == "pre-bacc", .(mcid, term)]
  exp_ans <- x_term[-c(3, 8, 11)]
  expect_equal(ans02, exp_ans)
  
  # no effect if re-applied
  x <- copy(ans01)
  y <- pre_or_post_bacc(x, x_degr)
  expect_equal(x, y)
  
  # confirm NO changes by reference
  term <- copy(toy_term)
  degr <- copy(toy_degree)
  z <- pre_or_post_bacc(term, degr)
  expect_true(check_equiv_frames(term, toy_term))
  expect_true(check_equiv_frames(degr, toy_degree))
  expect_equal(x[["idx"]], y[["idx"]])

  # ---------- errors
  
  # check for incorrect input class / required variables
  expect_error(pre_or_post_bacc(1))
  expect_error(pre_or_post_bacc(toy_term, "sat"))
  expect_error(pre_or_post_bacc(toy_student, toy_degree))
  expect_error(pre_or_post_bacc(toy_degree, toy_student))
  
  # function output not printed
  invisible(NULL)
}

test_pre_or_post_bacc()






