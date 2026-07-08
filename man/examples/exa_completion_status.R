term <- toy_term
degree <- toy_degree

# Start with a selected population 
x <- toy_student[21:36, .(mcid)]
x

# Timely term column is required
x <- timely_term(x, midfield_table = term)
x

# Build completion status data frame
x <- completion_status(x, midfield_table = degree)
x

# Only ID and timely term are pulled from x, all other columns drop
x[, term_degree := "17761"]
x[, completion_status := "unknown"][]
completion_status(x, degree)

