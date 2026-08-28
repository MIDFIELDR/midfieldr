# select min required columns
term <- toy_term[, .(mcid, term)]
course <- toy_course[, .(mcid, term_course)]
degree <- toy_degree[, .(mcid, term_degree)]

# labeling pre- and post-completion terms
term <- post_completion_terms(term, midf_table = degree)
course <- post_completion_terms(course, midf_table = degree)
degree <- post_completion_terms(degree, midf_table = degree)

# results
term[order(-before_or_after)]
term[, .N, by = "before_or_after"][order(-N)]

course[order(-before_or_after)]
course[, .N, by = "before_or_after"][order(-N)]

degree[order(-before_or_after)]
degree[, .N, by = "before_or_after"][order(-N)]
