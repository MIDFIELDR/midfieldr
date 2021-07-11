# Start with IDs and add institution and timely term
dframe <- toy_student[1:10, .(mcid)]
dframe <- add_institution(dframe, midfield_term = toy_term)
dframe <- add_timely_term(dframe, midfield_term = toy_term)


# Data sufficiency column
add_data_sufficiency(dframe, midfield_term = toy_term)


# Data sufficiency column with details
add_data_sufficiency(dframe, midfield_term = toy_term, detail = TRUE)


# If present, existing data_sufficiency column is overwritten
# Using dframe from above,
DT1 <- add_data_sufficiency(dframe, midfield_term = toy_term)
DT2 <- add_data_sufficiency(DT1, midfield_term = toy_term)
all.equal(DT1, DT2)

