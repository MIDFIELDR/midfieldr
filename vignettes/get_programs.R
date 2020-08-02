## ----setup, include = FALSE---------------------------------------------------
source("vignette-knitr-opts.R")
knitr::opts_chunk$set(fig.path = "../man/figures/vignette-get-programs-")

## -----------------------------------------------------------------------------
# packages used
library(midfieldr)
library(data.table)

# print max 20 rows, otherwise 5 rows each head/tail
options(datatable.print.nrows = 20, datatable.print.topn = 5)

## -----------------------------------------------------------------------------
# view the example CIP
exa_cip

## -----------------------------------------------------------------------------
# case study CIP subset
columns_we_want <- c("cip4", "cip4name")
exa_cip4 <- exa_cip[, ..columns_we_want]

# examine the result
exa_cip4

## -----------------------------------------------------------------------------
# work with programs one at a time and bind
# get civil engineering 6-digit codes 
cve <- filter_by_text(exa_cip, keep_any = "^1408", keep_col = "cip6")
cve

## -----------------------------------------------------------------------------
# add a program label
cve[, program := "Civil Engineering"]
cve

## -----------------------------------------------------------------------------
# get electrical  engineering
ele <- filter_by_text(exa_cip, keep_any = "^1410", keep_col = "cip6")
ele[, program := "Electrical Engineering"]
ele

# get mechanical  engineering
mce <- filter_by_text(exa_cip, keep_any = "^1419", keep_col = "cip6")
mce[, program := "Mechanical Engineering"]
mce

# get industrial engineering
ise <- filter_by_text(exa_cip, keep_any = "^1435", keep_col = "cip6")
ise[, program := "Industrial Engineering"]
ise

## -----------------------------------------------------------------------------
# gather the programs in the study
program_group <- rbind(cve, ele, ise, mce)

# examine the result
program_group

## -----------------------------------------------------------------------------
# work with programs all in one data frame
program_group <- exa_cip[, .(cip6, program = cip4name)]

# examine the result
program_group

## -----------------------------------------------------------------------------
# identify the CIP rows that start with 1410
rows_to_edit <- startsWith(program_group$cip6, "1410")

# relabel the electrical programs
program_group[rows_to_edit, program := "Electrical Engineering"]

# examine the result
program_group

## -----------------------------------------------------------------------------
# assign the 2-digit level name
sub_cip <- filter_by_text(cip, 
                          keep_any = "^31", 
                          keep_col = c("cip6", "cip2name"))
program_group <- sub_cip[, .(cip6, program = cip2name)]

## ----echo = FALSE-------------------------------------------------------------
kable2html(program_group)

## -----------------------------------------------------------------------------
# assign the 4-digit level name
sub_cip <- filter_by_text(cip, 
                          keep_any = "^31", 
                          keep_col = c("cip6", "cip4name"))
program_group <- sub_cip[, .(cip6, program = cip4name)]

## ----echo = FALSE-------------------------------------------------------------
kable2html(program_group)

## -----------------------------------------------------------------------------
# assign the 6-digit level name
sub_cip <- filter_by_text(cip, 
                          keep_any = "^31", 
                          keep_col = c("cip6", "cip6name"))
program_group <- sub_cip[, .(cip6, program = cip6name)]

## ----echo = FALSE-------------------------------------------------------------
kable2html(program_group)

## -----------------------------------------------------------------------------
# assign an arbitrary program name
sub_cip <- filter_by_text(cip, keep_any = "^31", keep_col = "cip6")
program_group <- sub_cip[, program := "Leisure Studies"]

## ----echo = FALSE-------------------------------------------------------------
kable2html(program_group)

## -----------------------------------------------------------------------------
# name and class of variables (columns) in cip
sapply(cip, FUN = class)

## ----eval = FALSE-------------------------------------------------------------
#  # packages used
#  library(midfieldr)
#  library(data.table)
#  
#  # work with programs one at a time and bind
#  cve <- filter_by_text(exa_cip, keep_any = "^1408", keep_col = "cip6")
#  cve[, program := "Civil Engineering"]
#  
#  ele <- filter_by_text(exa_cip, keep_any = "^1410", keep_col = "cip6")
#  ele[, program := "Electrical Engineering"]
#  
#  mce <- filter_by_text(exa_cip, keep_any = "^1419", keep_col = "cip6")
#  mce[, program := "Mechanical Engineering"]
#  
#  ise <- filter_by_text(exa_cip, keep_any = "^1435", keep_col = "cip6")
#  ise[, program := "Industrial Engineering"]
#  
#  program_group <- rbind(cve, ele, ise, mce)
#  
#  # work with programs all in one data frame
#  program_group <- exa_cip[, .(cip6, program = cip4name)]
#  rows_to_edit <- startsWith(program_group$cip6, "1410")
#  program_group[rows_to_edit, program := "Electrical Engineering"]
#  
#  # assign the 2-digit level name
#  sub_cip <- filter_by_text(cip,
#                            keep_any = "^31",
#                            keep_col = c("cip6", "cip2name"))
#  program_group <- sub_cip[, .(cip6, program = cip2name)]
#  
#  # assign the 4-digit level name
#  sub_cip <- filter_by_text(cip,
#                            keep_any = "^31",
#                            keep_col = c("cip6", "cip4name"))
#  program_group <- sub_cip[, .(cip6, program = cip4name)]
#  
#  # assign the 6-digit level name
#  sub_cip <- filter_by_text(cip,
#                            keep_any = "^31",
#                            keep_col = c("cip6", "cip6name"))
#  program_group <- sub_cip[, .(cip6, program = cip6name)]
#  
#  
#  # assign an arbitrary program name
#  sub_cip <- filter_by_text(cip, keep_any = "^31", keep_col = "cip6")
#  program_group <- sub_cip[, program := "Leisure Studies"]
#  
#  
#  # name and class of variables (columns) in cip
#  sapply(cip, FUN = class)

