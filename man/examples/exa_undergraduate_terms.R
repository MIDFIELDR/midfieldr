# select min required columns
term <- toy_term[, .(mcid, term)]
course <- toy_course[, .(mcid, term_course)]
degree <- toy_degree[, .(mcid, term_degree)]

# labeling terms by group: undergrad & grad
term <- undergraduate_terms(term, midf_table = degree)
course <- undergraduate_terms(course, midf_table = degree)
degree <- undergraduate_terms(degree, midf_table = degree)

# results
term[order(-term_group)]
term[, .N, by = "term_group"][order(-N)]

course[order(-term_group)]
course[, .N, by = "term_group"][order(-N)]

degree[order(-term_group)]
degree[, .N, by = "term_group"][order(-N)]
