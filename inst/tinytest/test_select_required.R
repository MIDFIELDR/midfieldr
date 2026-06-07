test_select_required <- function() {

    # usage
    # select_required(midfield_x, select_add = NULL)

    # Needed for tinytest::build_install_test()
    require("data.table")

    # Default character vector for selecting columns
    default_cols<- c("mcid", "institution", "race", "sex", "^term", "cip6", "level", "abbrev", "number")
    
    # Create one string separated by OR
    search_pattern <- paste(default_cols, collapse = "|")
    
    # Expect same number of columns as TRUE in grepl()
    x <- select_required(toy_student) 
    y <- grepl(search_pattern, names(x))
    expect_equal(ncol(x), sum(y))
    
    # Expect same number of columns as TRUE in grepl()
    x <- select_required(toy_term) 
    y <- grepl(search_pattern, names(x))
    expect_equal(ncol(x), sum(y))
    
    # Expect same number of columns as TRUE in grepl()
    x <- select_required(toy_course) 
    y <- grepl(search_pattern, names(x))
    expect_equal(ncol(x), sum(y))
    
    # Expect same number of columns as TRUE in grepl()
    x <- select_required(toy_degree) 
    y <- grepl(search_pattern, names(x))
    expect_equal(ncol(x), sum(y))
    
    # add a dummy grade column to course for testing
    toy_course$grade <- rep(c("A", "B", "C", "D", "F"), length.out = nrow(toy_course))
    
    # Add columns test
    cols_to_add <- c("grade")
    x <- select_required(toy_course, select_add = cols_to_add)
    y <- grepl(search_pattern, names(x))
    expect_equal(ncol(x), sum(y) + length(cols_to_add))
    
    # Silently ignore search terms not found
    cols_to_add <- c("grade")
    x <- select_required(toy_student, select_add = cols_to_add)
    y <- grepl(search_pattern, names(x))
    expect_equal(ncol(x), sum(y))

    # Error if no columns found
    cols_to_add <- c("grade")
    x <- toy_course[, .SD, .SDcols = cols_to_add]
    expect_error(select_required(x))

    # is incoming data frame class preserved
    class_df  <- c("data.frame")
    class_dt  <- c("data.table", "data.frame")
    class_tbl <- c("tbl_df", "tbl", "data.frame")
    
    x_dt <- copy(toy_degree)
    x_df <- as.data.frame(copy(x_dt))
    x_tbl <- x_df
    class(x_tbl) <- class_tbl
    
    expect_equal(class_df, class(select_required(x_df)))
    expect_equal(class_dt, class(select_required(x_dt)))
    expect_equal(class_tbl, class(select_required(x_tbl)))
    
    
    
    # function output not printed
    invisible(NULL)
}

test_select_required()






