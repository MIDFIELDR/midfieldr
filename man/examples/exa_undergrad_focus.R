# select min required columns
term <- toy_term[, .(mcid, term)]
course <- toy_course[, .(mcid, term_course)]
degree <- toy_degree[, .(mcid, term_degree)]

# labeling terms by group: undergrad & grad
term <- undergrad_focus(term, midf_table = degree)
course <- undergrad_focus(course, midf_table = degree)
degree <- undergrad_focus(degree, midf_table = degree)

# results
term[order(-focus)]
term[, .N, by = "focus"][order(-N)]

course[order(-focus)]
course[, .N, by = "focus"][order(-N)]

degree[order(-focus)]
degree[, .N, by = "focus"][order(-N)]
