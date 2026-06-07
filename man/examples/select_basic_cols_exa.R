# Basic usage
select_basic_cols(toy_student[1:5])
select_basic_cols(toy_course[1:5])
select_basic_cols(toy_term[1:5])
select_basic_cols(toy_degree[1:5])

# With patterns for additional columns
DT <- toy_student[141:146]
select_basic_cols(DT, patternv = c("transfer", "hours_tranfer"))

# Using regular expressions
these_IDs <- DT$mcid
DT <- toy_term[mcid %chin% these_IDs]
select_basic_cols(DT, patternv = c("^gpa"))
