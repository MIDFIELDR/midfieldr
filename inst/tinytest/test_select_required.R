test_select_required <- function() {

    # usage
    # select_required(midfield_x, select_add = NULL)

    # Needed for tinytest::build_install_test()
    library("data.table")

    
    # Default character vector for selecting columns
    default_cols<- c("mcid", "institution", "race", "sex", "^term", "cip6", "level")
    
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
    
    # Add columns
    cols_to_add <- c("abbrev", "number", "grade")
    x <- select_required(toy_course, select_add = cols_to_add) 
    y <- grepl(search_pattern, names(x))
    expect_equal(ncol(x), sum(y) + length(cols_to_add))
    
    # Silently ignore search terms not found
    x <- select_required(toy_student, select_add = cols_to_add) 
    y <- grepl(search_pattern, names(x))
    expect_equal(ncol(x), sum(y))

    # Error if no columns found
    cols_to_add <- c("abbrev", "number", "grade")
    x <- toy_course[, .SD, .SDcols = cols_to_add]
    expect_error(select_required(x))

    # function output not printed
    invisible(NULL)
}

test_select_required()






