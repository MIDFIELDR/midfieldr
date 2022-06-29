## ----setup--------------------------------------------------------------------
# code chunks
knitr::opts_chunk$set(
  echo = TRUE,
  message = FALSE,
  warning = FALSE,
  collapse = FALSE,
  comment = "#>",
  error = FALSE
)

# figures
knitr::opts_chunk$set(
  fig.path = "../man/figures/art-040-completion-",
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

## -----------------------------------------------------------------------------
# Packages
library("midfieldr")
library("midfielddata")
suppressPackageStartupMessages(library("data.table"))

# Printing options for data.table
options(
  datatable.print.nrows = 55,
  datatable.print.topn = 5,
  datatable.print.class = TRUE
)

## -----------------------------------------------------------------------------
# Load data sets from midfielddata
data(student, term, degree)

## -----------------------------------------------------------------------------
# Filter for data sufficiency
DT <- copy(term)
DT <- add_timely_term(DT, term)
DT <- add_data_sufficiency(DT, term)
DT <- DT[data_sufficiency == "include"]

# Filter for degree seeking
DT <- DT[, .(mcid)]
DT <- unique(DT)
DT <- DT[student, .(mcid), on = c("mcid"), nomatch = NULL]
DT[]

## -----------------------------------------------------------------------------
# Add completion status
DT <- add_timely_term(DT, term)
DT <- add_completion_status(DT, degree)

# Drop unnecessary columns
DT[, c("term_i", "level_i", "adj_span") := NULL]
DT[]

## -----------------------------------------------------------------------------
# Student F
DT[mcid == "MID25783162"]

## -----------------------------------------------------------------------------
# Student G
DT[mcid == "MID26696871"]

## -----------------------------------------------------------------------------
# Student H
DT[mcid == "MID26697615"]

## -----------------------------------------------------------------------------
# Required arguments in order and explicitly named
x <- add_completion_status(dframe = DT, midfield_degree = degree)

# Required arguments in order, but not named
y <- add_completion_status(DT, degree)

# Using the implicit default for the midfield_term argument
z <- add_completion_status(DT)

# Equality test between the data tables
all.equal(x, y)
all.equal(x, z)

## -----------------------------------------------------------------------------
# Using degree data named something else
toy_DT <- toy_student[, .(mcid)]
toy_DT <- add_timely_term(toy_DT, toy_term)
toy_DT <- add_completion_status(toy_DT, toy_degree)
toy_DT[, c("term_i", "level_i", "adj_span") := NULL]
toy_DT[]

## -----------------------------------------------------------------------------
# Drop two columns
toy_DT <- toy_DT[, c("term_degree", "completion_status") := NULL]
toy_DT[]

## -----------------------------------------------------------------------------
# Reapply the function
toy_DT <- add_completion_status(toy_DT, toy_degree)
toy_DT[]

## -----------------------------------------------------------------------------
DT[, .N, by = c("completion_status")]

## -----------------------------------------------------------------------------
x <- DT[student, .(mcid, sex, completion_status), on = c("mcid"), nomatch = NULL]
x <- x[, .N, by = c("sex", "completion_status")]
setkeyv(x, c("completion_status", "sex"))
x[]

## -----------------------------------------------------------------------------
x <- DT[completion_status == "timely"]
x[]

## -----------------------------------------------------------------------------
DT <- DT[completion_status == "timely"]
DT <- DT[degree, .(mcid, cip6), on = c("mcid"), nomatch = NULL]
DT[]

## -----------------------------------------------------------------------------
study_program_cips[]

## -----------------------------------------------------------------------------
DT <- DT[study_program_cips, .(mcid, program), on = c("cip6"), nomatch = NULL]
DT[]

## -----------------------------------------------------------------------------
DT[, .N, by = c("program")]

## -----------------------------------------------------------------------------
#  # Packages
#  library("midfieldr")
#  library("midfielddata")
#  suppressPackageStartupMessages(library("data.table"))
#  
#  # Printing options for data.table
#  options(
#    datatable.print.nrows = 55,
#    datatable.print.topn = 5,
#    datatable.print.class = TRUE
#  )
#  
#  # Load data sets from midfielddata
#  data(student, term, degree)
#  
#  # Filter for data sufficiency
#  DT <- copy(term)
#  DT <- add_timely_term(DT, term)
#  DT <- add_data_sufficiency(DT, term)
#  DT <- DT[data_sufficiency == "include"]
#  
#  # Filter for degree seeking
#  DT <- DT[, .(mcid)]
#  DT <- unique(DT)
#  DT <- DT[student, .(mcid), on = c("mcid"), nomatch = NULL]
#  
#  # Add completion status
#  DT <- add_timely_term(DT, term)
#  DT <- add_completion_status(DT, degree)
#  DT[, c("term_i", "level_i", "adj_span") := NULL]
#  
#  # Closer look
#  DT[mcid == "MID25783162"]
#  DT[mcid == "MID26696871"]
#  DT[mcid == "MID26697615"]
#  
#  # Equivalent statements
#  x <- add_completion_status(dframe = DT, midfield_degree = degree)
#  y <- add_completion_status(DT, degree)
#  z <- add_completion_status(DT)
#  all.equal(x, y)
#  all.equal(x, z)
#  
#  # Using degree data named something else
#  toy_DT <- toy_student[, .(mcid)]
#  toy_DT <- add_timely_term(toy_DT, toy_term)
#  toy_DT <- add_completion_status(toy_DT, toy_degree)
#  toy_DT[, c("term_i", "level_i", "adj_span") := NULL]
#  
#  # Caution. Overwriting.
#  toy_DT <- toy_DT[, c("term_degree", "completion_status") := NULL]
#  toy_DT <- add_completion_status(toy_DT, toy_degree)
#  
#  # Completion summaries
#  DT[, .N, by = c("completion_status")]
#  x <- DT[student, .(mcid, sex, completion_status), on = c("mcid"), nomatch = NULL]
#  x <- x[, .N, by = c("sex", "completion_status")]
#  setkeyv(x, c("completion_status", "sex"))
#  
#  # Completion filter
#  x <- DT[completion_status == "timely"]
#  
#  # Completion programs
#  DT <- DT[completion_status == "timely"]
#  DT <- DT[degree, .(mcid, cip6), on = c("mcid"), nomatch = NULL]
#  DT <- DT[study_program_cips, .(mcid, program), on = c("cip6"), nomatch = NULL]
#  DT[, .N, by = c("program")]

