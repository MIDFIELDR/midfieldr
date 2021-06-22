# Using the toy data sets
DT <- toy_student[1:10, .(mcid)]
add_timely_term(DT, midfield_term = toy_term)


# Add details on which the timely term is based
add_timely_term(DT, midfield_term = toy_term, details = TRUE)


# Define timely completion as 200% of scheduled span (8 years)
add_timely_term(DT, midfield_term = toy_term, span = 8)


# Optional arguments (after ...) must be named
add_timely_term(DT, toy_term, details = TRUE, span = 6)

