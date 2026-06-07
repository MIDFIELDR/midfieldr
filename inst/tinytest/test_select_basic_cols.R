test_select_basic_cols <- function() {
    
    # usage
    # select_basic_cols(dframe, ..., patternv = NULL)
    
    # Needed for tinytest::build_install_test()
    require("data.table")
    
    # Default character vector for selecting columns
    default_cols <- c(
        "mcid", "institution", "race", "sex", "cip6", "level", 
        "abbrev", "number", "term", "term_course", "term_degree"
    )
    
    # input checks
    expect_error(select_basic_cols(toy_student, "^sat"))
    expect_error(select_basic_cols(1))
    expect_error(select_basic_cols(toy_student, patternv = 1))
    
    # class preserved?
    x <- copy(toy_student)
    y <- select_basic_cols(x)
    expect_equal(class(x), class(y))
    
    setattr(x, "class", c("tbl_df", "tbl", "data.frame"))
    y <- select_basic_cols(x)
    expect_equal(class(x), class(y))
    
    # keys preserved?
    x <- copy(toy_student)
    setkeyv(x, "mcid")
    y <- select_basic_cols(x)
    expect_equal(key(x), key(y))
    
    setkeyv(x, NULL)
    y <- select_basic_cols(x)
    expect_equal(key(x), key(y))
    
    # basic columns correct
    default_cols <- c(
        "mcid", "institution", "race", "sex", "cip6", "level", 
        "abbrev", "number", "term", "term_course", "term_degree"
    )
   
    expect_equal_colnames <- function (x, these_cols, patternv = NULL) {
      expect_cols <- intersect(colnames(x), these_cols)
      result_cols <- colnames(select_basic_cols(x, patternv = patternv))
      expect_equal(expect_cols, result_cols)
    }
    
    expect_equal_colnames(toy_student, default_cols)
    expect_equal_colnames(toy_course , default_cols)
    expect_equal_colnames(toy_term   , default_cols)
    expect_equal_colnames(toy_degree , default_cols)
    
    # patternv correct answer
    x <- copy(toy_term)
    this_pattern <- "^gpa"
    add_names <- colnames(x)[grepl(this_pattern, colnames(x))]
    set_cols <- c(default_cols, add_names)
    expect_equal_colnames(toy_term, set_cols, patternv = this_pattern)
    
    # silently ignore search terms not found
    x <- copy(toy_degree)
    this_pattern <- "random_name"
    add_names <- colnames(x)[grepl(this_pattern, colnames(x))]
    set_cols <- c(default_cols, add_names)
    expect_equal_colnames(toy_term, set_cols, patternv = this_pattern)
    
    # dframe 0 rows 0 cols when no odefault colnames present
    x <- toy_degree[, .(degree)]
    expect_length(select_basic_cols(x), 0)

    # function output not printed
    invisible(NULL)
}

test_select_basic_cols()






