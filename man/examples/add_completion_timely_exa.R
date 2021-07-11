# Start with IDs and add institution and timely term
dframe <- toy_student[1:10, .(mcid)]
dframe <- add_institution(dframe, midfield_term = toy_term)
dframe <- add_timely_term(dframe, midfield_term = toy_term)


# Timely completion column without detail
add_completion_timely(dframe, midfield_degree = toy_degree)


# Timely completion column with detail
add_completion_timely(dframe, midfield_degree = toy_degree, detail = TRUE)


# If present, existing completion_timely column is overwritten
DT1 <- add_completion_timely(dframe, midfield_degree = toy_degree)
DT2 <- add_completion_timely(DT1, midfield_degree = toy_degree)
all.equal(DT1, DT2)

