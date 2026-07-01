# Basic usage
select_records(toy_student[1:5])
select_records(toy_term[1:5])
select_records(toy_course[1:5])
select_records(toy_degree[1:5])

# With col_patterns for additional columns
DT <- toy_student[141:146]
select_records(DT, col_pattern = c("transfer", "hours_tranfer"))

# Using regular expressions
these_IDs <- DT$mcid
DT <- toy_term[mcid %chin% these_IDs]
select_records(DT, col_pattern = c("^gpa"))
