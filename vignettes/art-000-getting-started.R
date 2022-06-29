## ----setup, include = FALSE---------------------------------------------------
# code chunks
knitr::opts_chunk$set(
  echo = TRUE,
  message = FALSE,
  warning = FALSE,
  collapse = TRUE,
  comment = "#>",
  error = FALSE,
  cache = FALSE # speeds up repeats
)

# figures
knitr::opts_chunk$set(
  fig.path = "../man/figures/art-000-getting-started-",
  fig.width = 6,
  fig.asp = 1 / 1.6,
  out.width = "70%",
  fig.align = "center"
)

# inline numbers
knitr::knit_hooks$set(inline = function(x) {
  if (!is.numeric(x)) {
    x
  } else if (x >= 10000) {
    prettyNum(round(x, 2), big.mark = ",")
  } else {
    prettyNum(round(x, 2))
  }
})

## ----echo = FALSE-------------------------------------------------------------
wrapr::build_frame(
  "Practice data table", "Each row is", "No. of rows", "No. of columns" |
    "student", "a degree-seeking student", "97,640", "13" |
    "course", "a student in a course", "3.5M", "12" |
    "term", "a student in a term", "728,000", "13" |
    "degree", "a student who graduates", "48,000", "5"
) |>
  kableExtra::kbl(align = "llrr") |>
  kableExtra::kable_paper(lightable_options = "basic", full_width = TRUE) |>
  kableExtra::row_spec(0, background = "#c7eae5") |>
  kableExtra::column_spec(1, monospace = TRUE) |>
  kableExtra::column_spec(1:4, color = "black", background = "white")

## -----------------------------------------------------------------------------
# packages used
library("midfieldr")
library("midfielddata")
suppressPackageStartupMessages(library("data.table"))

# optional code to control data.table printing
options(
  datatable.print.nrows = 6,
  datatable.print.topn = 3,
  datatable.print.class = TRUE
)

## -----------------------------------------------------------------------------
# the names of objects in the environment
ls()

## ----echo = FALSE-------------------------------------------------------------
if (!exists("student")) data(student)

## -----------------------------------------------------------------------------
# the names of objects in the environment
ls()

## ----echo = FALSE-------------------------------------------------------------
if (!exists("course")) data(course)
if (!exists("term")) data(term)
if (!exists("degree")) data(degree)

## -----------------------------------------------------------------------------
# the names of objects in the environment
ls()

## ----echo = FALSE-------------------------------------------------------------
# cip
n_cip <- nrow(unique(cip))

# student
obs_students <- nrow(student)
var_students <- ncol(student)
size_students <- "19 MB"

# degree
n_id_degrees <- nrow(unique(degree[, .(mcid)]))
n_graduates <- nrow(unique(degree[!is.na(degree), .(mcid)]))
n_term <- nrow(unique(degree[, .(term)]))
obs_degrees <- nrow(degree)
var_degrees <- ncol(degree)
size_degrees <- "10 MB"

# term
n_id_terms <- nrow(unique(term[, .(mcid)]))
obs_terms <- nrow(term)
var_terms <- ncol(term)
n_institutions <- nrow(unique(term[, .(institution)]))
n_programs_terms <- nrow(unique(term[, .(institution, cip6)]))
n_terms <- nrow(unique(term[, .(term)]))
year_span <- c(substr(min(term[, term]), 1, 4), substr(max(term[, term]), 1, 4))
size_terms <- "82 MB"

# course
n_id_courses <- nrow(unique(course[, .(mcid)]))
n_courses <- nrow(unique(course[, .(institution, abbrev, number)]))
n_term_course <- nrow(unique(course[, .(term)]))
obs_courses <- nrow(course)
var_courses <- ncol(course)
size_courses <- "349 MB"

## -----------------------------------------------------------------------------
# view the structure of the data set
str(student)

## -----------------------------------------------------------------------------
length(unique(student$mcid))

## -----------------------------------------------------------------------------
summary(student$sat_math)

summary(student$age)

## -----------------------------------------------------------------------------
sort(unique(student$sex))

sort(unique(student$race))

## -----------------------------------------------------------------------------
# view the structure of the data set
str(course)

## -----------------------------------------------------------------------------
# number of unique IDs
length(unique(course$mcid))

## -----------------------------------------------------------------------------
summary(course$hours_course)

## -----------------------------------------------------------------------------
# type of courses
sort(unique(course$type))

## -----------------------------------------------------------------------------
str(term)

## -----------------------------------------------------------------------------
# number of unique IDs
length(unique(term$mcid))

## -----------------------------------------------------------------------------
summary(term$hours_term)

summary(term$gpa_term)

## -----------------------------------------------------------------------------
sort(unique(term$level))

sort(unique(term$standing))

## -----------------------------------------------------------------------------
str(degree)

## -----------------------------------------------------------------------------
# number of unique IDs
length(unique(degree$mcid))

## -----------------------------------------------------------------------------
sort(unique(degree$institution))

sort(unique(degree$degree))

## -----------------------------------------------------------------------------
degree[is.na(degree)]

## ----echo = FALSE-------------------------------------------------------------
wrapr::build_frame(
  "Function", "Action" |
    "add_*", "A family of functions that add columns to a data frame to classify observations." |
    "add_completion_status()", "Determine program completion status for every student" |
    "add_data_sufficiency()", "Determine data sufficiency for every student" |
    "add_timely_term()", "Calculate a timely completion term for every student" |
    "filter_*", "A family of functions that subset rows that match conditions." |
    "filter_search()", "Subset rows that include matches to search strings" |
    "condition_*", "A family of functions that transform data frames to condition data for specific tasks." |
    "condition_fye()", "Condition FYE data for multiple imputation" |
    "condition_multiway()", "Condition multiway data for graphing"
) |>
  kableExtra::kbl(align = "ll", col.names = NULL) |>
  kableExtra::kable_paper(lightable_options = "basic", full_width = TRUE) |>
  kableExtra::column_spec(1, monospace = TRUE) |>
  kableExtra::column_spec(1:2, color = "black", background = "white") |>
  kableExtra::row_spec(c(1, 5, 7), background = "#c7eae5")

## -----------------------------------------------------------------------------
#  # packages used
#  library("midfieldr")
#  library("midfielddata")
#  suppressPackageStartupMessages(library("data.table"))
#  
#  # loading data
#  data(student)
#  data(course)
#  data(term)
#  data(degree)
#  
#  # student
#  str(student)
#  length(unique(student$mcid))
#  summary(student$sat_math)
#  summary(student$age)
#  sort(unique(student$sex))
#  sort(unique(student$race))
#  
#  # course
#  str(course)
#  length(unique(course$mcid))
#  summary(course$hours_course)
#  sort(unique(course$type))
#  
#  # term
#  str(term)
#  length(unique(term$mcid))
#  summary(term$hours_term)
#  summary(term$gpa_term)
#  sort(unique(term$level))
#  sort(unique(term$standing))
#  
#  # degree
#  str(degree)
#  length(unique(degree$mcid))
#  sort(unique(degree$institution))
#  sort(unique(degree$degree))
#  degree[is.na(degree)]

