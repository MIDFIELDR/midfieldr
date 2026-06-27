
# functions used in the test

run_check <- function(x, fnc) {
  
  z <- fnc(x)
  expect_equal(class(x), class(z))
  
  rm(z)
}

expect_class_preserved <- function(df1, fnc) {
  
  x <- copy(df1)
  
  x <- as.data.frame(x)
  run_check(x, fnc)
  
  setattr(x, "class", c("tbl_df", "tbl", "data.frame"))
  run_check(x, fnc)
  
  x <- as.data.table(x)
  run_check(x, fnc)
  
  rm(x)
}

test_select_record_cols <- function() {
    
    # usage
    # select_record_cols(dframe, type, ..., col_patterncol_pattern = NULL)
    
    # Needed for tinytest::build_install_test()
  suppressPackageStartupMessages(require("data.table"))
    
    # Default character vector for selecting columns
    default_cols <- c(
        "mcid", "institution", "race", "sex", "cip6", "level", 
        "abbrev", "number", "term", "term_course", "term_degree"
    )
    
    # ---------- input checks
    

    expect_error(select_record_cols(1))
    expect_error(select_record_cols(toy_student, col_pattern = 1))

    # ---------- class preserved
    
    expect_class_preserved(toy_student, select_record_cols)
    
    # # data.table preserved
    # x <- copy(toy_student)
    # y <- select_record_cols(x)
    # expect_equal(class(x), class(y))
    # 
    # # tibble preserved
    # x <- copy(toy_student)
    # setattr(x, "class", c("tbl_df", "tbl", "data.frame"))
    # y <- select_record_cols(x)
    # expect_equal(class(x), class(y))
    # 
    # # base R data.frame preserved
    # x <- copy(toy_student)
    # setattr(x, "class", c("data.frame"))
    # y <- select_record_cols(x)
    # expect_equal(class(x), class(y))
    # 
    # # grouped tibble yields data.frame
    # x <- copy(toy_student)
    # setattr(x, "class", c("grouped_df", "tbl_df", "tbl", "data.frame"))
    # y <- select_record_cols(x)
    # expect_true(class(y) == "data.frame")
    
    
    
    
    # keys preserved?
    # x <- copy(toy_student)
    # setkeyv(x, "mcid")
    # y <- select_record_cols(x)
    # expect_equal(key(x), key(y))
    
    # setkeyv(x, NULL)
    # y <- select_record_cols(x)
    # expect_equal(key(x), key(y))
    
    # ---------- basic columns correct
    
    default_cols <- c(
        "mcid", "institution", "race", "sex", "cip6", "level", 
        "abbrev", "number", "term", "term_course", "term_degree"
    )
   
    expect_equal_colnames <- function (x, these_cols, col_pattern = NULL) {
      expect_cols <- intersect(colnames(x), these_cols)
      result_cols <- colnames(select_record_cols(x, col_pattern = col_pattern))
      expect_equal(expect_cols, result_cols)
    }
    
    expect_equal_colnames(toy_student, default_cols)
    expect_equal_colnames(toy_course , default_cols)
    expect_equal_colnames(toy_term   , default_cols)
    expect_equal_colnames(toy_degree , default_cols)
    
    # col_pattern correct answer
    x <- copy(toy_term)
    this_col_pattern <- "^gpa"
    add_names <- colnames(x)[grepl(this_col_pattern, colnames(x))]
    set_cols <- c(default_cols, add_names)
    expect_equal_colnames(toy_term, set_cols, col_pattern = this_col_pattern)
    
    # silently ignore search terms not found
    x <- copy(toy_degree)
    this_col_pattern <- "random_name"
    add_names <- colnames(x)[grepl(this_col_pattern, colnames(x))]
    set_cols <- c(default_cols, add_names)
    expect_equal_colnames(toy_term, set_cols, col_pattern = this_col_pattern)
    
    # dframe 0 rows 0 cols when no default colnames present
    x <- toy_degree[, .(degree)]
    expect_length(select_record_cols(x), 0)

    # confirm NO changes by reference
    student <- copy(toy_student)
    y <- select_record_cols(student)
    expect_true(check_equiv_frames(student, toy_student))
    
    term <- copy(toy_term)
    y <- select_record_cols(term)
    expect_true(check_equiv_frames(term, toy_term))
    
    degree <- copy(toy_degree)
    y <- select_record_cols(degree)
    expect_true(check_equiv_frames(degree, toy_degree))
    
    
    
    
    
    
    # function output not printed
    invisible(NULL)
}

test_select_record_cols()






