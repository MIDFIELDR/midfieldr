# Basic usage
select_basic_cols(toy_student[1:5])
select_basic_cols(toy_term[1:5])
select_basic_cols(toy_course[1:5])
select_basic_cols(toy_degree[1:5])

# If the input is not strictly one of the four MIDFIELD data
# tables, all possible required columns are returned.
x <- toy_student[toy_degree, on = c("mcid")][1:5]
select_basic_cols(x)

# Required columns can only be returned if present, 
# e.g., consider the result for a full table:
select_basic_cols(toy_term)

# Compared to the result for a subset of the same table:
y <- toy_term[, .(mcid, term, cip6, hours_term, gpa_term)]
select_basic_cols(y)
