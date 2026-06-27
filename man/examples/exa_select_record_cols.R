# Basic usage
select_record_cols(toy_student[1:5])
select_record_cols(toy_term[1:5])
select_record_cols(toy_course[1:5])
select_record_cols(toy_degree[1:5])

# Return columns by record type
select_record_cols(toy_student[1:5], type = "s")
select_record_cols(toy_term[1:5], "t")
select_record_cols(toy_course[1:5], "c")
select_record_cols(toy_degree[1:5], "d")

# With col_patterns for additional columns
DT <- toy_student[141:146]
select_record_cols(DT, "t", col_pattern = c("transfer", "hours_tranfer"))

# Using regular expressions
these_IDs <- DT$mcid
DT <- toy_term[mcid %chin% these_IDs]
select_record_cols(DT, "t", col_pattern = c("^gpa"))
