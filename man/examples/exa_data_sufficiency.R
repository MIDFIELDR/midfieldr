term <- toy_term

# Start with a selected population.
x <- toy_student[c(9:15, 342:344), .(mcid, sex)]
x

# Add the required columns from timely_term().
x <- timely_term(x, midfield_table = term)
x <- x[, .(mcid, sex, term_i, timely_term)]
x

# Add data sufficiency columns. Unrelated columns (sex) are unaffected.
x <- data_sufficiency(x, midfield_table = term)
x

# Repeat. New columns silently replace existing columns of the same name.
y <- data_sufficiency(x, midfield_table = term)
y
