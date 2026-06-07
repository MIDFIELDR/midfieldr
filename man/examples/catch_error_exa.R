# Example data frames
s <- toy_student[, .(mcid)]
t <- toy_term[, .(mcid, term)]
d <- toy_degree[, .(mcid, term_degree)]

# No error
catch_error(add_post_bacc(t, d))

# Error, no term variable 
catch_error(add_post_bacc(s, d))

# Error, missing dframe argument
catch_error(add_post_bacc())

# Error, missing degree argument
catch_error(add_post_bacc(t))

