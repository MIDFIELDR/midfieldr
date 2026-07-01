# Start with an excerpt from the student data set 
dframe <- toy_student[1:10, .(mcid)]

# Add timely completion term column
timely_term(dframe, toy_term)

# Define timely completion as 200% of scheduled span (8 years)
timely_term(dframe, toy_term, span = 8)

# Existing timely_term column, if any, is overwritten
dframe[, timely_term := NA_character_][]
timely_term(dframe, toy_term)


