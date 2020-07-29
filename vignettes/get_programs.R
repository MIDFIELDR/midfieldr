## ----setup, include = FALSE---------------------------------------------------
source("vignette-knitr-opts.R")
knitr::opts_chunk$set(fig.path = "../man/figures/vignette-get-programs-")

## -----------------------------------------------------------------------------
# packages used
library(midfieldr)
library(data.table)

# data.table, print max 20 rows, otherwise 5 rows head/tail
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
# get civil engineering
cve_cip <- get_cip(exa_cip, keep_any = "^1408")
cve_cip

## -----------------------------------------------------------------------------
# keep the 6-digit CIP and add a program label
cve <- label_programs(cve_cip, label = "Civil Engineering")
cve

## -----------------------------------------------------------------------------
# get electrical  engineering
ele_cip <- get_cip(exa_cip, keep_any = "^1410")
ele <- label_programs(ele_cip, label = "Electrical Engineering")
ele

## -----------------------------------------------------------------------------
# get mechanical  engineering
mce_cip <- get_cip(exa_cip, keep_any = "^1419")
mce <- label_programs(mce_cip, label = "cip4name")
mce

# get industrial engineering
ise_cip <- get_cip(exa_cip, keep_any = "^1435")
ise <- label_programs(ise_cip, label = "cip4name")
ise

## -----------------------------------------------------------------------------
# gather the programs in the study
program_group <- rbind(cve, ele, ise, mce)

# delete the verbose column
program_group[, cip6name := NULL]

# examine the result
program_group

## -----------------------------------------------------------------------------
# work with programs all in one data frame
program_group <- label_programs(exa_cip, label = "cip4name")

# delete the verbose column
program_group[, cip6name := NULL]

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
# assign an arbitrary program name
sub_cip <- get_cip(cip, keep_any = "^31")
program_group <- label_programs(sub_cip, label = "Leisure Studies")

## ----echo = FALSE-------------------------------------------------------------
kable2html(program_group)

## -----------------------------------------------------------------------------
# assign the 2-digit level name
program_group <- label_programs(sub_cip, label = "cip2name")

## ----echo = FALSE-------------------------------------------------------------
kable2html(program_group)

## -----------------------------------------------------------------------------
# assign the 6-digit level name
program_group <- label_programs(sub_cip, label = "cip6name")

## ----echo = FALSE-------------------------------------------------------------
kable2html(program_group)

## -----------------------------------------------------------------------------
# label argument NULL same as 4-digit level name
program_group <- label_programs(sub_cip)

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
#  cve_cip <- get_cip(exa_cip, keep_any = "^1408")
#  cve <- label_programs(cve_cip, label = "Civil Engineering")
#  
#  ele_cip <- get_cip(exa_cip, keep_any = "^1410")
#  ele <- label_programs(ele_cip, label = "Electrical Engineering")
#  
#  mce_cip <- get_cip(exa_cip, keep_any = "^1419")
#  mce <- label_programs(mce_cip, label = "cip4name")
#  
#  ise_cip <- get_cip(exa_cip, keep_any = "^1435")
#  ise <- label_programs(ise_cip, label = "cip4name")
#  
#  program_group <- rbind(cve, ele, ise, mce)
#  program_group[, cip6name := NULL]
#  
#  # work with programs all in one data frame
#  program_group <- label_programs(exa_cip, label = "cip4name")
#  program_group[, cip6name := NULL]
#  rows_to_edit <- startsWith(program_group$cip6, "1410")
#  program_group[rows_to_edit, program := "Electrical Engineering"]
#  
#  # assign an arbitrary program name
#  sub_cip <- get_cip(cip, keep_any = "^31")
#  program_group <- label_programs(sub_cip, label = "Leisure Studies")
#  
#  # assign the 2-digit level name
#  program_group <- label_programs(sub_cip, label = "cip2name")
#  
#  # assign the 6-digit level name
#  program_group <- label_programs(sub_cip, label = "cip6name")
#  
#  # label argument NULL same as 4-digit level name
#  program_group <- label_programs(sub_cip)
#  
#  # name and class of variables (columns) in cip
#  sapply(cip, FUN = class)

