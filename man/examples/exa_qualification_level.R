# select min required columns
term <- toy_term[, .(mcid, term)]
course <- toy_course[, .(mcid, term_course)]
degree <- toy_degree[, .(mcid, term_degree)]

# labeling terms by group: undergrad & grad
term <- qualification_level(term, midf_table = degree)
course <- qualification_level(course, midf_table = degree)
degree <- qualification_level(degree, midf_table = degree)

# results
term[order(-qual_level)]
term[, .N, by = "qual_level"][order(-N)]

course[order(-qual_level)]
course[, .N, by = "qual_level"][order(-N)]

degree[order(-qual_level)]
degree[, .N, by = "qual_level"][order(-N)]
