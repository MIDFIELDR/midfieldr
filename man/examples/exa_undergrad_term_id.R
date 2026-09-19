# For illustration only, choose a minimum set of columns
term <- toy_term[, .(mcid, term)]
course <- toy_course[, .(mcid, term_course)]
degree <- toy_degree[, .(mcid, term_degree)]

# Example result
term

# Add term ID columns
x <- undergrad_term_id(term, midf_table = degree)
x[order(-term_id)]

# No change if added columns duplicate existing
y <- undergrad_term_id(x, midf_table = degree)
check_equiv_frames(x, y)

# Filter to retain "satisfied" rows only
x[term_id == "undergrad"]

# Function is applied to all tables containing a term-value
term <- undergrad_term_id(term, midf_table = degree)
course <- undergrad_term_id(course, midf_table = degree)
degree <- undergrad_term_id(degree, midf_table = degree)
