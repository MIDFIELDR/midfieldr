## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(fig.path = "../man/figures/vignette-get-started-")
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

## -----------------------------------------------------------------------------
# packages used
library(midfieldr)
library(midfielddata)
library(data.table)
library(ggplot2)

# print max 20 rows, otherwise 10 rows each head/tail
options(datatable.print.nrows = 20, datatable.print.topn = 10)

## -----------------------------------------------------------------------------
# engineering
engineering <- filter_by_text(cip, keep_text = "^14", keep_col = "cip6")

# add program label
engineering[, program := "Engineering"]

# examine the result
engineering

## -----------------------------------------------------------------------------
# business
business <- filter_by_text(cip, keep_text = "^52", keep_col = "cip6")

# add program label
business[, program := "Business"]

# bind the two data frames
program_group <- rbind(engineering, business)

# examine the result
program_group

## -----------------------------------------------------------------------------
# extract a vector of 6-digit CIP codes
group_cip <- program_group$cip6

# examine the result
str(group_cip)

## -----------------------------------------------------------------------------
# extract students ever enrolled
enrollees <- filter_by_cip(midfieldterms,
  keep_cip = group_cip,
  keep_col = c("id", "cip6"),
  unique_row = TRUE
)

# examine the result
enrollees

## -----------------------------------------------------------------------------
# apply the feasible completion filter
feasible_ids <- feasible_subset(enrollees$id)

# subset the enrollees
rows_we_want <- enrollees$id %in% feasible_ids
enrollees <- enrollees[rows_we_want]

# examine the result
enrollees

## -----------------------------------------------------------------------------
race_sex <- filter_by_id(midfieldstudents,
  keep_id = feasible_ids,
  keep_col = c("id", "race", "sex"),
  unique_row = TRUE
)

# examine the result
race_sex

## -----------------------------------------------------------------------------
# left-join demographics to enrollees
enrollees <- merge(enrollees, race_sex, by = "id", all.x = TRUE)

# left-join program_group to enrollees
enrollees <- merge(enrollees, program_group, by = "cip6", all.x = TRUE)

# examine the result
enrollees

## -----------------------------------------------------------------------------
# assign
grouping_variables <- c("program", "race", "sex")

# aggregate using data.table syntax
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

# order rows for viewing
pre_mw <- pre_mw[order(program, race, sex)]

# examine the result
pre_mw

## -----------------------------------------------------------------------------
# create a new category
pre_mw[, race_sex := paste(race, sex, sep = " ")]

# examine the result
pre_mw

## -----------------------------------------------------------------------------
# select the three multiway variables
columns_we_want <- c("program", "race_sex", "ever")
pre_mw <- pre_mw[, ..columns_we_want]

# examine the result
pre_mw

## -----------------------------------------------------------------------------
# order the category levels
data_mw <- order_multiway(pre_mw)

## -----------------------------------------------------------------------------
lapply(data_mw, FUN = attributes)

## ----fig1, fig.asp = 0.8------------------------------------------------------
ggplot(data = data_mw, mapping = aes(x = ever, y = race_sex)) +
  facet_wrap(facets = vars(program), ncol = 1, as.table = FALSE) +
  geom_point(na.rm = TRUE) +
  scale_x_continuous(
    trans = "log2",
    breaks = 2^seq(4, 14),
    limits = 2^c(4, 14)
  ) +
  theme(panel.grid.minor.x = element_blank()) +
  labs(
    x = "Number of students (log-2 scale)",
    y = "",
    title = "Ever enrolled",
    caption = "Source: midfielddata"
  )

## ----eval=FALSE---------------------------------------------------------------
#  # packages used
#  library(midfieldr)
#  library(midfielddata)
#  library(data.table)
#  library(ggplot2)
#  
#  # gather the programs
#  engineering_cip <- filter_by_text(cip, keep_text = "^14", keep_col = "cip6")
#  engineering <- engineering_cip[, program := "Engineering"]
#  business_cip <- filter_by_text(cip, keep_text = "^52", keep_col = "cip6")
#  business <- business_cip[, program := "Business"]
#  program_group <- rbind(engineering, business)
#  
#  # extract a vector of 6-digit CIP codes
#  group_cip <- program_group$cip6
#  
#  # gather students ever enrolled with feasible program completion
#  enrollees <- filter_by_cip(midfieldterms,
#    keep_cip = group_cip,
#    keep_col = c("id", "cip6"),
#    uniqueRow = TRUE
#  )
#  feasible_ids <- feasible_subset(enrollees$id)
#  rows_we_want <- enrollees$id %in% feasible_ids
#  enrollees <- enrollees[rows_we_want]
#  race_sex <- filter_by_id(midfieldstudents,
#    keep_id = feasible_ids,
#    keep_col = c("id", "race", "sex"),
#    uniqueRow = TRUE
#  )
#  enrollees <- merge(enrollees, race_sex, by = "id", all.x = TRUE)
#  enrollees <- merge(enrollees, program_group, by = "cip6", all.x = TRUE)
#  
#  # group and summarize
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
#    scale_x_continuous(
#      trans = "log2",
#      breaks = 2^seq(4, 14),
#      limits = 2^c(4, 14)
#    ) +
#    theme(panel.grid.minor.x = element_blank()) +
#    labs(
#      x = "Number of students (log-2 scale)",
#      y = "",
#      title = "Ever enrolled",
#      caption = "Source: midfielddata"
#    )

