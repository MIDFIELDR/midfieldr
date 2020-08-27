## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(fig.path = "../man/figures/vignette-data-basics-")
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
library(midfieldr)
library(midfielddata)
library(data.table)

# print max 10 rows, otherwise 5 rows each head/tail
options(datatable.print.nrows = 10, datatable.print.topn = 5)

## ----echo = FALSE-------------------------------------------------------------
n_students <- nrow(midfieldstudents)
n_institutions <- length(unique(midfieldstudents$institution))
year_span <- floor(c(min(midfieldterms$term), max(midfieldterms$term)) / 10)

## ----echo = FALSE-------------------------------------------------------------
# midfieldstudents
n_id_students  <- nrow(unique(midfieldstudents[, .(id)]))
n_term_enter   <- nrow(unique(midfieldstudents[, .(term_enter)]))
obs_students   <- nrow(midfieldstudents)
var_students   <- ncol(midfieldstudents)
size_students  <- "19 MB"

# midfielddegrees
n_id_degrees <- nrow(unique(midfielddegrees[, .(id)]))
n_graduates  <- nrow(unique(midfielddegrees[!is.na(degree), .(id)]))
n_term_degree   <- nrow(unique(midfielddegrees[, .(term_degree)]))
obs_degrees  <- nrow(midfielddegrees)
var_degrees  <- ncol(midfielddegrees)
size_degrees <- "10.2 MB"

# midfieldterms
n_id_terms <- nrow(unique(midfieldterms[, .(id)]))
obs_terms  <- nrow(midfieldterms)
var_terms  <- ncol(midfieldterms)
n_institutions <- nrow(unique(midfieldterms[, .(institution)]))
n_programs_terms <- nrow(unique(midfieldterms[, .(institution, cip6)]))
n_terms    <- nrow(unique(midfieldterms[, .(term)]))
year_span  <- floor(c(min(midfieldterms$term), max(midfieldterms$term)) / 10)
size_terms <- "82 MB"

# midfieldcourses
n_id_courses <- nrow(unique(midfieldcourses[, .(id)]))
n_courses    <- nrow(unique(midfieldcourses[, .(institution, abbrev, number)]))
n_term_course <- nrow(unique(midfieldcourses[, .(term_course)]))
obs_courses  <- nrow(midfieldcourses)
var_courses  <- ncol(midfieldcourses)
size_courses <- "349 MB"

## -----------------------------------------------------------------------------
midfieldstudents

## -----------------------------------------------------------------------------
midfielddegrees

## -----------------------------------------------------------------------------
midfieldterms

## -----------------------------------------------------------------------------
midfieldcourses

## -----------------------------------------------------------------------------
# data.table object
midfielddegrees[1:10, ]

## -----------------------------------------------------------------------------
# confirm classification 
class(midfielddegrees)

## -----------------------------------------------------------------------------
# data.frame object
airquality[1:10, ]

# confirm classification 
class(airquality)

## -----------------------------------------------------------------------------
# start with a fresh copy
DT <- copy(midfielddegrees)

## -----------------------------------------------------------------------------
# TRUE/FALSE/NA vector
rows_we_want <- DT$cip6 == "540101"

# subset the data frame
DT <- DT[rows_we_want]

# examine the result
DT[]

## -----------------------------------------------------------------------------
# start with a fresh copy
DT <- copy(midfielddegrees)

# subset the data frame
rows_we_want <- is.na(DT$cip6) & DT$institution == "Institution D"
DT <- DT[rows_we_want]

# examine the result
DT[]

## -----------------------------------------------------------------------------
# start with a fresh copy
DT <- copy(midfielddegrees)

# subset the data frame
DT <- na.omit(DT)

# examine the result
DT[]

## -----------------------------------------------------------------------------
# subset the data frame
rows_we_want <- DT$cip6 == "540101"
DT <- DT[rows_we_want]

# order rows by values in ID column 
DT <- DT[order(id)]

# examine the result
DT[]

## -----------------------------------------------------------------------------
# order rows by values in two columns 
DT <- DT[order(institution, id)]

# examine the result
DT[]

## -----------------------------------------------------------------------------
# order rows by values, one ascending, one descending 
DT <- DT[order(institution, -term_degree)]

# examine the result
DT[]

## -----------------------------------------------------------------------------
# start with a fresh copy
DT <- copy(midfieldstudents)

# column-names vector
cols_we_want <- c("id", "race", "sex")

# subset the data frame
DT <- DT[, ..cols_we_want]

# examine the result
DT

## -----------------------------------------------------------------------------
# start with a fresh copy
DT <- copy(midfieldstudents)

# subset the data frame
DT <- DT[, .(id, race, sex)]

# examine the result
DT

## -----------------------------------------------------------------------------
# subset the data frame, rename a column 
DT <- DT[, .(id, race_ethnicity = race, sex)]

# examine the result
DT

## -----------------------------------------------------------------------------
# start with a fresh copy
DT <- copy(midfieldstudents)

# subset the data frame
rows_we_want <- DT$hours_transfer > 11 & DT$hours_transfer < 49
cols_we_want <- c("id", "cip6", "hours_transfer")
DT <- DT[rows_we_want, ..cols_we_want]

# examine the result
DT

## -----------------------------------------------------------------------------
# order rows and rename columns 
DT <- DT[order(-hours_transfer), 
         .(ID = id, CIP = cip6, HOURS = hours_transfer)]

# examine the result
DT

## -----------------------------------------------------------------------------
# create a subset to work with
DT <- copy(midfielddegrees)
rows_we_want <- DT$institution == "Institution D"
DT <- DT[rows_we_want]

# examine the result
DT[order(degree)]

## -----------------------------------------------------------------------------
# omit columns by not selecting them 
cols_we_want <- c("id", "degree",  "term_degree")
DT <- DT[, ..cols_we_want]

# examine the result
DT[order(degree)]

## -----------------------------------------------------------------------------
# omit a column in place
DT[, id := NULL]

# examine the result
DT[order(degree)]

## -----------------------------------------------------------------------------
# add column in place 
DT[, inst_size := "small"]

# examine the result
DT[order(degree)]

## -----------------------------------------------------------------------------
# add columns in place 
DT[, year  := floor(term_degree / 10)]
DT[, iterm := floor(term_degree - 10 * year)]

# examine the result
DT[order(degree, term_degree)]

## -----------------------------------------------------------------------------
DT[!is.na(degree), status := "grad"]
DT[order(status)]

## -----------------------------------------------------------------------------
DT[is.na(degree), status := "nongrad"]
DT[order(status)]

## -----------------------------------------------------------------------------
# create a subset to work with
rows_we_want <- midfieldterms$cip6 == "141901"
cols_we_want <- c("institution", "cip6", "term", "coop")
DT <- midfieldterms[rows_we_want, ..cols_we_want]

# examine the result
DT

## -----------------------------------------------------------------------------
# count by institution
DT[order(institution), .N, by = institution]

# count by coop
DT[, .N, by = coop]

## -----------------------------------------------------------------------------
# column name for the count
DT[, .(N_coop = .N), by = coop]

## -----------------------------------------------------------------------------
# edit the printout option
options(datatable.print.nrows = 16)

# assign the grouping variables 
grouping_variables <- c("institution", "coop")

# count by the groupings
DT[order(institution, coop), .(frequency = .N), by = grouping_variables]

# reset the printout option
options(datatable.print.nrows = 10, datatable.print.topn = 5)

## -----------------------------------------------------------------------------
# create a subset to work with
rows_we_want <- midfieldterms$cip6 == "141901"
cols_we_want <- c("id", "cip6", "term")
DT <- midfieldterms[rows_we_want, ..cols_we_want]

# examine the result
DT

## -----------------------------------------------------------------------------
# keep the latest term data by ID
DT <- DT[, .SD[term == max(term)], by = id]

# examine the result
DT

## -----------------------------------------------------------------------------
# the original is a data.frame
DF <- copy(airquality)
class(DF)

## -----------------------------------------------------------------------------
# create data.table
DT <- setDT(DF)
class(DT)

## -----------------------------------------------------------------------------
class(DF)

## -----------------------------------------------------------------------------
# both labels refer to the same memory address
address(DT)
address(DF)

## -----------------------------------------------------------------------------
# edit DT
DT[, year := 1973]
DT 

# and the change applied to DF 
DF

## -----------------------------------------------------------------------------
# the original is a data.frame
DF <- copy(airquality)
class(DF)

## -----------------------------------------------------------------------------
# make a copy
DT <- copy(DF)

# transform
setDT(DT)

# DT is a data.table
class(DT)

## -----------------------------------------------------------------------------
# the two objects have different addresses in memory
address(DT)
address(DF)

# DF remains a data.frame
class(DF)

## -----------------------------------------------------------------------------
# edit DT
DT[, year := 1973]

# examine the result
head(DT)

# no change to DF 
head(DF)

## -----------------------------------------------------------------------------
# start with a data.frame
class(airquality)

# copy and transform in place
DT <- copy(airquality)
setDT(DT)

# compare results
class(airquality)
class(DT)

## -----------------------------------------------------------------------------
# start with a data.table
class(cip)

# copy and transform in place
DF <- copy(cip)
setDF(DF)

# compare results
class(cip)
class(DF)

## -----------------------------------------------------------------------------
# create a subset to work with
DT <- copy(midfielddegrees)
rows_we_want <- DT$institution == "Institution D"
DT <- DT[rows_we_want]

# examine the result
DT[order(degree)]

## -----------------------------------------------------------------------------
# edit column names in place
setnames(DT, old = c("id", "cip6"), new = c("ID", "CIP"))

# examine the result
DT

## ----eval = FALSE-------------------------------------------------------------
#  # packages used
#  library(midfieldr)
#  library(midfielddata)
#  library(data.table)
#  
#  # view each data set
#  midfieldstudents
#  midfielddegrees
#  midfieldterms
#  midfieldcourses
#  
#  # identify objects
#  midfielddegrees[1:10, ]
#  class(midfielddegrees)
#  airquality[1:10, ]
#  class(airquality)
#  
#  # subset and arrange rows
#  DT <- copy(midfielddegrees)
#  rows_we_want <- DT$cip6 == "540101"
#  DT <- DT[rows_we_want]
#  
#  # filter rows using multiple conditions
#  DT <- copy(midfielddegrees)
#  rows_we_want <- is.na(DT$cip6) & DT$institution == "Institution D"
#  DT <- DT[rows_we_want]
#  
#  # discard rows with missing values
#  DT <- copy(midfielddegrees)
#  DT <- na.omit(DT)
#  
#  # arrange rows
#  rows_we_want <- DT$cip6 == "540101"
#  DT <- DT[rows_we_want]
#  DT <- DT[order(id)]
#  DT <- DT[order(institution, id)]
#  DT <- DT[order(institution, -term_degree)]
#  
#  # select columns using a character vector
#  DT <- copy(midfieldstudents)
#  cols_we_want <- c("id", "race", "sex")
#  DT <- DT[, ..cols_we_want]
#  
#  # select columns using a list
#  DT <- copy(midfieldstudents)
#  DT <- DT[, .(id, race, sex)]
#  
#  # select columns, rename one
#  DT <- DT[, .(id, race_ethnicity = race, sex)]
#  
#  # combine row and column operations
#  DT <- copy(midfieldstudents)
#  rows_we_want <- DT$hours_transfer > 11 & DT$hours_transfer < 49
#  cols_we_want <- c("id", "cip6", "hours_transfer")
#  DT <- DT[rows_we_want, ..cols_we_want]
#  DT <- DT[order(-hours_transfer),
#           .(ID = id, CIP = cip6, HOURS = hours_transfer)]
#  
#  # remove a column in place
#  DT <- copy(midfielddegrees)
#  rows_we_want <- DT$institution == "Institution D"
#  cols_we_want <- c("id", "degree",  "term_degree")
#  DT <- DT[rows_we_want, ..cols_we_want]
#  DT[, id := NULL]
#  
#  # add a column in place
#  DT[, inst_size := "small"]
#  DT[, year  := floor(term_degree / 10)]
#  DT[, iterm := floor(term_degree - 10 * year)]
#  
#  # add/modify a column in place for specific rows
#  DT[!is.na(degree), status := "grad"]
#  DT[is.na(degree), status := "nongrad"]
#  
#  # frequency by group
#  rows_we_want <- midfieldterms$cip6 == "141901"
#  cols_we_want <- c("institution", "cip6", "term", "coop")
#  DT <- midfieldterms[rows_we_want, ..cols_we_want]
#  DT[order(institution), .N, by = institution]
#  DT[, .(N_coop = .N), by = coop]
#  grouping_variables <- c("institution", "coop")
#  DT[order(institution, coop), .(frequency = .N), by = grouping_variables]
#  
#  # operate on a column by group
#  rows_we_want <- midfieldterms$cip6 == "141901"
#  cols_we_want <- c("id", "cip6", "term")
#  DT <- midfieldterms[rows_we_want, ..cols_we_want]
#  DT <- DT[, .SD[term == max(term)], by = id]
#  
#  # convert data.frame to data.table in place
#  class(airquality)
#  DT <- copy(airquality)
#  setDT(DT)
#  class(airquality)
#  class(DT)
#  
#  # convert data.table to data.frame in place
#  class(cip)
#  DF <- copy(cip)
#  setDF(DF)
#  class(cip)
#  class(DF)
#  
#  # rename columns in place
#  DT <- copy(midfielddegrees)
#  rows_we_want <- DT$institution == "Institution D"
#  DT <- DT[rows_we_want]
#  setnames(DT, old = c("id", "cip6"), new = c("ID", "CIP"))

