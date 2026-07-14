term <- toy_term

# Start with a selected population. 
x <- toy_student[c(51:55, 346:350), .(mcid, sex)]
x

# Add timely term columns. Unrelated columns (sex) are unaffected.
x <- timely_term(x, midfield_table = term)
x

# Repeat. New columns silently replace existing columns of the same name.
y <- timely_term(x, midfield_table = term)
y
