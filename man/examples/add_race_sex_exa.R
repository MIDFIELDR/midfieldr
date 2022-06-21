# Start with an excerpt from the degree data set 
dframe <- toy_degree[1:5, c("mcid", "cip6")]

# Add columns for race/ethnicity and sex
add_race_sex(dframe, midfield_student = toy_student)

# Repeat with an example from the term data set 
dframe <- toy_term[21:26, c("mcid", "institution", "level")]
add_race_sex(dframe, midfield_student = toy_student)

# Existing race and sex columns, if any, are overwritten
dframe[, c("race", "sex") := NA_character_]
add_race_sex(dframe, midfield_student = toy_student)
