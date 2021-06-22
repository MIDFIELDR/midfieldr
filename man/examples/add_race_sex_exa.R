# Add race and sex to a data frame of graduates
dframe <- toy_degree[1:5, c("mcid", "cip6")]
add_race_sex(dframe, midfield_student = toy_student)


# Add race and sex to a data frame from the term table
dframe <- toy_term[21:26, c("mcid", "institution", "level")]
add_race_sex(dframe, midfield_student = toy_student)


# If present, existing race and sex columns are overwritten
# Using dframe from above,
DT1 <- add_race_sex(dframe, midfield_student = toy_student)
DT2 <- add_race_sex(DT1, midfield_student = toy_student)
all.equal(DT1, DT2)
