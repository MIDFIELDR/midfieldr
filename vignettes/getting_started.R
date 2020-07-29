## ----setup, include = FALSE---------------------------------------------------
source("vignette-knitr-opts.R")
knitr::opts_chunk$set(fig.path = "../man/figures/vignette-getting-started-")

## -----------------------------------------------------------------------------
# packages used
library(midfieldr)
library(midfielddata)
library(data.table)
library(ggplot2)

# data.table, print max 20 rows, otherwise 5 rows head/tail
options(datatable.print.nrows = 20, datatable.print.topn = 5)

## -----------------------------------------------------------------------------
# engineering 
engineering_cip <- get_cip(cip, keep_any = "^14")
engineering <- label_programs(engineering_cip, label = "Engineering")

# examine the result
engineering

## -----------------------------------------------------------------------------
# business 
business_cip <- get_cip(cip, keep_any = "^52")
business <- label_programs(business_cip, label = "Business")

# bind the two data frames
program_group <- rbind(engineering, business)

# examine the result
program_group

## -----------------------------------------------------------------------------
# verbose column can be deleted
program_group[, cip6name := NULL]

# examine the result
program_group

## -----------------------------------------------------------------------------
# extract a vector of 6-digit CIP codes
group_codes <- program_group$cip6

# examine the result
str(group_codes)

## -----------------------------------------------------------------------------
# extract students ever enrolled
enrollees <- get_enrollees(midfieldterms, codes = group_codes)

# examine the result
enrollees

## -----------------------------------------------------------------------------
# apply the feasible completion filter
feasible_ids <- completion_feasible(id = enrollees$id)

# subset the enrollees
rows_we_want <- enrollees$id %in% feasible_ids
enrollees <- enrollees[rows_we_want]

# examine the result
enrollees

## -----------------------------------------------------------------------------
# obtain student race/ethnicity and sex
demographics <- get_race_sex(midfieldstudents, keep_id = feasible_ids)

# examine the result
demographics

## -----------------------------------------------------------------------------
# left-join demographics to enrollees
enrollees <- merge(enrollees, demographics, by = "id", all.x = TRUE)

# left-join program_group to enrollees
enrollees <- merge(enrollees, program_group, by = "cip6", all.x = TRUE)

# examine the result
enrollees

## -----------------------------------------------------------------------------
# assign variables to aggregate by
grouping_variables <- c("program", "race", "sex")

# aggregation using data.table syntax
grouped_enrollees <- enrollees[, .(ever = .N), by = grouping_variables]

# examine the result
grouped_enrollees

## -----------------------------------------------------------------------------
# initialize the pre-multiway data frame
pre_mw <- grouped_enrollees

# remove ambiguous levels of race/ethnicity
rows_we_want <- !pre_mw$race %in% c("Unknown", "International", "Other")
pre_mw <- pre_mw[rows_we_want]

# examine the result
unique(pre_mw$race)

## -----------------------------------------------------------------------------
# protect confidentiality of small populations
rows_we_want <- pre_mw$ever > 10
pre_mw <- pre_mw[rows_we_want]

# examine the result
pre_mw[order(program, race, sex)]

## -----------------------------------------------------------------------------
# create a new category
pre_mw[, race_sex := paste(race, sex, sep = " ")]

# examine the result
pre_mw[order(program, race_sex)]

## -----------------------------------------------------------------------------
# select the three multiway variables
columns_we_want <- c("program", "race_sex", "ever")
pre_mw <- pre_mw[, ..columns_we_want]

# examine the result
pre_mw[order(program, race_sex)]

## -----------------------------------------------------------------------------
# order the category levels
data_mw <- order_multiway(pre_mw)

## -----------------------------------------------------------------------------
sapply(data_mw, FUN = attributes)

## ----fig1, fig.asp = 0.8------------------------------------------------------
ggplot(data = data_mw, mapping = aes(x = ever, y = race_sex)) +
  facet_wrap(facets = vars(program), ncol = 1, as.table = FALSE) +
  geom_point(na.rm = TRUE) +
  scale_x_continuous(trans = "log2", 
                     breaks = 2^seq(4, 14), 
                     limits = 2^c(4, 14)) +
  theme(panel.grid.minor.x = element_blank()) +
  labs(x = "Number of students (log-2 scale)", 
       y = "", 
       title = "Ever enrolled", 
       caption = "Source: midfielddata")

## ----eval=FALSE---------------------------------------------------------------
#  # packages used
#  library(midfieldr)
#  library(midfielddata)
#  library(data.table)
#  library(ggplot2)
#  
#  # gather the programs
#  engineering_cip <- get_cip(cip, keep_any = "^14")
#  engineering <- label_programs(engineering_cip, label = "Engineering")
#  business_cip <- get_cip(cip, keep_any = "^52")
#  business <- label_programs(business_cip, label = "Business")
#  program_group <- rbind(engineering, business)
#  program_group[, cip6name := NULL]
#  
#  # extract a vector of 6-digit CIP codes
#  group_codes <- program_group$cip6
#  
#  # gather students ever enrolled with feasible program completion
#  enrollees <- get_enrollees(midfieldterms, codes = group_codes)
#  feasible_ids <- completion_feasible(id = enrollees$id)
#  rows_we_want <- enrollees$id %in% feasible_ids
#  enrollees <- enrollees[rows_we_want]
#  demographics <- get_race_sex(midfieldstudents, keep_id = feasible_ids)
#  enrollees <- merge(enrollees, demographics, by = "id", all.x = TRUE)
#  enrollees <- merge(enrollees, program_group, by = "cip6", all.x = TRUE)
#  
#  # group and count
#  grouping_variables <- c("program", "race", "sex")
#  grouped_enrollees <- enrollees[, .(ever = .N), by = grouping_variables]
#  
#  # condition the data for display
#  pre_mw <- grouped_enrollees
#  rows_we_want <- !pre_mw$race %in% c("Unknown", "International", "Other")
#  pre_mw <- pre_mw[rows_we_want]
#  rows_we_want <- pre_mw$ever > 10
#  pre_mw <- pre_mw[rows_we_want]
#  pre_mw[, race_sex := paste(race, sex, sep = " ")]
#  columns_we_want <- c("program", "race_sex", "ever")
#  pre_mw <- pre_mw[, ..columns_we_want]
#  
#  # complete the transformation to multiway form
#  data_mw <- order_multiway(pre_mw)
#  
#  # graph results
#  ggplot(data = data_mw, mapping = aes(x = ever, y = race_sex)) +
#    facet_wrap(facets = vars(program), ncol = 1, as.table = FALSE) +
#    geom_point(na.rm = TRUE) +
#    scale_x_continuous(trans = "log2",
#                       breaks = 2^seq(4, 14),
#                       limits = 2^c(4, 14)) +
#    theme(panel.grid.minor.x = element_blank()) +
#    labs(x = "Number of students (log-2 scale)",
#         y = "",
#         title = "Ever enrolled",
#         caption = "Source: midfielddata")

