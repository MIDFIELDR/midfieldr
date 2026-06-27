# Using toy data
prep_fye_mice(toy_student, toy_term)

# Other columns, if any, are dropped
colnames(toy_student)
colnames(prep_fye_mice(toy_student, toy_term))

# Optional argument permits multiple CIP codes for FYE
prep_fye_mice(midfield_student = toy_student, 
              midfield_term =toy_term, 
              fye_codes = c("140101", "140102"))

