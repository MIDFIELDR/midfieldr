## ----include = FALSE----------------------------------------------------------
knitr::opts_knit$set(root.dir = "../")
knitr::opts_chunk$set(
  fig.path = "../man/figures/vignette-graduation-rate-"
  )
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

## ----echo = FALSE-------------------------------------------------------------
load("inst/extdata/ipeds-vignette-data.rda")

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
# gather students matriculating in programs
cols_we_want <- c("id", "cip6")
rows_we_want <- midfieldstudents$cip6 %in% group_cip
matriculants <- midfieldstudents[rows_we_want, ..cols_we_want]
matriculants <- unique(matriculants)

# examine the result
matriculants

## -----------------------------------------------------------------------------
# gather FYE students predicted to start in these programs
cols_we_want <- c("id", "start")
rows_we_want <- fye_start$start %in% group_cip
fye_starters <- fye_start[rows_we_want, ..cols_we_want]
fye_starters <- unique(fye_starters)
setnames(fye_starters, old = "start", new = "cip6")

# examine the result
fye_starters

## -----------------------------------------------------------------------------
starters <- rbind(matriculants, fye_starters)

# examine the result
starters

## -----------------------------------------------------------------------------
# apply the feasible completion filter
feasible_ids <- subset_feasible(id = starters$id)

# examine the result
str(feasible_ids)

## -----------------------------------------------------------------------------
# subset the starters
rows_we_want <- starters$id %in% feasible_ids
starters <- starters[rows_we_want]

# examine the result
starters

## -----------------------------------------------------------------------------
# subset_ipeds() requires a CIP `start` column
setnames(starters, old = "cip6", new = "start")
ipeds_students <- subset_ipeds(starters)
ipeds_students[]

## ----echo = FALSE-------------------------------------------------------------
x <- (nrow(starters) - nrow(ipeds_students)) / nrow(starters)
xpct <- round(100 * x, 0)

## -----------------------------------------------------------------------------
setnames(ipeds_students, old = "start", new = "cip6")

# join race sex
rows_we_want <- midfieldstudents$id %in% ipeds_students$id 
cols_we_want <- c("id", "race", "sex")
race_sex <- midfieldstudents[rows_we_want, ..cols_we_want]
race_sex <- unique(race_sex)
ipeds_students <- merge(ipeds_students, race_sex, by = "id", all.x = TRUE)

# join programs
ipeds_students <- merge(ipeds_students,
  program_group,
  by = "cip6",
  all.x = TRUE
)

# done with ID and CIP
ipeds_students[, id := NULL]
ipeds_students[, cip6 := NULL]

ipeds_students

## -----------------------------------------------------------------------------
# assign variables to aggregate by
grouping_variables <- c("program", "race", "sex")

# group and summarize
grouped_starters <- ipeds_students[, .(start = .N), by = grouping_variables]

# examine the result
grouped_starters

## -----------------------------------------------------------------------------
# group and summarize
rows_we_want <- ipeds_students$ipeds_grad == "Y"
grouped_graduates <- ipeds_students[rows_we_want,
  .(grad = .N),
  by = grouping_variables
]

# examine the result
grouped_graduates

## -----------------------------------------------------------------------------
grouped_data <- merge(grouped_starters,
  grouped_graduates,
  by = grouping_variables,
  all.x = TRUE
)

grouped_data

## -----------------------------------------------------------------------------
grad_rate <- grouped_data
rows_with_grad_NA <- is.na(grad_rate$grad)
grad_rate[rows_with_grad_NA, grad := 0]

grad_rate

## -----------------------------------------------------------------------------
# prevent division by zero
rows_we_want <- grad_rate$start > 0
grad_rate <- grad_rate[rows_we_want]

## -----------------------------------------------------------------------------
grad_rate[, rate := round(grad / start, 2)]

grad_rate

## -----------------------------------------------------------------------------
# name and class of variables (columns)
unlist(lapply(grad_rate, FUN = class))

## -----------------------------------------------------------------------------
# pre-multiway data frame
pre_mw <- copy(grad_rate)

# prepare rows
rows_we_want <- pre_mw$start >= 5
pre_mw <- pre_mw[rows_we_want]

rows_we_want <- !pre_mw$race %in% c(
  "Unknown",
  "International",
  "Other",
  "Native American"
)
pre_mw <- pre_mw[rows_we_want]

# complete the transformation to multiway form
data_mw <- copy(pre_mw)
data_mw[, race_sex := paste(race, sex, sep = " ")]
cols_we_want <- c("program", "race_sex", "rate")
data_mw <- data_mw[, ..cols_we_want]

# transform characters to factors ordered by median rate
data_mw <- prepare_multiway(data_mw)

## ----include = FALSE----------------------------------------------------------
asp_ratio <- asp_ratio_mw(data_mw, categories = c("program", "race_sex"))

## ----fig1, fig.asp = asp_ratio[1]---------------------------------------------
# graph results
ggplot(data = data_mw, mapping = aes(x = rate, y = race_sex)) +
  facet_wrap(facets = vars(program), ncol = 1, as.table = FALSE) +
  geom_point(na.rm = TRUE) +
  labs(x = "Graduation rate", y = "")

## ----echo = FALSE-------------------------------------------------------------
ipeds01[order(id)]
n_starters <- nrow(starters)
n_ipeds01 <- nrow(ipeds01)

## ----echo = FALSE-------------------------------------------------------------
ipeds02[order(id)]
n_ipeds02 <- nrow(ipeds02)

## ----echo = FALSE-------------------------------------------------------------
ipeds03[order(id)]
n_ipeds03 <- nrow(ipeds03)

## ----echo = FALSE-------------------------------------------------------------
ipeds04[order(id)]

## ----echo = FALSE-------------------------------------------------------------
ipeds06[order(id)]

## ----eval = FALSE-------------------------------------------------------------
#  # packages used
#  library(midfieldr)
#  library(midfielddata)
#  library(data.table)
#  library(ggplot2)
#  
#  # select programs (built-in data set)
#  program_group <- copy(rep_group)
#  group_cip <- program_group$cip6
#  
#  # gather students matriculating in programs
#  cols_we_want <- c("id", "cip6")
#  rows_we_want <- midfieldstudents$cip6 %in% group_cip
#  matriculants <- midfieldstudents[rows_we_want, ..cols_we_want]
#  matriculants <- unique(matriculants)
#  
#  # gather FYE students predicted to start in these programs
#  cols_we_want <- c("id", "start")
#  rows_we_want <- fye_start$start %in% group_cip
#  fye_starters <- fye_start[rows_we_want, ..cols_we_want]
#  fye_starters <- unique(fye_starters)
#  setnames(fye_starters, old = "start", new = "cip6")
#  starters <- rbind(matriculants, fye_starters)
#  
#  # apply the feasible completion filter
#  feasible_ids <- subset_feasible(starters$id)
#  rows_we_want <- starters$id %in% feasible_ids
#  starters <- starters[rows_we_want]
#  
#  # apply IPEDS constraints
#  setnames(starters, old = "cip6", new = "start")
#  ipeds_students <- subset_ipeds(starters)
#  setnames(ipeds_students, old = "start", new = "cip6")
#  
#  # join race sex
#  rows_we_want <- midfieldstudents$id %in% ipeds_students$id
#  cols_we_want <- c("id", "race", "sex")
#  race_sex <- midfieldstudents[rows_we_want, ..cols_we_want]
#  race_sex <- unique(race_sex)
#  ipeds_students <- merge(ipeds_students, race_sex, by = "id", all.x = TRUE)
#  
#  # join programs
#  ipeds_students <- merge(ipeds_students,
#    program_group,
#    by = "cip6",
#    all.x = TRUE
#  )
#  
#  # group, summarize, join
#  grouping_variables <- c("program", "race", "sex")
#  grouped_starters <- ipeds_students[, .(start = .N), by = grouping_variables]
#  rows_we_want <- ipeds_students$ipeds_grad == "Y"
#  grouped_graduates <- ipeds_students[rows_we_want,
#    .(grad = .N),
#    by = grouping_variables
#  ]
#  grouped_data <- merge(grouped_starters,
#    grouped_graduates,
#    by = grouping_variables,
#    all.x = TRUE
#  )
#  
#  # compute graduation rate
#  grad_rate <- grouped_data
#  rows_with_grad_NA <- is.na(grad_rate$grad)
#  grad_rate[rows_with_grad_NA, grad := 0]
#  rows_we_want <- grad_rate$start > 0
#  grad_rate <- grad_rate[rows_we_want]
#  grad_rate[, rate := round(grad / start, 2)]
#  
#  # condition data for display
#  pre_mw <- grad_rate
#  rows_we_want <- pre_mw$start >= 5
#  pre_mw <- pre_mw[rows_we_want]
#  rows_we_want <- !pre_mw$race %in% c(
#    "Unknown",
#    "International",
#    "Other",
#    "Native American"
#  )
#  pre_mw <- pre_mw[rows_we_want]
#  data_mw <- pre_mw
#  data_mw[, race_sex := paste(race, sex, sep = " ")]
#  cols_we_want <- c("program", "race_sex", "rate")
#  data_mw <- data_mw[, ..cols_we_want]
#  data_mw <- prepare_multiway(data_mw)
#  
#  # graph
#  ggplot(data = data_mw, mapping = aes(x = rate, y = race_sex)) +
#    facet_wrap(facets = vars(program), ncol = 1, as.table = FALSE) +
#    geom_point(na.rm = TRUE) +
#    labs(x = "Graduation rate", y = "")

