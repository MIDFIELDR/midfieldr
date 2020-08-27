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
# engineering
engineering <- filter_text(cip, keep_text = "^14", keep_col = "cip6")

# add program label
engineering[, program := "Engineering"]

# examine the result
engineering[order(cip6)]

## -----------------------------------------------------------------------------
# business
business <- filter_text(cip, keep_text = "^52", keep_col = "cip6")

# add program label
business[, program := "Business"]

# examine the result
business[order(cip6)]

## -----------------------------------------------------------------------------
# bind the two data frames
program_group <- rbind(engineering, business)

# examine the result
program_group[order(cip6)]

## -----------------------------------------------------------------------------
# extract a vector of 6-digit CIP codes
group_cip <- program_group$cip6

# examine the result
str(group_cip)

## -----------------------------------------------------------------------------
# extract students ever enrolled from terms data 
cols_we_want <- c("id", "cip6")
rows_we_want <- midfieldterms$cip6 %in% group_cip
enrollees <- midfieldterms[rows_we_want, ..cols_we_want]
enrollees <- unique(enrollees)

# examine the result
enrollees[order(id)]

## -----------------------------------------------------------------------------
# extract students from matriculant data 
rows_we_want <- midfieldstudents$cip6 %in% group_cip
matriculants <- midfieldstudents[rows_we_want, ..cols_we_want]

## -----------------------------------------------------------------------------
# combine findings
enrollees <- rbind(enrollees, matriculants)
enrollees <- unique(enrollees)
                    
# examine the result
enrollees[order(id)]

## -----------------------------------------------------------------------------
# apply the feasible completion filter
feasible_ids <- subset_feasible(enrollees$id)

# subset the enrollees
rows_we_want <- enrollees$id %in% feasible_ids
enrollees <- enrollees[rows_we_want]

# examine the result
enrollees[order(id)]

## -----------------------------------------------------------------------------
rows_we_want <- midfieldstudents$id %in% feasible_ids
cols_we_want <- c("id", "race", "sex")
race_sex <- midfieldstudents[rows_we_want, ..cols_we_want]
race_sex <- unique(race_sex)

# examine the result
race_sex[order(id)]

## -----------------------------------------------------------------------------
# left-join demographics to enrollees
enrollees <- merge(enrollees, race_sex, by = "id", all.x = TRUE)

# left-join program_group to enrollees
enrollees <- merge(enrollees, program_group, by = "cip6", all.x = TRUE)

# examine the result
enrollees[order(id)]

## -----------------------------------------------------------------------------
# remove the CIP codes
enrollees[, cip6 := NULL]

# remove duplicates
enrollees <- unique(enrollees)

# examine the result
enrollees[order(id)]

## -----------------------------------------------------------------------------
# assign
grouping_variables <- c("program", "race", "sex")

# aggregate using data.table syntax
grouped_enrollees <- enrollees[, .(ever = .N), by = grouping_variables]

# examine the result
grouped_enrollees

## -----------------------------------------------------------------------------
# initialize the pre-multiway data frame
pre_mw <- copy(grouped_enrollees)

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
cols_we_want <- c("program", "race_sex", "ever")
pre_mw <- pre_mw[, ..cols_we_want]

# examine the result
pre_mw

## -----------------------------------------------------------------------------
# order the category levels
data_mw <- prepare_multiway(pre_mw)

## -----------------------------------------------------------------------------
lapply(data_mw, FUN = attributes)

## ----include = FALSE----------------------------------------------------------
asp_ratio <- asp_ratio_mw(data_mw, categories = c("program", "race_sex"))

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
    title = "Ever enrolled in the program",
    caption = "Source: midfielddata"
  )

## ----eval=FALSE---------------------------------------------------------------
#  # packages used
#  library(midfieldr)
#  library(midfielddata)
#  library(data.table)
#  library(ggplot2)
#  
#  # gather programs
#  engineering   <- filter_text(cip, keep_text = "^14", keep_col = "cip6")
#  engineering[, program := "Engineering"]
#  business      <- filter_text(cip, keep_text = "^52", keep_col = "cip6")
#  business      <- business[, program := "Business"]
#  program_group <- rbind(engineering, business)
#  group_cip     <- program_group$cip6
#  
#  # gather students
#  cols_we_want <- c("id", "cip6")
#  rows_we_want <- midfieldterms$cip6 %in% group_cip
#  enrollees    <- midfieldterms[rows_we_want, ..cols_we_want]
#  rows_we_want <- midfieldstudents$cip6 %in% group_cip
#  matriculants <- midfieldstudents[rows_we_want, ..cols_we_want]
#  enrollees    <- rbind(enrollees, matriculants)
#  enrollees    <- unique(enrollees)
#  
#  # apply feasible completion
#  feasible_ids <- subset_feasible(enrollees$id)
#  rows_we_want <- enrollees$id %in% feasible_ids
#  enrollees    <- enrollees[rows_we_want]
#  
#  # join grouping variables
#  rows_we_want <- midfieldstudents$id %in% feasible_ids
#  cols_we_want <- c("id", "race", "sex")
#  race_sex     <- midfieldstudents[rows_we_want, ..cols_we_want]
#  enrollees    <- merge(enrollees, race_sex, by = "id", all.x = TRUE)
#  enrollees    <- merge(enrollees, program_group, by = "cip6", all.x = TRUE)
#  enrollees[, cip6 := NULL]
#  enrollees    <- unique(enrollees)
#  
#  # group and summarize
#  grouping_variables <- c("program", "race", "sex")
#  grouped_enrollees  <- enrollees[, .(ever = .N), by = grouping_variables]
#  
#  # condition the data for display
#  pre_mw       <- grouped_enrollees
#  rows_we_want <- !pre_mw$race %in% c("Unknown", "International", "Other")
#  pre_mw       <- pre_mw[rows_we_want]
#  rows_we_want <- pre_mw$ever > 10
#  pre_mw       <- pre_mw[rows_we_want]
#  pre_mw[, race_sex := paste(race, sex, sep = " ")]
#  cols_we_want <- c("program", "race_sex", "ever")
#  pre_mw       <- pre_mw[, ..cols_we_want]
#  data_mw      <- prepare_multiway(pre_mw)
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
#      title = "Ever enrolled in the program",
#      caption = "Source: midfielddata"
#    )

