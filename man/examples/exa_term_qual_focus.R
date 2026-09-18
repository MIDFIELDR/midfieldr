# Select min required columns
term <- toy_term[, .(mcid, term)]
course <- toy_course[, .(mcid, term_course)]
degree <- toy_degree[, .(mcid, term_degree)]

# Example of starting data frame
term

# Labeling terms by group: undergrad & grad
term <- term_qual_focus(term, midf_table = degree)
course <- term_qual_focus(course, midf_table = degree)
degree <- term_qual_focus(degree, midf_table = degree)

# Example result
term[order(-term_focus)]

# No change if added columns duplicate existing
x <- term_qual_focus(term, midf_table = degree)
check_equiv_frames(term, x)

# Filter to retain "undergraduate" rows only
term <- term[term_focus == "undergrad"]
course <- course[term_focus == "undergrad"]
degree <- degree[term_focus == "undergrad"]

# Example result
term

