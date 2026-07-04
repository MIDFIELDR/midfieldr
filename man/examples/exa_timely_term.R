term <- toy_term

# Start with a small population 
x <- toy_student[c(51:55, 346:350), .(mcid)]
x

# Add timely term
x <- timely_term(x, midfield_table = term)
x

# Existing timely term column (if any) is replaced
x[, timely_term := NA_character_][]
timely_term(x, midfield_table = term)

# Columns not involved in the function are not modified
# For example, here we add "sex" to dframe
x <- toy_student[c(51:55, 346:350), .(mcid, sex)]
x
x <- timely_term(dframe = x, midfield_table = term)
x

# A variable in dframe with the same name as a variable  
# being joined from midfield_table is not affected. 
# For example, here we add a "term" column to x
x <- x[, .(mcid, sex, term = term_i)]
x
x <- timely_term(dframe = x, midfield_table = term)
x
