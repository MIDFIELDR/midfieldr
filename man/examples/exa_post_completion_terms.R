# reduce number of columns
term <- select_basic_cols(toy_term)
degree <- select_basic_cols(toy_degree)

# identify term-clusters in a 'term' table
x <- post_completion_terms(term, degree)
x[, .N, by = "term_cluster"][order(-N)]
x

# identify term-clusters in a 'degree' table
x <- post_completion_terms(degree, degree)
x[, .N, by = "term_cluster"][order(-N)]
x

# post-first-degree terms are usually dropped
x[term_cluster != "post-first-degree"]
