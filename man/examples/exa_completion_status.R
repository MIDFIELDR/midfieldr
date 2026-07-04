term <- toy_term
degree <- toy_degree

# Start with a small population 
x <- toy_student[21:36, .(mcid)]
x

# Timely term column is required
x <- timely_term(x, term)
x

# Add completion status column, columns not used are dropped
x <- completion_status(x, degree)
x

# Existing completion status column (if any) is replaced
x[, completion_status := NA_character_][]
completion_status(x, degree)
