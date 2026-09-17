# Assign toy data sets
student <- toy_student
term <- toy_term
degree <- toy_degree

# Start with a selected population
x <- student[c(9:11, 21:30, 344:345), .(mcid)]
x

# timely_term() to add required columns
x <- timely_term(x, midf_table = term)
x <- x[, .(mcid, timely_term)]
x

# Add completion status columns
x <- completion_status(x, midf_table = degree)
x

# No change if added columns duplicate existing
y <- completion_status(x, midf_table = degree)
check_equiv_frames(x, y)

# Filter to retain "timely" rows only
x[completion == "timely"]
