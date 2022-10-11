# Start with an excerpt from the student data set 
dframe <- toy_student[1:10, .(mcid)]

# Timely term column is required to add completion status column
dframe <- add_timely_term(dframe, toy_term)

# Add completion status column
add_completion_status(dframe, toy_degree)

# Existing completion_status column, if any, is overwritten
dframe[, completion_status := NA_character_]
add_completion_status(dframe, toy_degree)
