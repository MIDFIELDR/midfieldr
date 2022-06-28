## ----setup--------------------------------------------------------------------
# code chunks
knitr::opts_chunk$set(
  echo = FALSE,
  message = FALSE,
  warning = FALSE,
  collapse = FALSE,
  comment = "#>",
  error = FALSE
)

# figures
knitr::opts_chunk$set(
    fig.path = "../man/figures/art-010-data-sufficiency-", 
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
# set echo for example
knitr::opts_chunk$set(echo = TRUE)

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
# Load data set from midfielddata
data(term)

# Create a working data frame
DT <- copy(term)
str(DT)

## -----------------------------------------------------------------------------
# Retain the minimum number of columns
DT <- DT[, .(mcid)]

## -----------------------------------------------------------------------------
DT <- unique(DT)
DT[]

# Count unique IDs
length(unique(DT$mcid))

## -----------------------------------------------------------------------------
# Display timely term and supporting variables 
DT <- add_timely_term(DT, term)
DT[]

## -----------------------------------------------------------------------------
DT[mcid == "MID25783135"]

## -----------------------------------------------------------------------------
DT[mcid == "MID26697689"]

## -----------------------------------------------------------------------------
# Required arguments in order and explicitly named 
x <- add_timely_term(dframe = DT, midfield_term = term)

# Required arguments in order, but not named   
y <- add_timely_term(DT, term)

# Using the implicit default for the midfield_term argument
z <- add_timely_term(DT)

# Equality test between the data tables
all.equal(x, y)
all.equal(x, z)

## -----------------------------------------------------------------------------
# Using term data named something else
toy_DT <- toy_student[, .(mcid)]
toy_DT <- add_timely_term(toy_DT, toy_term)
toy_DT[]

## -----------------------------------------------------------------------------
# Drop three columns
toy_DT <- toy_DT[, c("term_i", "level_i", "timely_term") := NULL]
toy_DT[]

## -----------------------------------------------------------------------------
toy_DT <- add_timely_term(toy_DT, toy_term)
toy_DT[]

## -----------------------------------------------------------------------------
# Drop unnecessary columns
DT <- DT[, .(mcid, timely_term)]

# Display data sufficiency and supporting variables
DT <- add_data_sufficiency(DT, term)
DT[]

## -----------------------------------------------------------------------------
# Student A
DT[mcid == "MID25783135"]

## -----------------------------------------------------------------------------
# Student B
DT[mcid == "MID25783156"]

## -----------------------------------------------------------------------------
# Student D
DT[mcid == "MID25783197"]

## -----------------------------------------------------------------------------
# Required arguments in order and explicitly named 
x <- add_data_sufficiency(dframe = DT, midfield_term = term)

# Required arguments in order, but not named   
y <- add_data_sufficiency(DT, term)

# Using the implicit default for the midfield_term argument
z <- add_data_sufficiency(DT)

# Equality test between the data tables
all.equal(x, y)
all.equal(x, z)

## -----------------------------------------------------------------------------
# Using term data named something else
toy_DT <- toy_DT[, .(mcid, timely_term)]
toy_DT <- add_data_sufficiency(toy_DT, toy_term)
toy_DT[]

## -----------------------------------------------------------------------------
# Drop three columns
toy_DT <- toy_DT[, c("lower_limit", "data_sufficiency") := NULL]
toy_DT[]

## -----------------------------------------------------------------------------
toy_DT <- add_data_sufficiency(toy_DT, toy_term)
toy_DT[]

## -----------------------------------------------------------------------------
# Apply the data sufficiency criterion
DT <- DT[data_sufficiency == "include"]
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
#  # Load data set from midfielddata
#  data(term)
#  DT <- copy(term)
#  DT <- DT[, .(mcid)]
#  DT <- unique(DT)
#  
#  # Timely completion term
#  DT <- add_timely_term(DT, term)
#  DT[mcid == "MID25783135"]
#  DT[mcid == "MID26697689"]
#  
#  # Equivalent statements
#  x <- add_timely_term(dframe = DT, midfield_term = term)
#  y <- add_timely_term(DT, term)
#  z <- add_timely_term(DT)
#  all.equal(x, y)
#  all.equal(x, z)
#  
#  # Using term data named something else
#  toy_DT <- toy_student[, .(mcid)]
#  toy_DT <- add_timely_term(toy_DT, toy_term)
#  
#  # Silent overwriting
#  toy_DT <- toy_DT[, c("term_i", "level_i", "timely_term") := NULL]
#  toy_DT <- add_timely_term(toy_DT, toy_term)
#  
#  # Data sufficiency
#  DT <- DT[, .(mcid, timely_term)]
#  DT <- add_data_sufficiency(DT, term)
#  DT[mcid == "MID25783135"]
#  DT[mcid == "MID25783156"]
#  DT[mcid == "MID25783197"]
#  
#  # Equivalent statements
#  x <- add_data_sufficiency(dframe = DT, midfield_term = term)
#  y <- add_data_sufficiency(DT, term)
#  z <- add_data_sufficiency(DT)
#  all.equal(x, y)
#  all.equal(x, z)
#  
#  # Using term data named something else
#  toy_DT <- toy_DT[, .(mcid, timely_term)]
#  toy_DT <- add_data_sufficiency(toy_DT, toy_term)
#  
#  # Silent overwriting
#  toy_DT <- toy_DT[, c("lower_limit", "data_sufficiency") := NULL]
#  toy_DT <- add_data_sufficiency(toy_DT, toy_term)
#  
#  # Apply the data sufficiency criterion
#  DT <- DT[data_sufficiency == "include"]

