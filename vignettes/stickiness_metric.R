## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(fig.path = "../man/figures/vignette-stickiness-metric-")
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
asp_ratio_mw <- function(data, categories) {
  cat1 <- categories[1] # panels
  cat2 <- categories[2] # rows
  nlevel1 <- nlevels(data[, get(cat1)])
  nlevel2 <- nlevels(data[, get(cat2)])
  r <- nlevel1 * nlevel2
  q <- 32
  asp_ratio1 <- (r + 2 * nlevel1) / q
  asp_ratio2 <- (r + 2 * nlevel2) / q
  ratios <- c(asp_ratio1, asp_ratio2)
}

## -----------------------------------------------------------------------------
# packages used
library(midfieldr)
library(midfielddata)
library(data.table)
library(ggplot2)

# print max 20 rows, otherwise 10 rows each head/tail
options(datatable.print.nrows = 20, datatable.print.topn = 10)

## -----------------------------------------------------------------------------
# obtain programs (built-in data set)
program_group <- copy(rep_group)

# examine the result
program_group

## -----------------------------------------------------------------------------
# extract a vector of 6-digit CIP codes
group_cip <- program_group$cip6

# examine the result
group_cip

## -----------------------------------------------------------------------------
# extract students ever enrolled
cols_we_want <- c("id", "cip6")
rows_we_want <- midfieldterms$cip6 %in% group_cip
enrollees <- midfieldterms[rows_we_want, ..cols_we_want]
enrollees <- unique(enrollees)

# examine the result
enrollees[order(id)]

## -----------------------------------------------------------------------------
# gather FYE students predicted to start in these programs
rows_we_want <- fye_start$start %in% group_cip
cols_we_want <- c("id", "start")
fye_starters <- fye_start[rows_we_want, ..cols_we_want]
fye_starters <- unique(fye_starters)
setnames(fye_starters, old = "start", new = "cip6")

# examine the result
fye_starters[order(id)]

## -----------------------------------------------------------------------------
enrollees <- rbind(enrollees, fye_starters)
enrollees <- unique(enrollees)

# examine the result
enrollees[order(id)]

## ----include = FALSE, eval = FALSE--------------------------------------------
#  # run this manually to save external data
#  rep_ever <- enrollees$id
#  usethis::use_data(
#    rep_ever,
#    internal  = FALSE,
#    overwrite = TRUE
#  )

## -----------------------------------------------------------------------------
# apply the feasible completion filter
feasible_ids <- subset_feasible(id = enrollees$id)

# examine the result
str(feasible_ids)

## -----------------------------------------------------------------------------
# subset the enrollees
rows_we_want <- enrollees$id %in% feasible_ids
enrollees <- enrollees[rows_we_want]

# examine the result
enrollees[order(id)]

## -----------------------------------------------------------------------------
# obtain race/ethnicity and sex at matriculation
rows_we_want <- midfieldstudents$id %in% feasible_ids
cols_we_want <- c("id", "race", "sex")
race_sex <- midfieldstudents[rows_we_want, ..cols_we_want]
race_sex <- unique(race_sex)

# examine the result
race_sex[order(id)]

## -----------------------------------------------------------------------------
# left-join demographics to enrollees
enrollees <- merge(enrollees, race_sex, by = "id", all.x = TRUE)

# examine the result
enrollees[order(id)]

## -----------------------------------------------------------------------------
# left-join program_group to enrollees
enrollees <- merge(enrollees, program_group, by = "cip6", all.x = TRUE)

# examine the result
enrollees[order(id)]

## -----------------------------------------------------------------------------
# extract graduates
cols_we_want <- c("id", "cip6", "term_degree")
rows_we_want <- midfielddegrees$cip6 %in% group_cip
graduates <- midfielddegrees[rows_we_want, ..cols_we_want]

# examine the result
graduates[order(id)]

## -----------------------------------------------------------------------------
# keep the first degree term if more than one
graduates <- graduates[, .SD[term_degree == min(term_degree)], by = id]

# examine the result
graduates[order(id)]

## -----------------------------------------------------------------------------
# finished with term_degree column 
graduates[, term_degree := NULL]

# join race sex
rows_we_want <- midfieldstudents$id %in% graduates$id 
cols_we_want <- c("id", "race", "sex")
race_sex <- midfieldstudents[rows_we_want, ..cols_we_want]
race_sex <- unique(race_sex)
graduates <- merge(graduates, race_sex, by = "id", all.x = TRUE)

# join program labels
graduates <- merge(graduates, program_group, by = "cip6", all.x = TRUE)

# examine the result
graduates[order(id)]

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
stickiness <- copy(grouped_data)

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
unlist(lapply(stickiness, FUN = class))

## ----include = FALSE, eval = FALSE--------------------------------------------
#  # run this manually to save external data
#  rep_stickiness <- copy(stickiness)
#  usethis::use_data(
#    rep_stickiness,
#    internal  = FALSE,
#    overwrite = TRUE
#  )

## -----------------------------------------------------------------------------
# condition the data in multiway form (built-in data set)
data_mw <- copy(rep_stickiness_mw)

# examine the result
data_mw

## -----------------------------------------------------------------------------
# name and class of variables (columns)
lapply(data_mw, FUN = attributes)

## ----include = FALSE----------------------------------------------------------
asp_ratio <- asp_ratio_mw(data_mw, categories = c("program", "race_sex"))

## ----fig1, fig.asp = asp_ratio[1]---------------------------------------------
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
#  program_group <- rep_group
#  group_cip <- program_group$cip6
#  
#  # gather students ever enrolled in programs
#  cols_we_want <- c("id", "cip6")
#  rows_we_want <- midfieldterms$cip6 %in% group_cip
#  enrollees <- midfieldterms[rows_we_want, ..cols_we_want]
#  enrollees <- unique(enrollees)
#  
#  # gather FYE students predicted to start in these programs
#  rows_we_want <- fye_start$start %in% group_cip
#  cols_we_want <- c("id", "start")
#  fye_starters <- fye_start[rows_we_want, ..cols_we_want]
#  fye_starters <- unique(fye_starters)
#  setnames(fye_starters, old = "start", new = "cip6")
#  enrollees <- rbind(enrollees, fye_starters)
#  enrollees <- unique(enrollees)
#  
#  # apply the feasible completion filter
#  feasible_ids <- subset_feasible(id = enrollees$id)
#  rows_we_want <- enrollees$id %in% feasible_ids
#  enrollees <- enrollees[rows_we_want]
#  
#  # obtain race/ethnicity and sex at matriculation
#  rows_we_want <- midfieldstudents$id %in% feasible_ids
#  cols_we_want <- c("id", "race", "sex")
#  race_sex <- midfieldstudents[rows_we_want, ..cols_we_want]
#  race_sex <- unique(race_sex)
#  
#  # join data frames
#  enrollees <- merge(enrollees, race_sex, by = "id", all.x = TRUE)
#  enrollees <- merge(enrollees, program_group, by = "cip6", all.x = TRUE)
#  
#  # gather students graduating from programs
#  cols_we_want <- c("id", "cip6", "term_degree")
#  rows_we_want <- midfielddegrees$cip6 %in% group_cip
#  graduates <- midfielddegrees[rows_we_want, ..cols_we_want]
#  graduates <- graduates[, .SD[term_degree == min(term_degree)], by = id]
#  
#  # join race/ethnicity, sex, and program labels
#  rows_we_want <- midfieldstudents$id %in% graduates$id
#  cols_we_want <- c("id", "race", "sex")
#  race_sex <- midfieldstudents[rows_we_want, ..cols_we_want]
#  race_sex <- unique(race_sex)
#  graduates <- merge(graduates, race_sex, by = "id", all.x = TRUE)
#  graduates <- merge(graduates, program_group, by = "cip6", all.x = TRUE)
#  
#  # group, summarize, and join
#  grouping_variables <- c("program", "race", "sex")
#  grouped_enrollees <- enrollees[, .(ever = .N), by = grouping_variables]
#  grouped_graduates <- graduates[, .(grad = .N), by = grouping_variables]
#  grouped_data <- merge(grouped_enrollees,
#    grouped_graduates,
#    by = grouping_variables,
#    all.x = TRUE
#  )
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
#  data_mw <- rep_stickiness_mw
#  
#  # graph results
#  ggplot(data = data_mw, mapping = aes(x = stick, y = race_sex)) +
#    facet_wrap(facets = vars(program), ncol = 1, as.table = FALSE) +
#    geom_point(na.rm = TRUE) +
#    labs(x = "Stickiness", y = "")

