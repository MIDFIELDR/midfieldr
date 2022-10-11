# Start with an excerpt from the student data set 
dframe <- toy_student[1:10, .(mcid)]

# Add timely completion term column
add_timely_term(dframe, midfield_term = toy_term)

# Define timely completion as 200% of scheduled span (8 years)
add_timely_term(dframe, midfield_term = toy_term, span = 8)

# Existing timely_term column, if any, is overwritten
dframe[, timely_term := NA_character_]
add_timely_term(dframe, midfield_term = toy_term)


