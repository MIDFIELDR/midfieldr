term <- toy_term

# Start with a small population 
x <- toy_student[c(9:15, 342:344), .(mcid)]
x

# Timely term column is required
x <- timely_term(x, term)
x

# Add data sufficiency column, columns not used are dropped
x <- data_sufficiency(x, term)
x

# Existing data sufficiency column (if any) is replaced
x[, data_sufficiency := NA_character_][]
data_sufficiency(x, term)
