## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(fig.path = here::here("man/figures", 
                                            "art-03-case-selection-"))
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
options(datatable.print.nrows = 10, 
        datatable.print.topn  = 5, 
        datatable.print.class = TRUE)

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
case_study <- filter_search(pass04, select = c("cip6", "cip4name"))
case_study

## -----------------------------------------------------------------------------
case_study[, program := cip4name]
case_study

## -----------------------------------------------------------------------------
dframe <- copy(case_study)
dframe[, program := fcase(
  program %ilike% "civil"     , "CVE", 
  program %ilike% "electrical", "ECE", 
  program %ilike% "mechanical", "MCE", 
  program %ilike% "industrial", "ISE"
)]
dframe

## -----------------------------------------------------------------------------
# return matches in the cip4name column 
dframe <- copy(case_study) 
rows_to_edit <- dframe$program %ilike% "electrical"
dframe[rows_to_edit, program := "Electrical Engineering"]
dframe

## -----------------------------------------------------------------------------
# return matches that start with 1410
rows_to_edit <- case_study$cip6 %like% "^1410"
case_study[rows_to_edit, program := "Electrical Engineering"]
case_study

## -----------------------------------------------------------------------------
case_study[, cip4name := NULL]

case_study

## -----------------------------------------------------------------------------
# optional code to control data.table printing
options(datatable.print.topn = 5)

# subset degree rows
rows_we_want <- degree$cip6 %chin% case_study$cip6
case_degree <- degree[rows_we_want]

# examine the result
case_degree

## -----------------------------------------------------------------------------
# subset degree rows and columns 
cols_we_want <- c("mcid", "institution", "cip6")
rows_we_want <- degree$cip6 %chin% case_study$cip6
case_degree <- degree[rows_we_want, ..cols_we_want]

# examine the result
case_degree

## -----------------------------------------------------------------------------
# subset degree table
dframe <- filter_match(degree, 
                        match_to = case_study, 
                        by_col   = "cip6", 
                        select   = c("mcid", "institution", "cip6"))

# compare to the DT we obtained above after ordering rows the same way
all.equal(case_degree[order(mcid)], dframe[order(mcid)])

## -----------------------------------------------------------------------------
# subset student table
case_student <- filter_match(student, 
                        match_to = case_degree, 
                        by_col   = "mcid", 
                        select   = c("mcid", "transfer", "hours_transfer"))
# examine the result
case_student

## -----------------------------------------------------------------------------
case_student[, .N, by = "transfer"]

## -----------------------------------------------------------------------------
# join program names 
case_degree <- merge(case_degree, case_study, by = "cip6", all.x = TRUE)

# examine the result
case_degree

## -----------------------------------------------------------------------------
case_degree[, .N, by = "program"]

## -----------------------------------------------------------------------------
study_programs

## -----------------------------------------------------------------------------
all.equal(case_study, study_programs)

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
#  options(datatable.print.nrows = 10,
#          datatable.print.topn  = 5,
#          datatable.print.class = TRUE)
#  
#  # identify program codes
#  pass01 <- filter_search(cip, "engineering")
#  pass02 <- filter_search(pass01, "^14")
#  pass03 <- filter_search(pass02,
#                          c("civil", "electrical", "industrial", "mechanical"))
#  pass04 <- filter_search(pass03, drop_text = "electromechanical")
#  case_study <- filter_search(pass04, select = c("cip6", "cip4name"))
#  
#  # assign program names
#  case_study[, program := cip4name]
#  dframe <- copy(case_study)
#  dframe[, program := fcase(
#    program %ilike% "civil"     , "CVE",
#    program %ilike% "electrical", "ECE",
#    program %ilike% "mechanical", "MCE",
#    program %ilike% "industrial", "ISE"
#  )]
#  dframe <- copy(case_study)
#  rows_to_edit <- dframe$program %ilike% "electrical"
#  dframe[rows_to_edit, program := "Electrical Engineering"]
#  rows_to_edit <- case_study$cip6 %like% "^1410"
#  case_study[rows_to_edit, program := "Electrical Engineering"]
#  case_study[, cip4name := NULL]
#  
#  # apply results
#  case_degree <- filter_match(degree,
#                              match_to = case_study,
#                              by_col   = "cip6",
#                              select   = c("mcid", "institution", "cip6"))
#  case_student <- filter_match(student,
#                               match_to = case_degree,
#                               by_col   = "mcid",
#                               select   = c("mcid", "transfer", "hours_transfer"))
#  case_student[, .N, by = "transfer"]
#  case_degree <- merge(case_degree, case_study, by = "cip6", all.x = TRUE)
#  case_degree[, .N, by = "program"]
#  
#  # save results
#  fwrite(case_study, file = "results/case_study.csv")
#  case_study <- fread(
#    "results/case_study.csv",
#    colClasses = list(character = c("cip6"))
#  )

