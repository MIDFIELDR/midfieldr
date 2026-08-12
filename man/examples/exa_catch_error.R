# Example data frames
sel_ids <- toy_student[14:18, (mcid)]

s <- toy_student[mcid %chin% sel_ids, .(mcid, sex)]
t <- toy_term[mcid %chin% sel_ids, .(mcid, term)]
d <- toy_degree[mcid %chin% sel_ids, .(mcid, term_degree)]

# No error
catch_error(post_completion_terms(t, d))

# Error, no term variable 
catch_error(post_completion_terms(s, d))

# Error, missing dframe argument
catch_error(post_completion_terms())

# Error, missing degree argument
catch_error(post_completion_terms(t))
