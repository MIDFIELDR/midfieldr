## ----setup, echo = FALSE------------------------------------------------------
knitr::opts_knit$set(root.dir = "../")
knitr::opts_chunk$set(
  echo = TRUE,
  error = TRUE, 
  message = FALSE,
  warning = FALSE,
  collapse = TRUE,
  comment = "#>",
  fig.width = 6,
  fig.asp = 1 / 1.6,
  out.width = "70%",
  fig.align = "center",
  fig.path = "../man/figures/vign-using-midfieldr-"
)

## -----------------------------------------------------------------------------
# packages used
library(midfieldr)
library(midfielddata)
library(data.table)
library(ggplot2)

# data.table printing options
options(datatable.print.nrows = 20, datatable.print.topn = 5)

## -----------------------------------------------------------------------------
# first pass
sub_cip <- get_cip(data = cip, keep_any = "engineering")

# examine the result
sub_cip

## -----------------------------------------------------------------------------
# second pass
sub_cip2 <- get_cip(
  data = sub_cip,
  keep_any = c("chemical", "electrical", "industrial"),
  drop_any = "technolog"
)

# examine the result at the 4-digit level
columns_we_want <- c("cip4", "cip4name")
unique(sub_cip2[, ..columns_we_want])

## -----------------------------------------------------------------------------
# get chemical engineering
che_cip <- get_cip(data = sub_cip2, keep_any = "^1407")
che <- label_programs(data = che_cip, label = "Chemical Engineering")

# view the result
che

## -----------------------------------------------------------------------------
# get electrical engineering
ece_cip <- get_cip(data = sub_cip2, keep_any = "^1410")
ece <- label_programs(data = ece_cip, label = "Electrical Engineering")

# get industrial engineering
ise_cip <- get_cip(data = sub_cip2, keep_any = "^1435")
ise <- label_programs(data = ise_cip, label = "Industrial Engineering")

## -----------------------------------------------------------------------------
# gather the programs in the study
program_group <- rbind(che, ece, ise)

# examine the result
program_group

## -----------------------------------------------------------------------------
# verbose column can be deleted
program_group$cip6name <- NULL

# examine the result
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
# assign variables to aggregate by
grouping_variables <- c("program", "race", "sex")

# aggregation using data.table syntax
grouped_enrollees <- enrollees[, .(ever = .N), by = grouping_variables]

# examine the result
grouped_enrollees

## -----------------------------------------------------------------------------
# students graduating from programs 
graduates    <- get_graduates(midfielddegrees, codes = group_codes)
ids_we_want  <- graduates$id
demographics <- get_race_sex(midfieldstudents, keep_id = ids_we_want)
graduates    <- merge(graduates, demographics, by = "id", all.x = TRUE)
graduates    <- merge(graduates, program_group, by = "cip6", all.x = TRUE)
grouped_graduates <- graduates[, .(grad = .N), by = grouping_variables]

# examine the result
grouped_graduates

## -----------------------------------------------------------------------------
# left-join graduates to enrollees
metric <- merge(grouped_enrollees, 
                grouped_graduates, 
                by = grouping_variables, 
                all.x = TRUE)

# examine the result, ordered by program
metric[order(program)]

## -----------------------------------------------------------------------------
rows_with_degree_NA <- is.na(metric$grad)
metric[rows_with_degree_NA]

## -----------------------------------------------------------------------------
# convert grad NA to zero
metric[rows_with_degree_NA, grad := 0]

# examine the result
metric[rows_with_degree_NA]

## -----------------------------------------------------------------------------
# prevent division by zero
rows_we_want <- metric$ever > 0
metric <- metric[rows_we_want]

# compute stickiness
metric[, stick := round(grad / ever, 3)]

# examine the result
metric

## -----------------------------------------------------------------------------
# initialize the pre-multiway data frame
pre_mw <- metric

# remove ambiguous levels of race/ethnicity
rows_we_want <- !pre_mw$race %in% c("Unknown", "International", "Other")
pre_mw <- pre_mw[rows_we_want]

# examine the result
unique(pre_mw$race)

## -----------------------------------------------------------------------------
# protect confidentiality of small populations
rows_we_want <- pre_mw$ever > 5
pre_mw <- pre_mw[rows_we_want]

# examine the result
pre_mw

## -----------------------------------------------------------------------------
# complete the transformation to multiway form
data_mw <- pre_mw

# create a new combined framing variable
data_mw[, race_sex := paste(race, sex, sep = " ")]

# examine the result
data_mw

## -----------------------------------------------------------------------------
# select the three multiway variables
columns_we_want <- c("program", "race_sex", "stick")
data_mw <- pre_mw[, ..columns_we_want]

# initialize the multiway data frame
data_mw <- order_multiway(data_mw)

## -----------------------------------------------------------------------------
sapply(data_mw, FUN = attributes)

## ----echo = FALSE-------------------------------------------------------------
x <- attributes(data_mw$program)
level_medians <- x$scores

low_median   <- round(min(level_medians), 2)
high_median  <- round(max(level_medians), 2)

low_level  <- levels(data_mw$program)[1]
high_level <- levels(data_mw$program)[nlevels(data_mw$program)]

## ----echo = FALSE-------------------------------------------------------------
x <- attributes(data_mw$race_sex)
level_medians <- x$scores

low_median   <- round(min(level_medians), 2)
high_median  <- round(max(level_medians), 2)

low_level  <- levels(data_mw$race_sex)[1]
high_level <- levels(data_mw$race_sex)[nlevels(data_mw$race_sex)]

## ----fig1, fig.asp = 1.8/1.6, echo = FALSE------------------------------------
# for annotation
rows_we_want <- data_mw$program %in% "Electrical Engineering" &
  data_mw$race_sex %in% "White Female"
pt1 <- data_mw[rows_we_want, , drop = FALSE]
rows_we_want <- data_mw$program %in% "Chemical Engineering" &
  data_mw$race_sex %in% "Asian Male"
pt2 <- data_mw[rows_we_want, , drop = FALSE]
rows_we_want <- data_mw$program %in% "Industrial Engineering" &
  data_mw$race_sex %in% "Hispanic Female"
pt3 <- data_mw[rows_we_want, , drop = FALSE]
df <- rbind(pt1, pt2, pt3)

ggplot(data_mw, aes(x = stick, y = race_sex)) +
  facet_wrap(facets = vars(program), ncol = 1, as.table = FALSE) +
  geom_point(na.rm = TRUE) +
  labs(x = "Stickiness", y = "") +
  geom_point(
    data = df,
    mapping = aes(x = stick, y = race_sex),
    color = "red",
    shape = 1,
    size = 4
  )

## ----eval=FALSE---------------------------------------------------------------
#  # packages used
#  library(midfieldr)
#  library(midfielddata)
#  library(data.table)
#  library(ggplot2)
#  
#  # gather the three programs
#  che_cip <- get_cip(cip, keep_any = "^1407")
#  che <- label_programs(che_cip, label = "Chemical Engineering")
#  ece_cip <- get_cip(cip, keep_any = "^1410")
#  ece <- label_programs(ece_cip, label = "Electrical Engineering")
#  ise_cip <- get_cip(cip, keep_any = "^1435")
#  ise <- label_programs(ise_cip, label = "Industrial Engineering")
#  program_group <- rbind(che, ece, ise)
#  program_group$cip6name <- NULL
#  
#  # extract a vector of 6-digit CIP codes
#  group_codes <- program_group$cip6
#  
#  # gather students ever enrolled with feasible program completion
#  enrollees    <- get_enrollees(midfieldterms, codes = group_codes)
#  feasible_ids <- completion_feasible(id = enrollees$id)
#  rows_we_want <- enrollees$id %in% feasible_ids
#  enrollees    <- enrollees[rows_we_want]
#  demographics <- get_race_sex(midfieldstudents, keep_id = feasible_ids)
#  enrollees    <- merge(enrollees, demographics, by = "id", all.x = TRUE)
#  enrollees    <- merge(enrollees, program_group, by = "cip6", all.x = TRUE)
#  
#  # assign variables to aggregate by
#  grouping_variables <- c("program", "race", "sex")
#  grouped_enrollees <- enrollees[, .(ever = .N), by = grouping_variables]
#  
#  # gather graduates from programs
#  graduates    <- get_graduates(midfielddegrees, codes = group_codes)
#  ids_we_want  <- graduates$id
#  demographics <- get_race_sex(midfieldstudents, keep_id = ids_we_want)
#  graduates    <- merge(graduates, demographics, by = "id", all.x = TRUE)
#  graduates    <- merge(graduates, program_group, by = "cip6", all.x = TRUE)
#  grouped_graduates <- graduates[, .(grad = .N), by = grouping_variables]
#  
#  # compute the metric
#  metric <- merge(grouped_enrollees,
#                  grouped_graduates,
#                  by = grouping_variables,
#                  all.x = TRUE)
#  rows_with_degree_NA <- is.na(metric$grad)
#  metric[rows_with_degree_NA, grad := 0]
#  rows_we_want <- metric$ever > 0
#  metric <- metric[rows_we_want]
#  metric[, stick := round(grad / ever, 3)]
#  
#  # condition the data
#  pre_mw <- metric
#  rows_we_want <- !pre_mw$race %in% c("Unknown", "International", "Other")
#  pre_mw <- pre_mw[rows_we_want]
#  rows_we_want <- pre_mw$ever > 5
#  pre_mw <- pre_mw[rows_we_want]
#  
#  # complete the transformation to multiway form
#  data_mw <- pre_mw
#  data_mw[, race_sex := paste(race, sex, sep = " ")]
#  data_mw <- pre_mw[, .(program, race_sex, stick)]
#  data_mw <- order_multiway(data_mw)
#  
#  # graph results
#  ggplot(data = data_mw, mapping = aes(x = stick, y = race_sex)) +
#    facet_wrap(facets = vars(program), ncol = 1, as.table = FALSE) +
#    geom_point(na.rm = TRUE) +
#    labs(x = "Stickiness", y = "")

