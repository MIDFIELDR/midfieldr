# Assign toy data sets
student <- toy_student
term <- toy_term
degree <- toy_degree

# Start with a selected population
x <- student[c(9:11, 21:30, 344:345), .(mcid)]
x

# Add timely term columns
x <- timely_term(x, midf_table = term)
x

# If you repeat, the new columns are overwritten
timely_term(x, midf_table = term)

# Application: data_sufficiency() requires entry_term and timely_term
data_sufficiency(x[, .(mcid, entry_term, timely_term)], midf_table = term)

# Application: completion_status() requires timely_term
completion_status(x[, .(mcid, timely_term)], midf_table = degree)
