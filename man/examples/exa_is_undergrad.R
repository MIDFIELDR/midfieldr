# Select min required columns
term <- toy_term[, .(mcid, term)]
course <- toy_course[, .(mcid, term_course)]
degree <- toy_degree[, .(mcid, term_degree)]

# Example of starting data frame
term

# Labeling terms by group: undergrad & grad
term <- is_undergrad(term, midf_table = degree)
course <- is_undergrad(course, midf_table = degree)
degree <- is_undergrad(degree, midf_table = degree)

# Example result
term[order(-term_focus)]

# No change if added columns are redundant
x <- is_undergrad(term, midf_table = degree)
check_equiv_frames(term, x)

# Filter to retain "undergraduate" rows only
term <- term[term_focus == "undergrad"]
course <- course[term_focus == "undergrad"]
degree <- degree[term_focus == "undergrad"]

# Example result
term
