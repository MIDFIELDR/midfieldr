# select min required columns
term <- toy_term[, .(mcid, term)]
course <- toy_course[, .(mcid, term_course)]
degree <- toy_degree[, .(mcid, term_degree)]

# labeling terms by group: undergrad & grad
term <- record_bracket(term, midf_table = degree)
course <- record_bracket(course, midf_table = degree)
degree <- record_bracket(degree, midf_table = degree)

# results
term[order(-bracket)]
term[, .N, by = "bracket"][order(-N)]

course[order(-bracket)]
course[, .N, by = "bracket"][order(-N)]

degree[order(-bracket)]
degree[, .N, by = "bracket"][order(-N)]
