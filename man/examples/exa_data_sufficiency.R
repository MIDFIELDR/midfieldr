# Assign toy data sets
student <- toy_student
term <- toy_term

# Start with a selected population
x <- student[c(9:11, 21:30, 344:345), .(mcid)]
x

# Add the required columns from timely_term()
x <- timely_term(x, midf_table = term)
x <- x[, .(mcid, entry_term, timely_term)]
x

# Add data sufficiency columns
x <- data_sufficiency(x, midf_table = term)
x

# If you repeat, the new columns are overwritten
data_sufficiency(x, midf_table = term)

# Typical application retains "include" rows only
x[data_sufficiency == "include"]
