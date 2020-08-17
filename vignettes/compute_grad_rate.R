## ----include = FALSE----------------------------------------------------------
knitr::opts_knit$set(root.dir = "../")
knitr::opts_chunk$set(fig.path = "../man/figures/vignette-compute-grad-rate-")
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
group_cips <- program_group$cip6

# examine the result
group_cips

## -----------------------------------------------------------------------------
# gather students matriculating in programs
matriculants <- filter_by_cip(midfieldstudents,
                              keep_cip = group_cips, 
                              keep_col = c("id", "cip6"),
                              unique_row = TRUE)

# examine the result
matriculants

## -----------------------------------------------------------------------------
# column name cip6 is required 
fye <- copy(fye_start)
setnames(fye, old = "start", new = "cip6")

# gather FYE students predicted to start in these programs
fye_starters <- filter_by_cip(fye,
                              keep_cip = group_cips,
                              unique_row = TRUE)

# examine the result
fye_starters

## -----------------------------------------------------------------------------
starters <- rbind(matriculants, fye_starters)

# examine the result
starters

## -----------------------------------------------------------------------------
# apply the feasible completion filter
feasible_ids <- feasible_subset(id = starters$id)

# examine the result
str(feasible_ids)

## -----------------------------------------------------------------------------
# subset the starters
rows_we_want <- starters$id %in% feasible_ids
starters <- starters[rows_we_want]

# rename CIP 
setnames(starters, old = "cip6", new = "start")

# examine the result
starters

## -----------------------------------------------------------------------------
ipeds_students <- ipeds_subset(starters)
ipeds_students[]

## ----echo = FALSE-------------------------------------------------------------
x <- (nrow(starters) - nrow(ipeds_students)) / nrow(starters)
xpct <- round(100 * x, 0)

## -----------------------------------------------------------------------------
setnames(ipeds_students, old = "start", new = "cip6")
ipeds_students <- merge(ipeds_students, 
                        program_group, 
                        by = "cip6", 
                        all.x = TRUE)

# race sex
race_sex <- filter_by_id(midfieldstudents, 
                  keep_id = ipeds_students$id, 
                  keep_col = c("id", "race", "sex"))
ipeds_students <- merge(ipeds_students, race_sex, by = "id", all.x = TRUE)


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
                             by = grouping_variables]

# examine the result
grouped_graduates

## -----------------------------------------------------------------------------
grouped_data  <- merge(grouped_starters, 
                   grouped_graduates, 
                   by = grouping_variables, 
                   all.x = TRUE)

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

## ----echo = FALSE, eval = FALSE-----------------------------------------------
#  # run manually to create external data set
#  # external (user) data files
#  rep_grad_rate <- grad_rate
#  usethis::use_data(
#    rep_grad_rate,
#    internal  = FALSE,
#    overwrite = TRUE
#  )

## -----------------------------------------------------------------------------
# pre-multiway data frame
pre_mw <- copy(grad_rate)

# alternatively, use the built-in data set
# pre_mw <- copy(rep_grad_rate)

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
columns_we_want <- c("program", "race_sex", "rate")
data_mw <- data_mw[, ..columns_we_want]

# transform characters to factors ordered by median rate
data_mw <- order_multiway(data_mw)

## ----echo = FALSE, eval = FALSE-----------------------------------------------
#  # run manually to create external data set
#  # external (user) data files
#  rep_grad_rate_mw <- data_mw
#  usethis::use_data(
#    rep_grad_rate_mw,
#    internal  = FALSE,
#    overwrite = TRUE
#  )

## ----echo = FALSE-------------------------------------------------------------
nlevel1 <- nlevels(data_mw$program)
nlevel2 <- nlevels(data_mw$race_sex)
r <- nlevel1 * nlevel2
q <- 32
asp_ratio1 <- (r + 2 * nlevel1) / q
asp_ratio2 <- (r + 2 * nlevel2) / q

## ----fig1, fig.asp = asp_ratio1-----------------------------------------------
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
#  group_cips <- program_group$cip6
#  
#  # gather starters: matriculants and imputed FYE
#  matriculants <- filter_by_cip(midfieldstudents,
#                                keep_cip = group_cips,
#                                keep_col = c("id", "cip6"),
#                                unique_row = TRUE
#  )
#  fye <- copy(fye_start)
#  setnames(fye, old = "start", new = "cip6")
#  fye_starters <- filter_by_cip(fye,
#                                keep_cip = group_cips,
#                                unique_row = TRUE
#  )
#  starters <- rbind(matriculants, fye_starters)
#  
#  # apply the feasible completion filter
#  feasible_ids <- feasible_subset(starters$id)
#  rows_we_want <- starters$id %in% feasible_ids
#  starters <- starters[rows_we_want]
#  setnames(starters, old = "cip6", new = "start")
#  
#  # apply IPEDS constraints
#  ipeds_students <- ipeds_subset(starters)
#  
#  # join program labels and demographics
#  setnames(ipeds_students, old = "start", new = "cip6")
#  ipeds_students <- merge(ipeds_students,
#                          program_group,
#                          by = "cip6",
#                          all.x = TRUE)
#  race_sex <- filter_by_id(midfieldstudents,
#                           keep_id = ipeds_students$id,
#                           keep_col = c("id", "race", "sex"))
#  ipeds_students <- merge(ipeds_students, race_sex, by = "id", all.x = TRUE)
#  
#  # group, summarize, join
#  grouping_variables <- c("program", "race", "sex")
#  grouped_starters <- ipeds_students[, .(start = .N), by = grouping_variables]
#  rows_we_want <- ipeds_students$ipeds_grad == "Y"
#  grouped_graduates <- ipeds_students[rows_we_want,
#                                      .(grad = .N),
#                                      by = grouping_variables]
#  grouped_data  <- merge(grouped_starters,
#                         grouped_graduates,
#                         by = grouping_variables,
#                         all.x = TRUE)
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
#  columns_we_want <- c("program", "race_sex", "rate")
#  data_mw <- data_mw[, ..columns_we_want]
#  data_mw <- order_multiway(data_mw)
#  
#  # graph
#  ggplot(data = data_mw, mapping = aes(x = rate, y = race_sex)) +
#    facet_wrap(facets = vars(program), ncol = 1, as.table = FALSE) +
#    geom_point(na.rm = TRUE) +
#    labs(x = "Graduation rate", y = "")

