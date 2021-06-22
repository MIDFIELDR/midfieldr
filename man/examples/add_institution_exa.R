# Extract a column of IDs from student
id <- toy_student[, .(mcid)]


# Add institutions from term
DT1 <- add_institution(id, midfield_term = toy_term)
head(DT1)
nrow(DT1)


# Will overwrite institution column if present
DT2 <- add_institution(DT1, midfield_term = toy_term)
head(DT2)
nrow(DT2)

