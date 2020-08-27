## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(fig.path = "../man/figures/vignette-handle-fye-")
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

# optional
library(mice)

# print max 20 rows, otherwise 10 rows each head/tail
options(datatable.print.nrows = 20, datatable.print.topn = 10)

## -----------------------------------------------------------------------------
# FYE predicted starting programs
fye_start

## -----------------------------------------------------------------------------
# tally N students by program CIP
fye_start_summary <- fye_start[, .(.N), by = .(start)]
fye_start_summary

## ----results = "hide"---------------------------------------------------------
# rename start to cip6 for join
setnames(fye_start_summary, old = "start", new = "cip6")

# left-join program names from CIP data
fye_start_summary <- merge(fye_start_summary, cip, by = "cip6", all.x = TRUE)

# order rows and select columns
setnames(fye_start_summary, old = "cip6", new = "start")
cols_we_want <- c("start", "cip6name", "N")
fye_start_summary <- fye_start_summary[order(-N), ..cols_we_want]
fye_start_summary

## ----echo = FALSE-------------------------------------------------------------
kable2html(fye_start_summary, caption = "Summary of starting program predictions")

## -----------------------------------------------------------------------------
# IDs of students ever enrolled in the case study programs
str(rep_ever)

## -----------------------------------------------------------------------------
# matriculation CIP for representative example
rows_we_want <- midfieldstudents$id %in% rep_ever
cols_we_want <- c("id", "cip6")
matric_programs <- midfieldstudents[rows_we_want, ..cols_we_want]

# examine the result
matric_programs

## -----------------------------------------------------------------------------
# left-join the predicted CIPs for FYE students
start_programs <- merge(matric_programs,
  fye_start,
  by = "id",
  all.x = TRUE
)

# examine the result
start_programs

## -----------------------------------------------------------------------------
# non-FYE, replace NA with matriculation CIP
rows_non_fye <- is.na(start_programs$start)
start_programs <- start_programs[rows_non_fye, start := cip6]

## -----------------------------------------------------------------------------
# remove the matriculation CIP codes
start_programs[, cip6 := NULL]

# examine the result
start_programs[]

## ----echo = FALSE-------------------------------------------------------------
load("../inst/extdata/fye-vignette-data.rda")

## -----------------------------------------------------------------------------
# prepare data for mice()
mi_data <- prepare_fye_mi(midfieldstudents, midfieldterms)

# examine the result
mi_data[]

## ----echo = FALSE-------------------------------------------------------------
# set false to avoid imputation
knitr::opts_chunk$set(eval = FALSE)

## -----------------------------------------------------------------------------
#  # examine default arguments
#  mice(mi_data, maxit = 0)
#  # > Class: mids
#  # > Number of multiple imputations:  5
#  # > Imputation methods:
#  # >          id institution        race         sex        cip6
#  # >          ""          ""          ""          ""   "polyreg"
#  # > PredictorMatrix:
#  # >             id institution race sex cip6
#  # > id           0           1    1   1    1
#  # > institution  0           0    1   1    1
#  # > race         0           1    0   1    1
#  # > sex          0           1    1   0    1
#  # > cip6         0           1    1   1    0
#  # > Number of logged events:  1
#  # >   it im dep     meth out
#  # > 1  0  0     constant  id

## -----------------------------------------------------------------------------
#  # impute missing CIP codes
#  mi_mids <- mice::mice(mi_data, seed = 20180624, printFlag = TRUE)
#  # >  iter imp variable
#  # >   1   1  cip6
#  # >   1   2  cip6
#  # >   1   3  cip6
#  # >   1   4  cip6
#  # >   1   5  cip6
#  # > ---
#  # >   5   1  cip6
#  # >   5   2  cip6
#  # >   5   3  cip6
#  # >   5   4  cip6
#  # >   5   5  cip6

## -----------------------------------------------------------------------------
#  # export result to data frame
#  mi_start <- mice::complete(mi_mids)
#  
#  # convert to data.table structure
#  data.table::setDT(mi_start)
#  
#  # examine the result
#  mi_start[]
#  # >                id   institution          race    sex   cip6
#  # >    1: MID25783162 Institution M         White   Male 140901
#  # >    2: MID25783166 Institution M         White   Male 141901
#  # >    3: MID25783167 Institution M         White   Male 140901
#  # >    4: MID25783178 Institution M         Black   Male 140701
#  # >    5: MID25783197 Institution M         White   Male 140701
#  # >    6: MID25783199 Institution M         White Female 140301
#  # >    7: MID25783227 Institution M         White   Male 141001
#  # >    8: MID25783257 Institution M         White   Male 140701
#  # >    9: MID25783275 Institution M         White   Male 140501
#  # >   10: MID25783388 Institution M         White   Male 141901
#  # >   ---
#  # > 5983: MID26648334 Institution J International   Male 140801
#  # > 5984: MID26648354 Institution J         Asian   Male 140901
#  # > 5985: MID26648392 Institution J         White Female 141901
#  # > 5986: MID26648417 Institution J         White   Male 140201
#  # > 5987: MID26648422 Institution J         White   Male 141901
#  # > 5988: MID26648435 Institution J      Hispanic   Male 141901
#  # > 5989: MID26648484 Institution J      Hispanic   Male 140801
#  # > 5990: MID26648508 Institution J International Female 140701
#  # > 5991: MID26648517 Institution J      Hispanic   Male 140801
#  # > 5992: MID26648544 Institution J         White   Male 141901

## -----------------------------------------------------------------------------
#  # select columns
#  cols_we_want <- c("id", "cip6")
#  mi_start <- mi_start[, ..cols_we_want]
#  
#  # ensure our columns are characters
#  mi_start[, id := as.character(id)]
#  mi_start[, cip6 := as.character(cip6)]
#  
#  # order the rows
#  mi_start <- mi_start[order(id)]
#  
#  # rename CIP to start
#  setnames(mi_start, old = "cip6", new = "start")
#  
#  # examine the result
#  mi_start[]
#  # >                id  start
#  # >    1: MID25783162 140901
#  # >    2: MID25783166 141901
#  # >    3: MID25783167 140901
#  # >    4: MID25783178 140701
#  # >    5: MID25783197 140701
#  # >    6: MID25783199 140301
#  # >    7: MID25783227 141001
#  # >    8: MID25783257 140701
#  # >    9: MID25783275 140501
#  # >   10: MID25783388 141901
#  # >   ---
#  # > 5983: MID26648334 140801
#  # > 5984: MID26648354 140901
#  # > 5985: MID26648392 141901
#  # > 5986: MID26648417 140201
#  # > 5987: MID26648422 141901
#  # > 5988: MID26648435 141901
#  # > 5989: MID26648484 140801
#  # > 5990: MID26648508 140701
#  # > 5991: MID26648517 140801
#  # > 5992: MID26648544 141901

## -----------------------------------------------------------------------------
#  # verify result matches expectation
#  all.equal(mi_start, fye_start)
#  # > [1] TRUE

## ----echo = FALSE, eval = TRUE------------------------------------------------
# set false to avoid imputation
knitr::opts_chunk$set(eval = TRUE)

## -----------------------------------------------------------------------------
# unload because mice masks rbind
detach("package:mice", unload = TRUE)

## ----echo = FALSE-------------------------------------------------------------
# set false to avoid imputation
knitr::opts_chunk$set(eval = FALSE)

## ----echo = FALSE, eval = FALSE-----------------------------------------------
#  fye01[order(id)]

## -----------------------------------------------------------------------------
#  # >                id   institution          race    sex
#  # >    1: MID25783162 Institution M         White   Male
#  # >    2: MID25783166 Institution M         White   Male
#  # >    3: MID25783167 Institution M         White   Male
#  # >    4: MID25783178 Institution M         Black   Male
#  # >    5: MID25783197 Institution M         White   Male
#  # >    6: MID25783199 Institution M         White Female
#  # >    7: MID25783227 Institution M         White   Male
#  # >    8: MID25783257 Institution M         White   Male
#  # >    9: MID25783275 Institution M         White   Male
#  # >   10: MID25783388 Institution M         White   Male
#  # >   ---
#  # > 5983: MID26648334 Institution J International   Male
#  # > 5984: MID26648354 Institution J         Asian   Male
#  # > 5985: MID26648392 Institution J         White Female
#  # > 5986: MID26648417 Institution J         White   Male
#  # > 5987: MID26648422 Institution J         White   Male
#  # > 5988: MID26648435 Institution J      Hispanic   Male
#  # > 5989: MID26648484 Institution J      Hispanic   Male
#  # > 5990: MID26648508 Institution J International Female
#  # > 5991: MID26648517 Institution J      Hispanic   Male
#  # > 5992: MID26648544 Institution J         White   Male

## ----echo = FALSE, eval = FALSE-----------------------------------------------
#  fye02[order(id)]

## -----------------------------------------------------------------------------
#  # >                id   cip6
#  # >    1: MID25783167 140901
#  # >    2: MID25783178 140701
#  # >    3: MID25783197 140701
#  # >    4: MID25783199 140301
#  # >    5: MID25783257 140701
#  # >    6: MID25783275 140501
#  # >    7: MID25783388 141901
#  # >    8: MID25783441 140801
#  # >    9: MID25783491 141001
#  # >   10: MID25783553 140801
#  # >   ---
#  # > 3359: MID26640528 141901
#  # > 3360: MID26640591 141901
#  # > 3361: MID26640613 142101
#  # > 3362: MID26640916 141901
#  # > 3363: MID26640932 141101
#  # > 3364: MID26641121 140201
#  # > 3365: MID26642386 140801
#  # > 3366: MID26642809 140801
#  # > 3367: MID26642812 141001
#  # > 3368: MID26643920 141901

## ----echo = FALSE, eval = FALSE-----------------------------------------------
#  fye03[order(id)]

## -----------------------------------------------------------------------------
#  # >                id   institution          race    sex   cip6
#  # >    1: MID25783162 Institution M         White   Male   <NA>
#  # >    2: MID25783166 Institution M         White   Male   <NA>
#  # >    3: MID25783167 Institution M         White   Male 140901
#  # >    4: MID25783178 Institution M         Black   Male 140701
#  # >    5: MID25783197 Institution M         White   Male 140701
#  # >    6: MID25783199 Institution M         White Female 140301
#  # >    7: MID25783227 Institution M         White   Male   <NA>
#  # >    8: MID25783257 Institution M         White   Male 140701
#  # >    9: MID25783275 Institution M         White   Male 140501
#  # >   10: MID25783388 Institution M         White   Male 141901
#  # >   ---
#  # > 5983: MID26648334 Institution J International   Male   <NA>
#  # > 5984: MID26648354 Institution J         Asian   Male   <NA>
#  # > 5985: MID26648392 Institution J         White Female   <NA>
#  # > 5986: MID26648417 Institution J         White   Male   <NA>
#  # > 5987: MID26648422 Institution J         White   Male   <NA>
#  # > 5988: MID26648435 Institution J      Hispanic   Male   <NA>
#  # > 5989: MID26648484 Institution J      Hispanic   Male   <NA>
#  # > 5990: MID26648508 Institution J International Female   <NA>
#  # > 5991: MID26648517 Institution J      Hispanic   Male   <NA>
#  # > 5992: MID26648544 Institution J         White   Male   <NA>

## -----------------------------------------------------------------------------
#  mi_data <- prepare_fye_mi()

## -----------------------------------------------------------------------------
#  mi_framework <- mice::mice(mi_data, maxit = 0)

## -----------------------------------------------------------------------------
#  mi_method <- mi_framework$method
#  mi_predictors <- mi_framework$predictorMatrix

## -----------------------------------------------------------------------------
#  # apply an imputation method to CIP only
#  mi_method[c("cip6")] <- "polyreg"
#  mi_method[c("id", "institution", "race", "sex")] <- ""

## -----------------------------------------------------------------------------
#  mi_predictors[, c("id")] <- 0

## -----------------------------------------------------------------------------
#  mi_mids <- mice::mice(
#    data = mi_data,
#    method = mi_method,
#    predictorMatrix = mi_predictors,
#    seed = 20180624,
#    printFlag = TRUE
#  )

## ----eval=FALSE---------------------------------------------------------------
#  # packages used
#  library(midfieldr)
#  library(midfielddata)
#  library(data.table)
#  library(mice)
#  
#  # Option 1: Ready-to-use starting programs
#  # Summarize fye_start by program CIP
#  fye_start_summary <- fye_start[, .(N = .N), by = "start"]
#  setnames(fye_start_summary, old = "start", new = "cip6")
#  fye_start_summary <- merge(fye_start_summary, cip, by = "cip6", all.x = TRUE)
#  setnames(fye_start_summary, old = "cip6", new = "start")
#  cols_we_want <- c("start", "cip6name", "N")
#  fye_start_summary <- fye_start_summary[order(-N), ..cols_we_want]
#  
#  # How to use fye_start
#  rows_we_want <- midfieldstudents$id %in% rep_ever
#  cols_we_want <- c("id", "cip6")
#  matric_programs <- midfieldstudents[rows_we_want, ..cols_we_want]
#  start_programs <- merge(matric_programs,
#    fye_start,
#    by = "id",
#    all.x = TRUE
#  )
#  rows_non_fye <- is.na(start_programs$start)
#  start_programs <- start_programs[rows_non_fye, start := cip6]
#  start_programs[, cip6 := NULL]
#  
#  # Option 2: Perform the multiple imputation
#  # How to use prepare_fye_mi()
#  mi_data <- prepare_fye_mi(midfieldstudents, midfieldterms)
#  
#  # How to use mice()
#  mice(mi_data, maxit = 0)
#  mi_mids <- mice::mice(mi_data, seed = 20180624, printFlag = TRUE)
#  mi_start <- mice::complete(mi_mids)
#  data.table::setDT(mi_start)
#  cols_we_want <- c("id", "cip6")
#  mi_start <- mi_start[, ..cols_we_want]
#  mi_start[, id := as.character(id)]
#  mi_start[, cip6 := as.character(cip6)]
#  mi_start <- mi_start[order(id)]
#  setnames(mi_start, old = "cip6", new = "start")
#  detach("package:mice", unload = TRUE)
#  
#  # Appendix: editing the arguments for mice()
#  mi_data <- prepare_fye_mi()
#  mi_framework <- mice::mice(mi_data, maxit = 0)
#  mi_method <- mi_framework$method
#  mi_predictors <- mi_framework$predictorMatrix
#  mi_method[c("cip6")] <- "polyreg"
#  mi_method[c("id", "institution", "race", "sex")] <- ""
#  mi_predictors[, c("id")] <- 0
#  mi_mids <- mice::mice(
#    data = mi_data,
#    method = mi_method,
#    predictorMatrix = mi_predictors,
#    seed = 20180624,
#    printFlag = TRUE
#  )

## ----echo = FALSE-------------------------------------------------------------
#  # set false to avoid imputation
#  knitr::opts_chunk$set(eval = TRUE)

