# Example data frames
sel_ids <- toy_student[14:18, (mcid)]

s <- toy_student[mcid %chin% sel_ids, .(mcid, sex)]
t <- toy_term[mcid %chin% sel_ids, .(mcid, term)]
d <- toy_degree[mcid %chin% sel_ids, .(mcid, term_degree)]

# No error
catch_error(qualification_level(t, d))

# Error, no term variable 
catch_error(qualification_level(s, d))

# Error, missing dframe argument
catch_error(qualification_level())

# Error, missing degree argumeny
catch_error(qualification_level(t))
