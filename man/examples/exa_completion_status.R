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

# No change if new columns match existing columns
y = completion_status(x, midf_table = degree)

# If new column should match existing but does not,
# new column with suffix .1, .2, etc., is added. 
# Indicates an error has occurred somewhere. 
y$bacc_term[1] <- "19893"
z = completion_status(y, midf_table = degree)
z

# Typical application retains "timely" rows only
x[completion == "timely"]
