# Start with an excerpt from the student data set 
dframe <- toy_student[1:10, .(mcid)]

# Timely term column is required to add data sufficiency column
dframe <- add_timely_term(dframe, toy_term)

# Add data sufficiency column
data_sufficiency(dframe, toy_term)

# Existing data_sufficiency column, if any, is replaced
dframe[, data_sufficiency := NA_character_][]
data_sufficiency(dframe, toy_term)
