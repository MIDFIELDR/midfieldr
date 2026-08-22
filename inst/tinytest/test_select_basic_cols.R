
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

test_select_basic_cols <- function() {
  
  # usage
  # select_basic_cols(dframe)
  
  # Needed for tinytest::build_install_test()
  suppressPackageStartupMessages(require("data.table"))
  
  # Default character vector for selecting columns
  all_reqd_cols <- c(
    "mcid", "institution", "race", "sex", "cip6", "level", 
    "abbrev", "number", "term", "term_course", "term_degree"
  )
  
  # ---------- class preserved
  
  expect_class_preserved(toy_student, select_basic_cols)
  
  # grouped tibble yields tibble
  x <- copy(toy_student)
  setattr(x, "class", c("grouped_df", "tbl_df", "tbl", "data.frame"))
  y <- select_basic_cols(x)
  expect_equal(class(y), c("tbl_df", "tbl", "data.frame"))
  
  # ---------- basic columns correct
  
  expect_equal(sort(colnames(select_basic_cols(toy_student))),
               sort(c("mcid", "race", "sex")))
  expect_equal(sort(colnames(select_basic_cols(toy_term))),
               sort(c("mcid", "term", "cip6", "institution", "level")))
  expect_equal(sort(colnames(select_basic_cols(toy_course))),
               sort(c("mcid", "term_course", "abbrev", "number")))
  expect_equal(sort(colnames(select_basic_cols(toy_degree))),
               sort(c("mcid", "term_degree", "cip6")))
  
  # if the input is not strictly one of the four MIDFIELD data
  # tables, all possible required columns are returned.
  DT <- toy_student[toy_degree, on = c("mcid")]
  DT_names <- colnames(select_basic_cols(DT))
  s_names <- intersect(colnames(toy_student), all_reqd_cols)
  d_names <- intersect(colnames(toy_degree), all_reqd_cols)
  expect_equal(sort(DT_names), sort(unique(c(s_names, d_names))))

  # required columns can only be returned if present, 
  sel_names <- c("mcid", "term", "cip6", "hours_term", "gpa_term")
  x_names <- colnames(select_basic_cols(toy_term[, ..sel_names]))
  y_names <- intersect(sel_names, all_reqd_cols)
  expect_equal(x_names, y_names)
  
  # confirm NO changes by reference
  student <- copy(toy_student)
  y <- select_basic_cols(student)
  expect_true(check_equiv_frames(student, toy_student))
  
  # dframe 0 rows 0 cols when no default colnames present
  x <- toy_degree[, .(degree)]
  expect_length(select_basic_cols(x), 0)
  
  # ---------- errors
  
  expect_error(select_basic_cols(1))
  expect_error(select_basic_cols(NULL))
  
  
  
  # function output not printed
  invisible(NULL)
}

test_select_basic_cols()






