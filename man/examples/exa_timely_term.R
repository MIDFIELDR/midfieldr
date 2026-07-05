term <- toy_term

# Start with a small population 
x <- toy_student[c(51:55, 346:350), .(mcid, sex)]
x

# Add timely term, unrelated variables (sex) are dropped
x <- timely_term(x, midfield_table = term)
x

# Existing column with same name as added column is replaced
x[, adj_span := 0L][]
timely_term(x, midfield_table = term)
