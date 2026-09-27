# For illustration only, choose a minimum set of columns
term <- toy_term[, .(mcid, term)]
course <- toy_course[, .(mcid, term_course)]
degree <- toy_degree[, .(mcid, term_degree)]

# Example result
term

# Add term ID columns
x <- pre_or_post_bacc(term, midf_table = degree)
x[order(-pre_or_post)]

# No change if added columns duplicate existing
y <- pre_or_post_bacc(x, midf_table = degree)
check_equiv_frames(x, y)

# Filter to retain "undergrad" rows only
x[pre_or_post == "pre-bacc"]

# Function is applied to all tables containing a term-value
term <- pre_or_post_bacc(term, midf_table = degree)
course <- pre_or_post_bacc(course, midf_table = degree)
degree <- pre_or_post_bacc(degree, midf_table = degree)
