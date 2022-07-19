# # Using toy data
# DT <- toy_student[, .(mcid, race, sex)]
# preprocess_fye(dframe = DT, midfield_term = toy_term)
# 
# 
# # Overwrites institution if present in dframe
# DT <- toy_student[, .(mcid, institution, race, sex)]
# preprocess_fye(dframe = DT, midfield_term = toy_term)
# 
# 
# # Other columns, if any, are dropped
# colnames(toy_student)
# colnames(preprocess_fye(toy_student, toy_term))
# 
# 
# # Optional argument permits multiple CIP codes for FYE
# preprocess_fye(DT, toy_term, fye_codes = c("140101", "140102"))

