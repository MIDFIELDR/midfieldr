# Start with IDs
# dframe <- toy_student[1:10, .(mcid)]
# 
# 
# # Add the timely completion term, required for data sufficiency 
# dframe <- add_timely_term(dframe, midfield_term = toy_term)
# 
# 
# # Add the data sufficiency variable 
# add_data_sufficiency(dframe, midfield_term = toy_term)
# 
# 
# # Data sufficiency column with details
# add_data_sufficiency(dframe, midfield_term = toy_term, details = TRUE)
# 
# 
# # If present, existing data_sufficiency column is overwritten
# # Using dframe from above,
# DT1 <- add_data_sufficiency(dframe, midfield_term = toy_term)
# DT2 <- add_data_sufficiency(DT1, midfield_term = toy_term)
# all.equal(DT1, DT2)
