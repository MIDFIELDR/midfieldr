# For illustration only, choose a minimum set of columns
term <- toy_term[, .(mcid, term)]
course <- toy_course[, .(mcid, term_course)]
degree <- toy_degree[, .(mcid, term_degree)]

# Example result
term

# Filter to retain undergrad terms only
x <- filter_undergrad(term, midf_table = degree)
x

# `add_bacc_term` argument adds the first degree term and rows are not removed
y <- filter_undergrad(term, midf_table = degree, add_bacc_term = TRUE)
y[order(bacc_term)]

# Filtering for undergraduate terms can be done manually
y <- y[bacc_term >= term | is.na(bacc_term)]
y[, bacc_term := NULL]
y

# Verify result
check_equiv_frames(x, y)


# Function is applied to all tables containing a term-value
term <- filter_undergrad(term, midf_table = degree)
course <- filter_undergrad(course, midf_table = degree)
degree <- filter_undergrad(degree, midf_table = degree)
