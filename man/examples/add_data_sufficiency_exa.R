# Start with an excerpt from the student data set 
dframe <- toy_student[1:10, .(mcid)]

# Timely term column is required to add data sufficiency column
dframe <- add_timely_term(dframe, midfield_term = toy_term)

# Add data sufficiency column
add_data_sufficiency(dframe, midfield_term = toy_term)

# Existing data_sufficiency column, if any, is overwritten
dframe[, data_sufficiency := NA_character_]
add_data_sufficiency(dframe, midfield_term = toy_term)
