test_add_term_cluster <- function() {
    
    # usage
    # add_term_cluster(dframe, midfield_degree = degree)
    
    # Needed for tinytest::build_install_test()
    require("data.table")
    
    # check for incorrect input class / required variables
    expect_error(add_term_cluster(1))
    expect_error(add_term_cluster(toy_term, "sat"))
    expect_error(add_term_cluster(toy_student, toy_degree))
    expect_error(add_term_cluster(toy_degree, toy_student))
    
    # class preserved?
    x <- copy(toy_term)
    y <- copy(toy_degree)
    z <- add_term_cluster(x, y)
    expect_equal(class(x), class(z))
    
    setattr(x, "class", c("tbl_df", "tbl", "data.frame"))
    setattr(y, "class", c("tbl_df", "tbl", "data.frame"))
    z <- add_term_cluster(x, y)
    expect_equal(class(x), class(z))
    
    # keys preserved?
    x <- copy(toy_term)
    y <- copy(toy_degree)
    setkeyv(x, "mcid")
    setkeyv(y, "mcid")
    z <- add_term_cluster(x, y)
    expect_equal(key(x), key(z))
    
    setkeyv(x, NULL)
    setkeyv(y, NULL)
    z <- add_term_cluster(x, y)
    expect_equal(key(x), key(z))
    

    
    
    
    
    
    
    
    
    
    
    
    
    
  
    # # basic columns correct
    # default_cols <- c(
    #     "mcid", "institution", "race", "sex", "cip6", "level", 
    #     "abbrev", "number", "term", "term_course", "term_degree"
    # )
    # 
    # expect_equal_colnames <- function (x, these_cols, patternv = NULL) {
    #   expect_cols <- intersect(colnames(x), these_cols)
    #   result_cols <- colnames(select_basic_cols(x, patternv = patternv))
    #   expect_equal(expect_cols, result_cols)
    # }
    # 
    # expect_equal_colnames(toy_student, default_cols)
    # expect_equal_colnames(toy_course , default_cols)
    # expect_equal_colnames(toy_term   , default_cols)
    # expect_equal_colnames(toy_degree , default_cols)
    # 
    # # patternv correct answer
    # x <- copy(toy_term)
    # this_pattern <- "^gpa"
    # add_names <- colnames(x)[grepl(this_pattern, colnames(x))]
    # set_cols <- c(default_cols, add_names)
    # expect_equal_colnames(toy_term, set_cols, patternv = this_pattern)
    # 
    # # silently ignore search terms not found
    # x <- copy(toy_degree)
    # this_pattern <- "random_name"
    # add_names <- colnames(x)[grepl(this_pattern, colnames(x))]
    # set_cols <- c(default_cols, add_names)
    # expect_equal_colnames(toy_term, set_cols, patternv = this_pattern)
    # 
    # # dframe 0 rows 0 cols when no default colnames present
    # x <- toy_degree[, .(degree)]
    # expect_length(select_basic_cols(x), 0)

    
    
    
    
    # function output not printed
    invisible(NULL)
}

test_add_term_cluster()






