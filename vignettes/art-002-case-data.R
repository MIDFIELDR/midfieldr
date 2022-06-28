## ----setup, include = FALSE---------------------------------------------------
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
    fig.path = "../man/figures/art-002-case-data-", 
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
# Load three data sets from midfielddata
data(student, term, degree)

## -----------------------------------------------------------------------------
# Create a working data frame
DT <- copy(term)
str(DT)

## -----------------------------------------------------------------------------
# Minimize the dimensions of the data
DT <- DT[, .(mcid, cip6)]
DT <- unique(DT)
DT[]

# Count unique IDs
length(unique(DT$mcid))

## -----------------------------------------------------------------------------
# Calculate a timely completion term for every student
DT <- add_timely_term(DT, term)
DT[]

## -----------------------------------------------------------------------------
# Determine data sufficiency for every student
DT <- add_data_sufficiency(DT, term)
DT[]

## -----------------------------------------------------------------------------
# Retain observations having sufficient data 
DT <- DT[data_sufficiency == "include"]
DT <- DT[, .(mcid, cip6)]
DT[]

## -----------------------------------------------------------------------------
# Inner join that filters DT
DT <- DT[student, .(mcid, cip6), on = c("mcid"), nomatch = NULL]
DT[]

## -----------------------------------------------------------------------------
# Gather program CIP codes
study_program <- filter_search(cip, keep_text = c("^1408", "^1410", "^1419", "^1427", "^1435", "^1436", "^1437"))
study_program <- study_program[, .(cip6, cip4name)]
study_program[]

## -----------------------------------------------------------------------------
# Assign four program names by CIP code
study_program[, program := fcase(
    cip6 %like% "^1408", "CE", 
    cip6 %like% "^1410", "EE", 
    cip6 %like% "^1419", "ME", 
    cip6 %chin% c("142701", "143501", "143601", "143701"), "ISE"
)]

# Confirm that abbreviations match the longer program names
print(study_program[, .(cip4name, program)])

## -----------------------------------------------------------------------------
# Left-outer join to DT
DT <- study_program[DT, .(mcid, cip6, program), on = c("cip6")]
DT[]

## -----------------------------------------------------------------------------
# Retain observations in our four programs 
DT <- DT[!is.na(program)]
DT[]

## -----------------------------------------------------------------------------
# Drop duplicate rows
DT[, cip6 := NULL]
DT <- unique(DT)
DT[]

## -----------------------------------------------------------------------------
# Conclude development of the ever-enrolled observations
ever <- copy(DT)
ever[, group := "ever"]
ever[]

## -----------------------------------------------------------------------------
# Unique IDs of students ever enrolled in the study programs
DT <- DT[, .(mcid)]
DT <- unique(DT)
DT[]

## -----------------------------------------------------------------------------
# Inner join that filters DT 
DT <- DT[degree, .(mcid, cip6), on = c("mcid"), nomatch = NULL]
DT[]

## -----------------------------------------------------------------------------
# Calculate a timely completion term for every student
DT <- add_timely_term(DT, term)
DT[]

## -----------------------------------------------------------------------------
# Determine program completion status for every student
DT <- add_completion_status(DT, degree)
DT[]

## -----------------------------------------------------------------------------
# Retain timely completers
DT <- DT[completion_status == "positive"]
DT <- DT[, .(mcid, cip6)]
DT[]

## -----------------------------------------------------------------------------
# Left-outer join to DT 
DT <- study_program[DT, .(mcid, program), on = c("cip6")]
DT <- DT[!is.na(program)]

# Unique observations
DT <- unique(DT)
DT[]

## -----------------------------------------------------------------------------
# Conclude development of the graduate observations
grad <- copy(DT)
grad[, group := "grad"]
grad[]

## -----------------------------------------------------------------------------
# Combine two data frames
DT <- rbindlist(list(ever, grad), use.names = TRUE)
DT[]

## -----------------------------------------------------------------------------
# Selecting columns from student
student_cols <- student[, .(mcid, race, sex)]

# Add them to DT with a left outer join
DT <- student_cols[DT, on = c("mcid")]
DT[]

## ----collapse = TRUE----------------------------------------------------------
DT[mcid == "MID26694225"]

## ----collapse = TRUE----------------------------------------------------------
DT[mcid == "MID25786154"]

## ----collapse = TRUE----------------------------------------------------------
DT[mcid == "MID25868925"]

## ----collapse = TRUE----------------------------------------------------------
DT[mcid == "MID26526757"]

## -----------------------------------------------------------------------------
#  # Packages
#  library("midfieldr")
#  library("midfielddata")
#  suppressPackageStartupMessages(library("data.table"))
#  
#  # Import data
#  data(student, term, degree)
#  
#  # Gather ever enrolled
#  DT <- copy(term)
#  DT <- DT[, .(mcid, cip6)]
#  DT <- unique(DT)
#  
#  # Filter for data sufficiency
#  DT <- add_timely_term(DT, term)
#  DT <- add_data_sufficiency(DT, term)
#  DT <- DT[data_sufficiency == "include"]
#  DT <- DT[, .(mcid, cip6)]
#  
#  # Filter for degree-seeking
#  DT <- DT[student, .(mcid, cip6), on = c("mcid"), nomatch = NULL]
#  
#  # Filter by program
#  study_program <- filter_search(cip, keep_text = c("^1408", "^1410", "^1419", "^1427", "^1435", "^1436", "^1437"))
#  study_program <- study_program[, .(cip6, cip6name)]
#  study_program[, program := fcase(
#      cip6 %like% "^1408", "CE",
#      cip6 %like% "^1410", "EE",
#      cip6 %like% "^1419", "ME",
#      cip6 %chin% c("142701", "143501", "143601", "143701"), "ISE"
#  )]
#  DT <- study_program[DT, .(mcid, cip6, program), on = c("cip6")]
#  DT <- DT[!is.na(program)]
#  DT[, cip6 := NULL]
#  DT <- unique(DT)
#  ever <- copy(DT)
#  ever[, group := "ever"]
#  
#  # Gather graduate subset
#  DT <- DT[, .(mcid)]
#  DT <- unique(DT)
#  DT <- DT[degree, .(mcid, cip6), on = c("mcid"), nomatch = NULL]
#  
#  # Filter by completion status
#  DT <- add_timely_term(DT, midfield_term = term)
#  DT <- add_completion_status(DT, degree)
#  DT <- DT[completion_status == "positive"]
#  DT <- DT[, .(mcid, cip6)]
#  
#  # Filter by program
#  DT <- study_program[DT, .(mcid, program), on = c("cip6")]
#  DT <- DT[!is.na(program)]
#  DT <- unique(DT)
#  grad <- copy(DT)
#  grad[, group := "grad"]
#  
#  # Combine two data frames and match the column names
#  DT <- rbindlist(list(ever, grad), use.names = TRUE)
#  
#  # Add demographics
#  student_cols <- student[, .(mcid, race, sex)]
#  DT <- student_cols[DT, on = c("mcid")]

