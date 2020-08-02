## ----setup, include = FALSE---------------------------------------------------
source("vignette-knitr-opts.R")
knitr::opts_chunk$set(fig.path = "../man/figures/vignette-impute-fye-")

## -----------------------------------------------------------------------------
# packages used 
library(midfieldr)
library(midfielddata)

# print max 20 rows, otherwise 5 rows each head/tail
options(datatable.print.nrows = 20, datatable.print.topn = 5)

## -----------------------------------------------------------------------------
# view the example data
midfield_fye

## -----------------------------------------------------------------------------
str(exa_ever)

## -----------------------------------------------------------------------------
matric <- filter_by_id(midfieldstudents, 
                       keep_id = exa_ever, 
                       keep_col = c("id", "cip6"), 
                       unique_row = TRUE)
rows_we_want <- matric$cip %in% c("14XXXX", "14YYYY")
engr <- matric[!rows_we_want]
fye  <- matric[rows_we_want]

# join
fye <- merge(fye, midfield_fye, by = "id", all.x = TRUE)

# add start column 
engr <- engr[, .(id, cip6, start = cip6)]

starters <- rbind(fye, engr)
starters[order(id)]
starters

## -----------------------------------------------------------------------------
# additional packages used for the imputation 
library(midfielddata)
library(data.table)
library(mice)
library(visdat)

## -----------------------------------------------------------------------------
# extract IDs of all FYE students in midfieldstudents
rows_we_want <- midfieldstudents$cip6 %in% c("14XXXX", "14YYYY")
columns_we_want <- c("id")
fye <- midfieldstudents[rows_we_want, ..columns_we_want]

# examine the result
fye

## -----------------------------------------------------------------------------
# post-FYE major 
fye_id <- fye$id
cip_post_fye <- cip_after_fye(fye_id)

# examine the result
cip_post_fye

## -----------------------------------------------------------------------------
# reset CIP as "start" column 
engr_post_fye <- cip_post_fye[, .(id, start = cip6)]

# find NOT engineering rows
rows_we_want <- !grepl("^14", engr_post_fye$start)

# set NOT engineering to NA
engr_post_fye[rows_we_want, start := NA_character_]

# examine the result
engr_post_fye

## ----eval=FALSE---------------------------------------------------------------
#  library(dplyr)
#  inst_id <- semi_join(midfieldstudents, engr_post_fye, by = "id") %>%
#    select(id, institution)
#  
#  engr_post_fye <- left_join(engr_post_fye, inst_id, by = "id")
#  
#  race_sex <- filter_by_id(midfieldstudents,
#                           keep_id = engr_post_fye$id,
#                           keep_col = c("id", "race", "sex"),
#                           unique_row = TRUE)
#  engr_post_fye <- left_join(engr_post_fye, race_sex, by = "id")
#  
#  setDT(engr_post_fye)
#  
#  engr_post_fye

## ----eval=FALSE---------------------------------------------------------------
#  # TBD

