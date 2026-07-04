term <- toy_term

# Start with a small population 
x <- toy_student[c(51:55, 346:350), .(mcid)]
x

# Add timely term
x <- timely_term(x, term)
x

# Existing timely term column (if any) is replaced
x[, timely_term := NA_character_][]
timely_term(x, term)
