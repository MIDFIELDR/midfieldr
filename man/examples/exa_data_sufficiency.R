term <- toy_term

# Start with a small population 
x <- toy_student[c(9:15, 342:344), .(mcid)]
x

# Timely term column is required
x <- timely_term(x, midfield_table = term)
x

# Build data sufficiency data frame
data_sufficiency(x, midfield_table = term)
