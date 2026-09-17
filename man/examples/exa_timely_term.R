# Assign toy data sets
student <- toy_student
term <- toy_term

# Start with a selected population
x <- student[c(9:11, 21:30, 344:345), .(mcid)]
x

# Add timely term columns
x <- timely_term(x, midf_table = term)
x

# No change if added columns duplicate existing
y <- timely_term(x, midf_table = term)
check_equiv_frames(x, y)
