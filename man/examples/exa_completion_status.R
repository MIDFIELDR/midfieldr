# Assign toy data sets
student <- toy_student
term <- toy_term
degree <- toy_degree

# Start with a selected population
x <- student[c(9:11, 21:30, 344:345), .(mcid)]
x

# Add the required columns from timely_term()
x <- timely_term(x, midf_table = term)
x <- x[, .(mcid, timely_term)]
x

# Add completion status columns
x <- completion_status(x, midf_table = degree)
x

# If you repeat, the new columns are overwritten
completion_status(x, midf_table = degree)

# Typical application retains "timely" rows only
x[completion_status == "timely"]
