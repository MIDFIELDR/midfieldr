## ----setup, include = FALSE---------------------------------------------------
# code chunks
knitr::opts_chunk$set(
  echo = TRUE,
  message = FALSE,
  warning = FALSE,
  collapse = FALSE,
  comment = "#>",
  error = FALSE
)

# figures
knitr::opts_chunk$set(
  fig.path = "../man/figures/art-003-case-results-",
  fig.width = 6,
  fig.asp = 1 / 1.6,
  out.width = "70%",
  fig.align = "center"
)

# inline numbers
knitr::knit_hooks$set(inline = function(x) {
  if (!is.numeric(x)) {
    x
  } else if (x >= 10000) {
    prettyNum(round(x, 2), big.mark = ",")
  } else {
    prettyNum(round(x, 2))
  }
})

## -----------------------------------------------------------------------------
# Packages
library("midfieldr")
suppressPackageStartupMessages(library("data.table"))
suppressPackageStartupMessages(library("ggplot2"))

# Printing options for data.table
options(
  datatable.print.nrows = 15,
  datatable.print.topn = 5,
  datatable.print.class = TRUE
)

## -----------------------------------------------------------------------------
# Copy the case study observations
DT <- copy(study_observations)
DT[]

## -----------------------------------------------------------------------------
# Group and summarize
DT <- DT[, .N, by = c("group", "program", "race", "sex")]
DT[]

## -----------------------------------------------------------------------------
# Transform to row-record form
DT <- dcast(DT, program + sex + race ~ group, value.var = "N", fill = 0)
DT[]

## -----------------------------------------------------------------------------
DT[, stick := round(100 * grad / ever, 1)]
DT[]

## -----------------------------------------------------------------------------
# Preserve anonymity
DT <- DT[grad >= 10]
DT[]

## -----------------------------------------------------------------------------
# Filter by study design
DT <- DT[!race %chin% c("International", "Other/Unknown")]
DT[]

## -----------------------------------------------------------------------------
DT[, race_sex := paste(race, sex)]
DT[, c("race", "sex") := NULL]
setcolorder(DT, c("program", "race_sex"))
DT[]

## -----------------------------------------------------------------------------
DT[, program := fcase(
  program %like% "CE", "Civil Engineering",
  program %like% "EE", "Electrical Engineering",
  program %like% "ME", "Mechanical Engineering",
  program %like% "ISE", "Industrial/Systems Engineering"
)]
DT[]

## -----------------------------------------------------------------------------
# Convert categorical variables to factors
DT <- condition_multiway(DT,
  x = "stick",
  yy = c("program", "race_sex"),
  order_by = "percent",
  param_col = c("grad", "ever")
)
DT[]

## -----------------------------------------------------------------------------
ggplot(DT, aes(x = stick, y = program)) +
  facet_wrap(vars(race_sex), ncol = 1, as.table = FALSE) +
  geom_point() +
  labs(x = "Stickiness (%)", y = "")

## -----------------------------------------------------------------------------
ggplot(DT, aes(x = stick, y = race_sex)) +
  facet_wrap(vars(program), ncol = 1, as.table = FALSE) +
  geom_point() +
  labs(x = "Stickiness (%)", y = "")

## -----------------------------------------------------------------------------
# Select the columns I want for the table
tbl <- DT[, .(program, race_sex, grad, ever, stick)]

# Shorten the names that will appear in the header row
tbl[, program := fcase(
  program %like% "Civil Engineering", "Civil",
  program %like% "Electrical Engineering", "Electrical",
  program %like% "Mechanical Engineering", "Mechanical",
  program %like% "Industrial/Systems Engineering", "Industrial/Sys"
)]

# Combine three columns into one character column
tbl[, results := paste0("(", grad, "/", ever, ") ", format(stick, nsmall = 1))]

# Transform from block records to row records
tbl <- dcast(tbl, race_sex ~ program, value.var = "results")

# Change factor to character so the rows can b alphabetized
tbl[, race_sex := as.character(race_sex)]
tbl <- tbl[order(race_sex)]

# Edit one column header
setnames(tbl, old = "race_sex", new = "Group", skip_absent = TRUE)

## -----------------------------------------------------------------------------
tbl |>
  kableExtra::kbl(align = "lrrrr") |>
  kableExtra::kable_paper(lightable_options = "basic", full_width = TRUE) |>
  kableExtra::row_spec(0, background = "#c7eae5") |>
  # kableExtra::column_spec(1, monospace = TRUE) |>
  kableExtra::column_spec(1:5, color = "black", background = "white")

## -----------------------------------------------------------------------------
#  # Packages
#  library("midfieldr")
#  suppressPackageStartupMessages(library("data.table"))
#  suppressPackageStartupMessages(library("ggplot2"))
#  
#  # Printing options for data.table
#  options(
#    datatable.print.nrows = 15,
#    datatable.print.topn = 5,
#    datatable.print.class = TRUE
#  )
#  
#  # Copy the case study observations
#  DT <- copy(study_observations)
#  
#  # Group and summarize
#  DT <- DT[, .N, by = c("group", "program", "race", "sex")]
#  
#  # Compute the metric
#  DT <- dcast(DT, program + sex + race ~ group, value.var = "N", fill = 0)
#  DT[, stick := round(100 * grad / ever, 1)]
#  
#  # Prepare for dissemination
#  DT <- DT[grad >= 10]
#  DT <- DT[!race %chin% c("International", "Other/Unknown")]
#  DT[, race_sex := paste(race, sex)]
#  DT[, c("race", "sex") := NULL]
#  setcolorder(DT, c("program", "race_sex"))
#  DT[, program := fcase(
#    program %like% "CE", "Civil Engineering",
#    program %like% "EE", "Electrical Engineering",
#    program %like% "ME", "Mechanical Engineering",
#    program %like% "ISE", "Industrial/Systems Engineering"
#  )]
#  
#  # Convert categorical variables to factors
#  DT <- condition_multiway(DT,
#    x = "stick",
#    yy = c("program", "race_sex"),
#    order_by = "percent",
#    param_col = c("grad", "ever")
#  )
#  
#  # Chart 1
#  ggplot(DT, aes(x = stick, y = program)) +
#    facet_wrap(vars(race_sex), ncol = 1, as.table = FALSE) +
#    geom_point() +
#    labs(x = "Stickiness (%)", y = "")
#  
#  # Chart 2
#  ggplot(DT, aes(x = stick, y = race_sex)) +
#    facet_wrap(vars(program), ncol = 1, as.table = FALSE) +
#    geom_point() +
#    labs(x = "Stickiness (%)", y = "")
#  
#  # Table
#  tbl <- DT[, .(program, race_sex, grad, ever, stick)]
#  tbl[, program := fcase(
#    program %like% "Civil Engineering", "Civil",
#    program %like% "Electrical Engineering", "Electrical",
#    program %like% "Mechanical Engineering", "Mechanical",
#    program %like% "Industrial/Systems Engineering", "Industrial/Sys"
#  )]
#  tbl[, results := paste0("(", grad, "/", ever, ") ", format(stick, nsmall = 1))]
#  tbl <- dcast(tbl, race_sex ~ program, value.var = "results")
#  tbl[, race_sex := as.character(race_sex)]
#  tbl <- tbl[order(race_sex)]
#  setnames(tbl, old = "race_sex", new = "Group", skip_absent = TRUE)

