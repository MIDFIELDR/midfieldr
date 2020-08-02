## ----setup, include = FALSE---------------------------------------------------
source("vignette-knitr-opts.R")
knitr::opts_chunk$set(fig.path = "../man/figures/vignette-compute-stickiness-")

## -----------------------------------------------------------------------------
# packages used
library(midfieldr)
library(midfielddata)
library(data.table)
library(ggplot2)

# print max 20 rows, otherwise 5 rows each head/tail
options(datatable.print.nrows = 20, datatable.print.topn = 5)

## -----------------------------------------------------------------------------
# obtain programs (built-in data set) 
program_group <- exa_group

# examine the result
program_group

## -----------------------------------------------------------------------------
# extract a vector of 6-digit CIP codes
group_codes <- program_group$cip6

# examine the result
group_codes

## -----------------------------------------------------------------------------
# gather students ever enrolled in programs
enrollees <- filter_by_cip(midfieldterms, 
                           keep_cip = group_codes, 
                           keep_col = c("id", "cip6"), 
                           unique_row = TRUE)

# examine the result
enrollees

## -----------------------------------------------------------------------------
# apply the feasible completion filter
feasible_ids <- completion_feasible(id = enrollees$id)

# examine the result
str(feasible_ids)

## -----------------------------------------------------------------------------
# subset the enrollees
rows_we_want <- enrollees$id %in% feasible_ids
enrollees <- enrollees[rows_we_want]

# examine the result
enrollees

## -----------------------------------------------------------------------------
# obtain race/ethnicity and sex at matriculation
race_sex <- filter_by_id(midfieldstudents, 
                      keep_id = feasible_ids, 
                      keep_col = c("id", "race", "sex"), 
                      unique_row = TRUE)

# examine the result
race_sex

## -----------------------------------------------------------------------------
# left-join demographics to enrollees
enrollees <- merge(enrollees, race_sex, by = "id", all.x = TRUE)

# examine the result
enrollees

## -----------------------------------------------------------------------------
# left-join program_group to enrollees
enrollees <- merge(enrollees, program_group, by = "cip6", all.x = TRUE)

# examine the result
enrollees

## -----------------------------------------------------------------------------
# gather students graduating from programs
graduates <- filter_by_cip(midfielddegrees, 
                       keep_cip = group_codes, 
                       keep_col = c("id", "cip6"), 
                       unique_row = TRUE, 
                       first_degree = TRUE)
race_sex <- filter_by_id(midfieldstudents,
                      keep_id = graduates$id,
                      keep_col = c("id", "race", "sex"), 
                      unique_row = TRUE)
graduates <- merge(graduates, race_sex, by = "id", all.x = TRUE)
graduates <- merge(graduates, program_group, by = "cip6", all.x = TRUE)

# examine the result
graduates

## -----------------------------------------------------------------------------
# assign variables to aggregate by
grouping_variables <- c("program", "race", "sex")

## -----------------------------------------------------------------------------
# group and summarize
grouped_enrollees <- enrollees[, .(ever = .N), by = grouping_variables]

# examine the result
grouped_enrollees

## -----------------------------------------------------------------------------
# group and summarize
grouped_graduates <- graduates[, .(grad = .N), by = grouping_variables]

# examine the result
grouped_graduates

## -----------------------------------------------------------------------------
# left-join graduates to enrollees
grouped_data <- merge(grouped_enrollees,
  grouped_graduates,
  by = grouping_variables,
  all.x = TRUE
)

# examine the result, ordered by program
grouped_data[order(program)]

## -----------------------------------------------------------------------------
# begin work on computing the metric
stickiness <- grouped_data

# identify NA values
rows_with_degree_NA <- is.na(stickiness$grad)
stickiness[rows_with_degree_NA]

## -----------------------------------------------------------------------------
# convert grad NA to zero
stickiness[rows_with_degree_NA, grad := 0]

# examine the result
stickiness[rows_with_degree_NA]

## -----------------------------------------------------------------------------
# prevent division by zero
rows_we_want <- stickiness$ever > 0
stickiness <- stickiness[rows_we_want]

## -----------------------------------------------------------------------------
# compute stickiness
stickiness[, stick := round(grad / ever, 2)]

# examine the result
stickiness

## -----------------------------------------------------------------------------
# name and class of variables (columns)
sapply(stickiness, FUN = class)

## -----------------------------------------------------------------------------
# condition the data in multiway form (built-in data set)
data_mw <- exa_stickiness_mw
data_mw

## -----------------------------------------------------------------------------
# name and class of variables (columns)
sapply(data_mw, FUN = attributes)

## ----echo = FALSE-------------------------------------------------------------
nlevel1 <- nlevels(data_mw$program)
nlevel2 <- nlevels(data_mw$race_sex)
r <- nlevel1 * nlevel2
q <- 32
asp_ratio1 <- (r + 2 * nlevel1) / q
asp_ratio2 <- (r + 2 * nlevel2) / q

## ----fig1, fig.asp = asp_ratio1-----------------------------------------------
# graph results
ggplot(data = data_mw, mapping = aes(x = stick, y = race_sex)) +
  facet_wrap(facets = vars(program), ncol = 1, as.table = FALSE) +
  geom_point(na.rm = TRUE) +
  labs(x = "Stickiness", y = "")

## ----eval=FALSE---------------------------------------------------------------
#  # packages used
#  library(midfieldr)
#  library(midfielddata)
#  library(data.table)
#  library(ggplot2)
#  
#  # obtain programs (built-in data set)
#  program_group <- exa_group
#  group_codes <- program_group$cip6
#  
#  # gather students ever enrolled in programs
#  enrollees <- filter_by_cip(midfieldterms,
#                             keep_cip = group_codes,
#                             keep_col = c("id", "cip6"),
#                             unique_row = TRUE)
#  feasible_ids <- completion_feasible(id = enrollees$id)
#  rows_we_want <- enrollees$id %in% feasible_ids
#  enrollees <- enrollees[rows_we_want]
#  race_sex <- filter_by_id(midfieldstudents,
#                           keep_id = feasible_ids,
#                           keep_col = c("id", "race", "sex"),
#                           unique_row = TRUE)
#  enrollees <- merge(enrollees, race_sex, by = "id", all.x = TRUE)
#  enrollees <- merge(enrollees, program_group, by = "cip6", all.x = TRUE)
#  
#  # gather students graduating from programs
#  graduates <- filter_by_cip(midfielddegrees,
#                             keep_cip = group_codes,
#                             keep_col = c("id", "cip6"),
#                             unique_row = TRUE,
#                             first_degree = TRUE)
#  race_sex <- filter_by_id(midfieldstudents,
#                           keep_id = graduates$id,
#                           keep_col = c("id", "race", "sex"),
#                           unique_row = TRUE)
#  graduates <- merge(graduates, race_sex, by = "id", all.x = TRUE)
#  graduates <- merge(graduates, program_group, by = "cip6", all.x = TRUE)
#  
#  # group, summarize, and join
#  grouping_variables <- c("program", "race", "sex")
#  grouped_enrollees <- enrollees[, .(ever = .N), by = grouping_variables]
#  grouped_graduates <- graduates[, .(grad = .N), by = grouping_variables]
#  grouped_data <- merge(grouped_enrollees,
#                        grouped_graduates,
#                        by = grouping_variables,
#                        all.x = TRUE)
#  
#  # compute the metric
#  stickiness <- grouped_data
#  rows_with_degree_NA <- is.na(stickiness$grad)
#  stickiness[rows_with_degree_NA, grad := 0]
#  rows_we_want <- stickiness$ever > 0
#  stickiness <- stickiness[rows_we_want]
#  stickiness[, stick := round(grad / ever, 2)]
#  
#  # condition the data in multiway form (built-in data set)
#  data_mw <- exa_stickiness_mw
#  
#  # graph results
#  ggplot(data = data_mw, mapping = aes(x = stick, y = race_sex)) +
#    facet_wrap(facets = vars(program), ncol = 1, as.table = FALSE) +
#    geom_point(na.rm = TRUE) +
#    labs(x = "Stickiness", y = "")

