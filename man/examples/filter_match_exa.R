# Start with a toy sample of student (built-in data set)
head(toy_student)
nrow(toy_student)


# Filter by matching IDs of graduates
student_example <- filter_match(toy_student,
  match_to = toy_degree,
  by_col = "mcid"
)
head(student_example)
# Note change in number of rows
nrow(student_example)


# Same filter and select 3 columns only
student_example <- filter_match(toy_student,
  match_to = toy_degree,
  by_col = "mcid",
  select = c("mcid", "race", "sex")
)
head(student_example)
nrow(student_example)


# Filter term data for engineering program codes (start with "14")
term_example <- toy_term[grepl("^14", cip6), ]
head(term_example)
nrow(term_example)


# Filter student by matching IDs of engineering students
student_example <- filter_match(toy_student,
  match_to = term_example,
  by_col = "mcid",
  select = c("mcid", "institution", "transfer", "sex")
)
head(student_example)
nrow(student_example)


# The 'by_col' column does not have to be included in the `select` columns
student_example <- filter_match(toy_student,
  match_to = term_example,
  by_col = "mcid",
  select = c("institution", "transfer", "sex")
)
head(student_example)
nrow(student_example)

