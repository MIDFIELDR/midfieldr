library(data.table)

# Subset student and term data using selected IDs
IDs <- c("MCID3112319668", "MCID3112214437", "MCID3112328548", 
         "MCID3111447797", "MCID3111566004", "MCID3111697452", 
         "MCID3112268500", "MCID3112320295")
student <- select_basic_cols(toy_student[mcid %chin% IDs])
term <- select_basic_cols(toy_term[mcid %chin% IDs])

# Obtain results
proxy <- prep_fye_mice(student, term)
proxy

# ---------- Examine details
# Note: the CIP code and name for FYE is 140102 Pre-Engineering

# Join program names to term data for display
term_seq <- cip[term, .(mcid, term, cip6, cip6name), on = "cip6", nomatch = NULL]

# Function to display results for individual students
f <- function(IDs, i) {
    cat(paste("Student", i, "record\n"))
    print(term_seq[mcid == IDs[i]])
    cat("\nprep_fye_mice() results\n")
    print(proxy[mcid == IDs[i]])
}

# Example 1: Non-Engineering -> FYE -> Engineering
# 400501 (Chemistry) -> FYE -> 140701 (Chemical Engng)
# FYE proxy is 140701
f(IDs, 1)

# Example 2: FYE -> Engineering -> Non-Engineering
# FYE -> 140901 (Computer Engng) -> 450601 (Economics)
# FYE proxy is 140901
f(IDs, 2)

# Example 3: FYE -> Engineering
# FYE -> 141001 (Electrical Engng)
# FYE proxy is 141001
f(IDs, 3)

# Example 4: FYE -> Engineering -> Engineering
# FYE -> 141901 (Mechanical Engng) -> 143501 (Industrial Engng)
# FYE proxy is 141901 
f(IDs, 4)

# Example 5: Non-Engineering -> FYE -> Leaves the database
# 240102 (General Studies) -> FYE
# FYE proxy is NA 
f(IDs, 5)

# Example 6: FYE -> Leaves the database
# FYE proxy is NA 
f(IDs, 6)

# Example 7: Non-Engineering -> FYE -> Non-Engineering
# 240102 (General Studies) -> FYE -> 110101 (Computer Science)
# FYE proxy is NA 
f(IDs, 7)

# Example 8: FYE -> Non-Engineering
# FYE -> 230101 (English Literature)
# FYE proxy is NA 
f(IDs, 8)
