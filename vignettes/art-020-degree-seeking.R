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
    fig.path = "../man/figures/art-020-degree-seeking-", 
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
data(student, term)

## -----------------------------------------------------------------------------
# Filter for data sufficiency
DT <- copy(term)
DT <- add_timely_term(DT, term)
DT <- add_data_sufficiency(DT, term)
DT <- DT[data_sufficiency == "include"]

# Drop unnecessary variables
DT <- DT[, .(mcid, cip6)]
DT <- unique(DT)
DT[]

## -----------------------------------------------------------------------------
# Isolate the IDs of the second data frame
toy_select <- toy_student[, .(mcid)]

# Inner join to filter the observations of the first data frame
merge(DT, toy_select, by = c("mcid"), all = FALSE)

## -----------------------------------------------------------------------------
x <- merge(DT, toy_select, by = c("mcid"), all = FALSE)

## -----------------------------------------------------------------------------
# Isolating the IDs inside the merge function 
merge(DT, toy_student[, .(mcid)], by = c("mcid"), all = FALSE)

## -----------------------------------------------------------------------------
# A more computationally efficient approach
DT[toy_student, .(mcid, cip6), on = c("mcid"), nomatch = NULL]

## -----------------------------------------------------------------------------
# Swap the roles of the two data frames
toy_student[DT, .(mcid, cip6), on = c("mcid"), nomatch = NULL]

## -----------------------------------------------------------------------------
# Three equivalent inner joins
x <- merge(DT, toy_student[, .(mcid)], by = c("mcid"), all = FALSE)
setkey(x, NULL)
y <- DT[toy_student, .(mcid, cip6), on = c("mcid"), nomatch = NULL]
z <- toy_student[DT, .(mcid, cip6), on = c("mcid"), nomatch = NULL]

# Check equality 
all.equal(x, y)
all.equal(x, z)

## -----------------------------------------------------------------------------
# Selecting columns from both data frames using merge() 
x <- merge(DT[, .(mcid)], toy_student[, .(mcid, institution)], by = c("mcid"), all = FALSE)
setkey(x, NULL)
x[]

## -----------------------------------------------------------------------------
# Repeat using X[Y, j] syntax
y <- DT[toy_student, .(mcid, institution), on = c("mcid"), nomatch = NULL]

# Check equality 
all.equal(x, y)

## -----------------------------------------------------------------------------
# Unique IDs that are data sufficient
DT <- DT[, .(mcid)]
DT <- unique(DT)
DT[]

## -----------------------------------------------------------------------------
DT <- DT[student, .(mcid), on = c("mcid"), nomatch = NULL]
DT[]

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
#  data(student, term)
#  
#  # Filter for data sufficiency
#  DT <- copy(term)
#  DT <- add_timely_term(DT, term)
#  DT <- add_data_sufficiency(DT, term)
#  DT <- DT[data_sufficiency == "include"]
#  DT <- DT[, .(mcid, cip6)]
#  DT <- unique(DT)
#  
#  # Three equivalent inner joins
#  x <- merge(DT, toy_student[, .(mcid)], by = c("mcid"), all = FALSE)
#  setkey(x, NULL)
#  y <- DT[toy_student, .(mcid, cip6), on = c("mcid"), nomatch = NULL]
#  z <- toy_student[DT, .(mcid, cip6), on = c("mcid"), nomatch = NULL]
#  all.equal(x, y)
#  all.equal(x, z)
#  
#  # Selecting columns
#  x <- merge(DT[, .(mcid)], toy_student[, .(mcid, institution)], by = c("mcid"), all = FALSE)
#  setkey(x, NULL)
#  y <- DT[toy_student, .(mcid, institution), on = c("mcid"), nomatch = NULL]
#  all.equal(x, y)
#  
#  # Degree seeking
#  DT <- DT[, .(mcid)]
#  DT <- unique(DT)
#  DT <- DT[student, .(mcid), on = c("mcid"), nomatch = NULL]

