## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(fig.path = here::here(
  "man/figures",
  "art-07-fye-programs-"
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

# only if performing your own imputation
library("mice")

# optional code to control data.table printing
options(
  datatable.print.nrows = 10,
  datatable.print.topn = 5,
  datatable.print.class = TRUE
)

## -----------------------------------------------------------------------------
# load data tables from midfielddata
data(student, term)

## -----------------------------------------------------------------------------
# prepared starting programs of FYE students
fye_start

## -----------------------------------------------------------------------------
# case study programs
study_programs

# students ever enrolled in the case study programs
study_students

## -----------------------------------------------------------------------------
# subset term table by ID of case study students
DT <- filter_match(term,
  match_to = study_students,
  by_col = "mcid",
  select = c("mcid", "term", "cip6")
)

## -----------------------------------------------------------------------------
# set keys for ordering rows
keys <- c("mcid", "term")
setkeyv(DT, keys)
DT

## -----------------------------------------------------------------------------
# first term of each student
DT <- DT[, .SD[1], by = "mcid"]

# keys no longer required
setkey(DT, NULL)

# examine the result
DT

## -----------------------------------------------------------------------------
# filter for case study programs only
DT <- filter_match(DT,
  match_to = study_programs,
  by_col = "cip6",
  select = c("mcid", "cip6")
)

# ensure rows are unique
DT <- unique(DT)

# examine the result
DT

## -----------------------------------------------------------------------------
# summarize by CIP code
DT_no_fye <- DT[, .N, by = "cip6"]

# join program names
DT_no_fye <- merge(DT_no_fye, study_programs, by = "cip6", all.x = TRUE)

# order columns and rows for display
cols_we_want <- c("program", "N")
DT_no_fye <- DT_no_fye[order(-N), ..cols_we_want]
DT_no_fye

## -----------------------------------------------------------------------------
# subset predicted FYE start programs
setnames(fye_start, old = "start", new = "cip6")
study_fye <- filter_match(fye_start,
  match_to = study_programs,
  by_col = "cip6",
  select = c("mcid", "cip6")
)

# examine the result
study_fye

## -----------------------------------------------------------------------------
# combine the two data frames
DT <- rbindlist(list(DT, study_fye))

# examine the result
DT

# check that the IDs are unique
length(unique(DT[, mcid]))

## -----------------------------------------------------------------------------
# group and summarize with FYE included
DT_with_fye <- DT[, .N, by = "cip6"]

# examine the result
DT_with_fye

## -----------------------------------------------------------------------------
# join program names
DT_with_fye <- merge(DT_with_fye, study_programs, by = "cip6", all.x = TRUE)

# order columns and rows for display
cols_we_want <- c("program", "N")
DT_with_fye <- DT_with_fye[order(-N), ..cols_we_want]

# examine the result
DT_with_fye

## -----------------------------------------------------------------------------
# earlier summary for comparison
DT_no_fye

## -----------------------------------------------------------------------------
# get engineering CIP codes
engr_cip <- filter_search(cip, keep_text = "^14")

# examine the result
engr_cip

## -----------------------------------------------------------------------------
# get IDs of all engineering students in all terms
engr <- filter_match(term,
  match_to = engr_cip,
  by_col = "cip6",
  select = "mcid"
)

# all terms, so there will be duplictae IDs
engr

# omit duplicate rows
engr <- unique(engr)

# examine the result
engr

## -----------------------------------------------------------------------------
# limit the population to degree-seeking students
engr <- filter_match(engr,
  match_to = student,
  by_col = "mcid"
)

# examine the result
engr

## -----------------------------------------------------------------------------
# add race and sex variables
engr <- add_race_sex(engr, midfield_table = student)

# examine the result
engr

## -----------------------------------------------------------------------------
# set up a data frame for imputation
fye <- condition_fye(engr, midfield_table = term)

# view the result
fye

## -----------------------------------------------------------------------------
# number of NA values in cip6 column
sum(is.na(fye[, cip6]))

## -----------------------------------------------------------------------------
# imputation
framework <- mice(fye, maxit = 0)

# examine the results
framework

## -----------------------------------------------------------------------------
method <- framework[["method"]]
method

## -----------------------------------------------------------------------------
# variable(s) being imputed
method[c("cip6")] <- "polyreg"

# variable(s) not being imputed
method[c("mcid", "institution", "race", "sex")] <- ""

# examine the result
method

## -----------------------------------------------------------------------------
predictors <- framework[["predictorMatrix"]]
predictors

## -----------------------------------------------------------------------------
predictors["cip6", , drop = FALSE]

## -----------------------------------------------------------------------------
# set individual columns of the predictor matrix
predictors[, c("mcid", "cip6")] <- 0

# we need a one only in the last row for these three predictors
predictors[, c("institution", "race", "sex")] <- c(0, 0, 0, 0, 1)

# examine the result
predictors

## ----echo = FALSE-------------------------------------------------------------
# load the saved fye_mids to avoid running mice() repeatedly
load(here::here("R", "sysdata.rda"))

## ----eval = FALSE-------------------------------------------------------------
#  # imputation
#  fye_mids <- mice(
#    data = fye,
#    method = method,
#    predictorMatrix = predictors,
#    seed = 20180624,
#    printFlag = TRUE
#  )
#  
#  # output in console with printFlag = TRUE
#  # >  iter imp variable
#  # >   1   1  cip6
#  # >   1   2  cip6
#  # >   1   3  cip6
#  # >   1   4  cip6
#  # >   1   5  cip6
#  # >   ---
#  # >   5   1  cip6
#  # >   5   2  cip6
#  # >   5   3  cip6
#  # >   5   4  cip6
#  # >   5   5  cip6

## -----------------------------------------------------------------------------
fye <- complete(fye_mids)
setDT(fye)

# examine the result
fye

## -----------------------------------------------------------------------------
cols_we_want <- c("mcid", "cip6")
fye <- fye[, ..cols_we_want]
str(fye)

## -----------------------------------------------------------------------------
fye[, cip6 := as.character(cip6)]
str(fye)

## -----------------------------------------------------------------------------
fye <- fye[order(mcid)]
setnames(fye, old = "cip6", new = "start")
fye

## -----------------------------------------------------------------------------
all.equal(fye, fye_start)

## -----------------------------------------------------------------------------
detach("package:mice", unload = TRUE)
set.seed(NULL)

## ----eval = FALSE-------------------------------------------------------------
#  # packages used
#  library("midfieldr")
#  library("midfielddata")
#  library("data.table")
#  library("mice")
#  
#  # prepared predictions
#  DT <- filter_match(term,
#    match_to = study_students,
#    by_col = "mcid",
#    select = c("mcid", "term", "cip6")
#  )
#  keys <- c("mcid", "term")
#  setkeyv(DT, keys)
#  DT <- DT[, .SD[1], by = "mcid"]
#  setkey(DT, NULL)
#  DT <- filter_match(DT,
#    match_to = study_programs,
#    by_col = "cip6",
#    select = c("mcid", "cip6")
#  )
#  DT <- unique(DT)
#  
#  # summarize for later
#  DT_no_fye <- DT[, .N, by = "cip6"]
#  DT_no_fye <- merge(DT_no_fye, study_programs, by = "cip6", all.x = TRUE)
#  cols_we_want <- c("program", "N")
#  DT_no_fye <- DT_no_fye[order(-N), ..cols_we_want]
#  
#  # subset predicted FYE start programs
#  setnames(fye_start, old = "start", new = "cip6")
#  study_fye <- filter_match(fye_start,
#    match_to = study_programs,
#    by_col = "cip6",
#    select = c("mcid", "cip6")
#  )
#  DT <- rbindlist(list(DT, study_fye))
#  
#  # group and summarize with FYE included
#  DT_with_fye <- DT[, .N, by = "cip6"]
#  DT_with_fye <- merge(DT_with_fye, study_programs, by = "cip6", all.x = TRUE)
#  cols_we_want <- c("program", "N")
#  DT_with_fye <- DT_with_fye[order(-N), ..cols_we_want]
#  
#  # perform your own prediction
#  engr_cip <- filter_search(cip, keep_text = "^14")
#  engr <- filter_match(term,
#    match_to = engr_cip,
#    by_col = "cip6",
#    select = "mcid"
#  )
#  engr <- unique(engr)
#  engr <- filter_match(engr,
#    match_to = student,
#    by_col = "mcid"
#  )
#  engr <- add_race_sex(engr, midfield_table = student)
#  fye <- condition_fye(engr, midfield_table = term)
#  
#  # mice
#  framework <- mice(fye, maxit = 0)
#  method <- framework[["method"]]
#  method[c("cip6")] <- "polyreg"
#  method[c("mcid", "institution", "race", "sex")] <- ""
#  predictors <- framework[["predictorMatrix"]]
#  predictors[, c("mcid", "cip6")] <- 0
#  predictors[, c("institution", "race", "sex")] <- c(0, 0, 0, 0, 1)
#  fye_mids <- mice(
#    data = fye,
#    method = method,
#    predictorMatrix = predictors,
#    seed = 20180624,
#    printFlag = TRUE
#  )
#  fye <- complete(fye_mids)
#  
#  # prepare for use
#  setDT(fye)
#  cols_we_want <- c("mcid", "cip6")
#  fye <- fye[, ..cols_we_want]
#  fye[, cip6 := as.character(cip6)]
#  fye <- fye[order(mcid)]
#  setnames(fye, old = "cip6", new = "start")
#  
#  # reinitialize random number seed
#  set.seed(NULL)

