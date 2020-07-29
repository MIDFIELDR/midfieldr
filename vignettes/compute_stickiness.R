## ----setup, include = FALSE---------------------------------------------------
source("vignette-knitr-opts.R")
knitr::opts_chunk$set(fig.path = "../man/figures/vignette-compute-stickiness-")

## -----------------------------------------------------------------------------
# packages used
library(midfieldr)
library(midfielddata)
library(data.table)
library(ggplot2)

# data.table, print max 20 rows, otherwise 5 rows head/tail
options(datatable.print.nrows = 20, datatable.print.topn = 5)

## -----------------------------------------------------------------------------
# view the example program group
program_group <- exa_group
program_group

## -----------------------------------------------------------------------------
# extract a vector of 6-digit CIP codes
group_codes <- program_group$cip6

# examine the result
group_codes

## -----------------------------------------------------------------------------
# students ever enrolled in programs
enrollees <- get_enrollees(midfieldterms, codes = group_codes)

# examine the result
enrollees

## -----------------------------------------------------------------------------
# apply the feasible completion filter
feasible_ids <- completion_feasible(id = enrollees$id)

## -----------------------------------------------------------------------------
# subset the enrollees
rows_we_want <- enrollees$id %in% feasible_ids
enrollees <- enrollees[rows_we_want]

# examine the result
enrollees

## -----------------------------------------------------------------------------
# obtain race/ethnicity and sex at matriculation
demographics <- get_race_sex(midfieldstudents, keep_id = feasible_ids)

# examine the result
demographics

## -----------------------------------------------------------------------------
# left-join demographics to enrollees
enrollees <- merge(enrollees, demographics, by = "id", all.x = TRUE)

# examine the result
enrollees

## -----------------------------------------------------------------------------
# left-join program_group to enrollees
enrollees <- merge(enrollees, program_group, by = "cip6", all.x = TRUE)

# examine the result
enrollees

## -----------------------------------------------------------------------------
# students graduating from programs
graduates <- get_graduates(midfielddegrees, codes = group_codes)
ids_we_want <- graduates$id
demographics <- get_race_sex(midfieldstudents, keep_id = ids_we_want)
graduates <- merge(graduates, demographics, by = "id", all.x = TRUE)
graduates <- merge(graduates, program_group, by = "cip6", all.x = TRUE)

# examine the result
graduates

## -----------------------------------------------------------------------------
# assign variables to aggregate by
grouping_variables <- c("program", "race", "sex")

## -----------------------------------------------------------------------------
# aggregation
grouped_enrollees <- enrollees[, .(ever = .N), by = grouping_variables]

# examine the result
grouped_enrollees

## -----------------------------------------------------------------------------
# aggregation
grouped_graduates <- graduates[, .(grad = .N), by = grouping_variables]

# examine the result
grouped_graduates

## -----------------------------------------------------------------------------
# left-join graduates to enrollees
stickiness <- merge(grouped_enrollees,
  grouped_graduates,
  by = grouping_variables,
  all.x = TRUE
)

# examine the result, ordered by program
stickiness[order(program)]

## -----------------------------------------------------------------------------
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
stickiness[, stick := round(grad / ever, 3)]

# examine the result
stickiness

## -----------------------------------------------------------------------------
# name and class of variables (columns)
sapply(stickiness, FUN = class)

## -----------------------------------------------------------------------------
# view the example CIP
data_mw <- exa_stickiness_mw
data_mw

## -----------------------------------------------------------------------------
# name and class of variables (columns)
sapply(data_mw, FUN = class)

## -----------------------------------------------------------------------------
# levels of the program category
levels(data_mw$program)

# levels of the race/ethnicity/sex category
levels(data_mw$race_sex)

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
#  # TBD

