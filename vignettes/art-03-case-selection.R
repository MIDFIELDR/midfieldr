## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(fig.path = here::here(
  "man/figures",
  "art-03-case-selection-"
))
knitr::opts_chunk$set(
  echo = TRUE,
  message = FALSE,
  warning = FALSE,
  collapse = TRUE,
  comment = "#>",
  error = FALSE,
  fig.width = 6,
  fig.asp = 1 / 1.6,
  out.width = "70%",
  fig.align = "center"
)
knitr::knit_hooks$set(inline = function(x) {
  if (!is.numeric(x)) {
    x
  } else if (x >= 10000) {
    prettyNum(round(x, 2), big.mark = ",")
  } else {
    prettyNum(round(x, 2))
  }
})
kable2html <- function(x, font_size = NULL, caption = NULL) {
  font_size <- ifelse(is.null(font_size), 11, font_size)
  kable_in <- knitr::kable(x, format = "html", caption = caption)
  kableExtra::kable_styling(kable_input = kable_in, font_size = font_size)
}

## -----------------------------------------------------------------------------
# packages used
library("midfieldr")
library("midfielddata")
library("data.table")

# optional code to control data.table printing
options(
  datatable.print.nrows = 10,
  datatable.print.topn = 5,
  datatable.print.class = TRUE
)

## -----------------------------------------------------------------------------
# load data tables from midfielddata
data(student, term, degree)

## -----------------------------------------------------------------------------
# subset rows of the CIP data matching conditions
pass01 <- filter_search(cip, "engineering")
pass01

## -----------------------------------------------------------------------------
cols_we_want <- c("cip2", "cip2name")
unique(pass01[, ..cols_we_want])

## -----------------------------------------------------------------------------
pass02 <- filter_search(pass01, "^14")
pass02

## -----------------------------------------------------------------------------
# optional code to control data.table printing
options(datatable.print.topn = 13)

pass03 <- filter_search(pass02, c("civil", "electrical", "industrial", "mechanical"))
pass03

## -----------------------------------------------------------------------------
pass04 <- filter_search(pass03, drop_text = "electromechanical")
pass04

## -----------------------------------------------------------------------------
cols_we_want <- c("cip6", "cip4name")
case_cip <- pass04[, cols_we_want, with = FALSE]

# or, equivalently,
# case_cip <- pass04[, ..cols_we_want]

# examine the result
case_cip

## ----echo = FALSE-------------------------------------------------------------
# exercise solution
library("midfieldr")
library("midfielddata")
library("data.table")
data(student, term)

# Identify program codes
pass01 <- filter_search(cip, "history")
pass02 <- filter_search(pass01, "^54")
cols_we_want <- c("cip6", "cip6name")
exercise_cip <- pass02[, ..cols_we_want]

## -----------------------------------------------------------------------------
# Answer
exercise_cip

## -----------------------------------------------------------------------------
case_program <- copy(case_cip)
case_program[, program := cip4name]
case_program

## -----------------------------------------------------------------------------
dframe <- copy(case_program)
dframe[, program := fcase(
  program %ilike% "civil", "CVE",
  program %ilike% "electrical", "ECE",
  program %ilike% "mechanical", "MCE",
  program %ilike% "industrial", "ISE"
)]
dframe

## -----------------------------------------------------------------------------
# return matches in the cip4name column
dframe <- copy(case_program)
rows_to_edit <- dframe$program %ilike% "electrical"
dframe[rows_to_edit, program := "Electrical Engineering"]
dframe

## -----------------------------------------------------------------------------
# return matches that start with 1410
rows_to_edit <- case_program$cip6 %like% "^1410"
case_program[rows_to_edit, program := "Electrical Engineering"]
case_program

## -----------------------------------------------------------------------------
case_program[, cip4name := NULL]

case_program

## ----echo = FALSE-------------------------------------------------------------
# exercise solution
exercise_program <- copy(exercise_cip)
exercise_program[, program := cip6name]
exercise_program[
  cip6name %ilike% "General",
  program := "General History"
]
exercise_program[
  cip6name %ilike% "Other",
  program := "General History"
]
exercise_program[
  cip6name %ilike% "Philosophy",
  program := "Science and Techn"
]
exercise_program[
  cip6name %ilike% "Public",
  program := "Resource Admin"
]
exercise_program[
  cip6name %ilike% "United States",
  program := "US History"
]
exercise_program[, cip6name := NULL]

## -----------------------------------------------------------------------------
# Answer
exercise_program

## -----------------------------------------------------------------------------
# optional code to control data.table printing
options(datatable.print.topn = 5)

# subset degree rows
rows_we_want <- degree$cip6 %chin% case_program$cip6
dframe <- degree[rows_we_want]

# examine the result
dframe

## -----------------------------------------------------------------------------
# subset degree rows and columns
cols_we_want <- c("mcid", "institution", "cip6")
rows_we_want <- degree$cip6 %chin% case_program$cip6
dframe <- degree[rows_we_want, ..cols_we_want]

# examine the result
dframe

## -----------------------------------------------------------------------------
# subset degree table
case_degree <- filter_match(degree,
  match_to = case_program,
  by_col = "cip6",
  select = c("mcid", "institution", "cip6")
)

# compare to the DT we obtained above after ordering rows the same way
all.equal(case_degree[order(mcid)], dframe[order(mcid)])

## -----------------------------------------------------------------------------
# omit duplicate rows if any
case_degree <- unique(case_degree)

# examine the results
case_degree

## -----------------------------------------------------------------------------
# subset student table
case_student <- filter_match(student,
  match_to = case_degree,
  by_col = "mcid",
  select = c("mcid", "transfer", "hours_transfer")
)
# examine the result
case_student

## -----------------------------------------------------------------------------
# omit any duplicate rows before counting
case_student <- unique(case_student)
case_student[, .N, by = "transfer"]

## -----------------------------------------------------------------------------
# join program names
case_degree <- merge(case_degree, case_program, by = "cip6", all.x = TRUE)

# examine the result
case_degree

## -----------------------------------------------------------------------------
case_degree[, .N, by = "program"]

## ----echo = FALSE-------------------------------------------------------------
# exercise solution
exercise_student <- filter_match(term,
  match_to = exercise_program,
  by_col = "cip6",
  select = c("mcid", "cip6")
)
exercise_student <- unique(exercise_student)
exercise_student <- merge(exercise_student,
  exercise_program,
  by = "cip6",
  all.x = TRUE
)
exercise_summary <- exercise_student[, .N, by = "program"]

## -----------------------------------------------------------------------------
# answer
exercise_summary

## -----------------------------------------------------------------------------
study_programs

## -----------------------------------------------------------------------------
all.equal(case_program, study_programs)

## ----eval = FALSE-------------------------------------------------------------
#  # packages used
#  library("midfieldr")
#  library("midfielddata")
#  library("data.table")
#  
#  # load data tables from midfielddata
#  data(student, degree)
#  
#  # optional code to control data.table printing
#  options(
#    datatable.print.nrows = 10,
#    datatable.print.topn = 5,
#    datatable.print.class = TRUE
#  )
#  
#  # identify program codes
#  pass01 <- filter_search(cip, "engineering")
#  pass02 <- filter_search(pass01, "^14")
#  pass03 <- filter_search(
#    pass02,
#    c("civil", "electrical", "industrial", "mechanical")
#  )
#  pass04 <- filter_search(pass03, drop_text = "electromechanical")
#  cols_we_want <- c("cip6", "cip4name")
#  case_cip <- pass04[, cols_we_want, with = FALSE]
#  
#  # assign program names
#  case_program <- copy(case_cip)
#  case_program[, program := cip4name]
#  dframe <- copy(case_program)
#  dframe[, program := fcase(
#    program %ilike% "civil", "CVE",
#    program %ilike% "electrical", "ECE",
#    program %ilike% "mechanical", "MCE",
#    program %ilike% "industrial", "ISE"
#  )]
#  dframe <- copy(case_program)
#  rows_to_edit <- dframe$program %ilike% "electrical"
#  dframe[rows_to_edit, program := "Electrical Engineering"]
#  rows_to_edit <- case_program$cip6 %like% "^1410"
#  case_program[rows_to_edit, program := "Electrical Engineering"]
#  case_program[, cip4name := NULL]
#  
#  # apply results
#  case_degree <- filter_match(degree,
#    match_to = case_program,
#    by_col = "cip6",
#    select = c("mcid", "institution", "cip6")
#  )
#  case_student <- filter_match(student,
#    match_to = case_degree,
#    by_col = "mcid",
#    select = c("mcid", "transfer", "hours_transfer")
#  )
#  case_student[, .N, by = "transfer"]
#  case_degree <- merge(case_degree, case_program, by = "cip6", all.x = TRUE)
#  case_degree[, .N, by = "program"]
#  
#  # save results
#  fwrite(case_program, file = "results/case_program.csv")
#  case_program <- fread(
#    "results/case_program.csv",
#    colClasses = list(character = c("cip6"))
#  )

## ----echo = FALSE-------------------------------------------------------------
# work out the exercises
library("midfieldr")
library("midfielddata")
library("data.table")
data(student, term)

# Identify program codes
pass01 <- filter_search(cip, "history")
pass02 <- filter_search(pass01, "^54")
cols_we_want <- c("cip6", "cip6name")
exercise_cip <- pass02[, ..cols_we_want]
exercise_cip

# Assign program names
exercise_program <- copy(exercise_cip)
exercise_program[, program := cip6name]
exercise_program[
  cip6name %ilike% "General",
  program := "General History"
]
exercise_program[
  cip6name %ilike% "Other",
  program := "General History"
]
exercise_program[
  cip6name %ilike% "Philosophy",
  program := "Science and Technology"
]
exercise_program[
  cip6name %ilike% "Public",
  program := "Historical Resources"
]
exercise_program[
  cip6name %ilike% "United States",
  program := "US History"
]
exercise_program[, cip6name := NULL]
exercise_program

# Subset by CIP
exercise_student <- filter_match(term,
  match_to = exercise_program,
  by_col = "cip6",
  select = c("mcid", "cip6")
)
exercise_student <- unique(exercise_student)
exercise_student

# Merge program names
exercise_student <- merge(exercise_student,
  exercise_program,
  by = "cip6",
  all.x = TRUE
)
exercise_student

exercise_student[, .N, by = "program"]

# Save results
# no exercise

