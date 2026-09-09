# select min required columns
term <- toy_term[, .(mcid, term)]
course <- toy_course[, .(mcid, term_course)]
degree <- toy_degree[, .(mcid, term_degree)]

# labeling terms by group: undergrad & grad
term <- is_undergrad(term, midf_table = degree)
course <- is_undergrad(course, midf_table = degree)
degree <- is_undergrad(degree, midf_table = degree)

# results
term[order(-term_focus)]
term[, .N, by = "term_focus"][order(-N)]

course[order(-term_focus)]
course[, .N, by = "term_focus"][order(-N)]

degree[order(-term_focus)]
degree[, .N, by = "term_focus"][order(-N)]
