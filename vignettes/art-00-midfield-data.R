## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(fig.path = here::here(
  "man/figures",
  "art-00-introduction-"
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

## ----echo = FALSE-------------------------------------------------------------
knitr::kable(wrapr::build_frame(
  "Data table", "Each row is", "N rows", "N columns" |
    "[`student`](https://midfieldr.github.io/midfielddata/reference/student.html)", "a degree-seeking student", "97,640", "13" |
    "[`course`](https://midfieldr.github.io/midfielddata/reference/course.html)", "a student in a course", "3.5M", "12" |
    "[`term`](https://midfieldr.github.io/midfielddata/reference/term.html)", "a student in a term", "728,000", "13" |
    "[`degree`](https://midfieldr.github.io/midfielddata/reference/degree.html)", "a student who graduates", "48,000", "5"
), align = "llrr")

## -----------------------------------------------------------------------------
# packages used in this vignette
library("midfieldr")
library("midfielddata")
library("data.table")

## -----------------------------------------------------------------------------
# the names of objects in the environment
ls()

## ----echo = FALSE, cache = FALSE----------------------------------------------
# cache = TRUE speeds up repeats
if (!exists("student")) data(student)

## -----------------------------------------------------------------------------
# the names of objects in the environment
ls()

## ----echo = FALSE, cache = FALSE----------------------------------------------
# cache = TRUE speeds up repeats
if (!exists("course")) data(course)
if (!exists("term")) data(term)
if (!exists("degree")) data(degree)

## -----------------------------------------------------------------------------
# the names of objects in the environment
ls()

## ----echo = FALSE-------------------------------------------------------------
kable2html <- function(x, font_size = NULL, caption = NULL) {
  font_size <- ifelse(is.null(font_size), 11, font_size)
  kable_in <- knitr::kable(x, format = "html", caption = caption)
  kableExtra::kable_styling(kable_input = kable_in, font_size = font_size)
}

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
# number of unique IDs
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
df <- wrapr::build_frame(
  "Function", "Action" |
    "add_completion_timely()", "Add a column to evaluate program completion" |
    "add_data_sufficiency()", "Add a column to evaluate data sufficiency" |
    "add_institution()", "Add a column of institution names" |
    "add_race_sex()", "Add columns for student race/ethnicity and sex" |
    "add_timely_term()", "Add a column of terms delimiting timely completion"
)
kable2html(df, font_size = 12)

## ----echo = FALSE-------------------------------------------------------------
df <- wrapr::build_frame(
  "Function", "Action" |
    "filter_match()", "Subset rows by matching values in shared key columns" |
    "filter_search()", "Subset rows that include matches to search strings"
)
kable2html(df, font_size = 12)

## ----echo = FALSE-------------------------------------------------------------
df <- wrapr::build_frame(
  "Function", "Action" |
    "condition_fye()", "Condition FYE data for multiple imputation" |
    "condition_multiway()", "Condition multiway data for graphing"
)
kable2html(df, font_size = 12)

## ----eval = FALSE-------------------------------------------------------------
#  # packages used
#  library("midfieldr")
#  library("midfielddata")
#  library("data.table")
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

