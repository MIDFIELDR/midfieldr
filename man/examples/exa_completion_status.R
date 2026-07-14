term <- toy_term
degree <- toy_degree

# Start with a selected population. 
x <- toy_student[21:36, .(mcid, sex)]
x

# Add the required columns from timely_term().
x <- timely_term(x, midfield_table = term)
x <- x[, .(mcid, sex, timely_term)]
x

# Add completion status columns. Unrelated columns (sex) are unaffected.
x <- completion_status(x, midfield_table = degree)
x

# Repeat. New columns silently replace existing columns of the same name.
y <- completion_status(x, midfield_table = degree)
y
