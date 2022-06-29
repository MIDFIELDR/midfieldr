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
  fig.path = "../man/figures/art-050-demographics-",
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
  datatable.print.nrows = 15,
  datatable.print.topn = 5,
  datatable.print.class = TRUE
)

## -----------------------------------------------------------------------------
# Load data sets from midfielddata
data(student, term, degree)

## -----------------------------------------------------------------------------
# A convenient set of IDs
DT <- copy(study_mcid)
DT[]

## -----------------------------------------------------------------------------
# Subset of student data frame to join
cols_to_join <- student[, .(mcid, race, sex)]
merge(DT, cols_to_join, by = c("mcid"), all.x = TRUE)

## -----------------------------------------------------------------------------
merge(DT, student[, .(mcid, race, sex)], by = c("mcid"), all.x = TRUE)

## -----------------------------------------------------------------------------
# Fresh start
DT <- copy(study_mcid)

# Left-outer join student to DT
DT <- student[DT, .(mcid, race, sex), on = c("mcid")]
DT[]

## -----------------------------------------------------------------------------
# Fresh start
DT <- copy(study_mcid)
x <- merge(DT, student[, .(mcid, race, sex)], by = c("mcid"), all.x = TRUE)
setkey(x, NULL)
y <- student[DT, .(mcid, race, sex), on = c("mcid")]
all.equal(x, y)

## -----------------------------------------------------------------------------
# What we want
x <- student[DT, .(mcid, race, sex), on = c("mcid")]

# Not what we want
y <- DT[student, .(mcid, race, sex), on = c("mcid")]

# Equal?  
all.equal(x, y)

# Compare N rows
nrow(x)

nrow(y)

## -----------------------------------------------------------------------------
# Variables in the practice data set
names(student)

## -----------------------------------------------------------------------------
# Fresh start
DT <- copy(study_mcid)

# Add variables from student to DT
student[DT, .(mcid, transfer, hours_transfer), on = c("mcid")]

## -----------------------------------------------------------------------------
# Add variables from student to DT
student[DT, .(mcid, sat_math, sat_verbal), on = c("mcid")]

## -----------------------------------------------------------------------------
# Variables in the practice data set
names(term)

## -----------------------------------------------------------------------------
# Fresh start
DT <- copy(study_mcid)

# Add variables from term to DT
x <- term[DT, .(mcid, institution), on = c("mcid")]
x[]

# Remove duplicate rows
unique(x)

## -----------------------------------------------------------------------------
# Add variables from term to DT
x <- term[DT, .(mcid, cip6), on = c("mcid")]
unique(x)

## -----------------------------------------------------------------------------
# Variables in the practice data set
names(degree)

## -----------------------------------------------------------------------------
# Add variables from degree to DT
x <- degree[DT, .(mcid, term_degree, cip6), on = c("mcid")]
x[]

## -----------------------------------------------------------------------------
#  # Packages
#  library("midfieldr")
#  library("midfielddata")
#  suppressPackageStartupMessages(library("data.table"))
#  
#  # Printing options for data.table
#  options(
#    datatable.print.nrows = 15,
#    datatable.print.topn = 5,
#    datatable.print.class = TRUE
#  )
#  
#  # Load data sets from midfielddata
#  data(student, term, degree)
#  
#  # Using merge
#  DT <- copy(study_mcid)
#  cols_to_join <- student[, .(mcid, race, sex)]
#  merge(DT, cols_to_join, by = c("mcid"), all.x = TRUE)
#  merge(DT, student[, .(mcid, race, sex)], by = c("mcid"), all.x = TRUE)
#  
#  # Using Y[X, j]
#  DT <- copy(study_mcid)
#  student[DT, .(mcid, race, sex), on = c("mcid")]
#  
#  # Compare
#  x <- merge(DT, student[, .(mcid, race, sex)], by = c("mcid"), all.x = TRUE)
#  setkey(x, NULL)
#  y <- student[DT, .(mcid, race, sex), on = c("mcid")]
#  all.equal(x, y)
#  
#  # Order matters
#  x <- student[DT, .(mcid, race, sex), on = c("mcid")]
#  y <- DT[student, .(mcid, race, sex), on = c("mcid")]
#  all.equal(x, y)
#  nrow(x)
#  nrow(y)
#  
#  # Columns from student
#  names(student)
#  DT <- copy(study_mcid)
#  student[DT, .(mcid, transfer, hours_transfer), on = c("mcid")]
#  student[DT, .(mcid, sat_math, sat_verbal), on = c("mcid")]
#  
#  # Columns from term
#  names(term)
#  DT <- copy(study_mcid)
#  unique(term[DT, .(mcid, institution), on = c("mcid")])
#  unique(term[DT, .(mcid, cip6), on = c("mcid")])
#  
#  # Columns from degree
#  names(degree)
#  degree[DT, .(mcid, term_degree, cip6), on = c("mcid")]

