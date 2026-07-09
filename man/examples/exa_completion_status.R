term <- toy_term
degree <- toy_degree

# Start with a selected population 
x <- toy_student[21:36, .(mcid)]
x

# Timely term column is required
x <- timely_term(x, midfield_table = term)
x

# Build completion status data frame
completion_status(x, midfield_table = degree)

