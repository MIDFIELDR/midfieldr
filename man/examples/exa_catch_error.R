# setup
selected_ids <- toy_student[14:18, (mcid)]
s <- toy_student[mcid %chin% selected_ids, .(mcid, sex)]
t <- toy_term[mcid %chin% selected_ids, .(mcid, term)]
d <- toy_degree[mcid %chin% selected_ids, .(mcid, term_degree)]

# No error
catch_error(pre_or_post_bacc(dframe = t, midf_table = d))

# Error, no term variable in dframe
catch_error(pre_or_post_bacc(dframe = s, midf_table = d))

# Error, missing dframe argument
catch_error(pre_or_post_bacc(midf_table = d))

# Error, missing degree value in environment
catch_error(pre_or_post_bacc(dframe = t))

