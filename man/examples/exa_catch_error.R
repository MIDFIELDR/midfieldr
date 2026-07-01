# Example data frames
s <- toy_student[, .(mcid)]
t <- toy_term[, .(mcid, term)]
d <- toy_degree[, .(mcid, term_degree)]

# No error
catch_error(post_bacc_terms(t, d))

# Error, no term variable 
catch_error(post_bacc_terms(s, d))

# Error, missing dframe argument
catch_error(post_bacc_terms())

# Error, missing degree argument
catch_error(post_bacc_terms(t))

