## ----setup--------------------------------------------------------------------
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
    fig.path = "../man/figures/art-020-programs-", 
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
library("midfieldr")
df <- filter_search(cip, "^41")
n41 <- nrow(df)
n4102 <- nrow(filter_search(df, "^4102"))
n4103 <- nrow(filter_search(df, "^4103"))
name41 <- unique(df[, cip2name])

df24 <- filter_search(cip, "^24")
n24 <- nrow(df24)
name24 <- unique(df24[, cip2name])

df51 <- filter_search(cip, "^51")
n51 <- nrow(df51)
name51 <- unique(df51[, cip2name])

df1313 <- filter_search(cip, "^1313")
n1313 <- nrow(df1313)
name1313 <- unique(df1313[, cip2name])

## -----------------------------------------------------------------------------
x <- filter_search(cip, "^41")
x[2:9, cip2name := "\U02193"]
x[c(4, 5, 7, 8), cip4name := "\U02193"]

x |>
    kableExtra::kbl(align = "rlrlrl") |>
    kableExtra::kable_paper(lightable_options = "basic", full_width = TRUE) |>
    kableExtra::row_spec(0, background = "#c7eae5") |>
    kableExtra::column_spec(1:6, color = "black", background = "white")

## -----------------------------------------------------------------------------
# Packages
library("midfieldr")
suppressPackageStartupMessages(library("data.table"))

# Printing options for data.table
options(
  datatable.print.nrows = 55,
  datatable.print.topn = 3,
  datatable.print.class = TRUE
)

## -----------------------------------------------------------------------------
# Names of the CIP variables
names(cip)

## -----------------------------------------------------------------------------
# View cip
cip

## -----------------------------------------------------------------------------
# 2-digit level
sort(unique(cip$cip2))

# 4-digit level
length(unique(cip$cip4))

# 6-digit level
length(unique(cip$cip6))

## -----------------------------------------------------------------------------
set.seed(20210613)

## -----------------------------------------------------------------------------
# 2-digit name sample
sample(cip[, cip2name], 10)

# 4-digit name sample
sample(cip[, cip4name], 10)

# 6-digit name sample
sample(cip[, cip6name], 10)

## -----------------------------------------------------------------------------
set.seed(NULL)

## -----------------------------------------------------------------------------
# Filter basics
filter_search(dframe = cip, keep_text = "engineering")

## -----------------------------------------------------------------------------
# Optional arguments drop_text and select
filter_search(cip, 
              "engineering", 
              drop_text = c("related", "technology", "technologies"), 
              select = c("cip6", "cip6name"))

## -----------------------------------------------------------------------------
filter_search(cip, "civil") |>
    kableExtra::kbl(align = "rlrlrl") |>
    kableExtra::kable_paper(lightable_options = "basic", full_width = TRUE) |>
    kableExtra::row_spec(0, background = "#c7eae5") |>
    kableExtra::column_spec(1:6, color = "black", background = "white")

## -----------------------------------------------------------------------------
# First search
first_pass <- filter_search(cip, "civil")

# Refine the search
second_pass <- filter_search(first_pass, "engineering")

# Refine further
third_pass <- filter_search(second_pass, drop_text = "technology")

## -----------------------------------------------------------------------------
third_pass |>
    kableExtra::kbl(align = "rlrlrl") |>
    kableExtra::kable_paper(lightable_options = "basic", full_width = TRUE) |>
    kableExtra::row_spec(0, background = "#c7eae5") |>
    kableExtra::column_spec(1:6, color = "black", background = "white")

## -----------------------------------------------------------------------------
filter_search(cip, "civil engineering", drop_text = "technology")

## -----------------------------------------------------------------------------
filter_search(cip, "german") |>
    kableExtra::kbl(align = "rlrlrl") |>
    kableExtra::kable_paper(lightable_options = "basic", full_width = TRUE) |>
    kableExtra::row_spec(0, background = "#c7eae5") |>
    kableExtra::column_spec(1:6, color = "black", background = "white")

## -----------------------------------------------------------------------------
filter_search(cip, c("050125", "160501")) |>
    kableExtra::kbl(align = "rlrlrl") |>
    kableExtra::kable_paper(lightable_options = "basic", full_width = TRUE) |>
    kableExtra::row_spec(0, background = "#c7eae5") |>
    kableExtra::column_spec(1:6, color = "black", background = "white")

## -----------------------------------------------------------------------------
# partial solution to exercise
pass01 <- filter_search(cip, "history")
pass02 <- filter_search(pass01, "^54")
cols_we_want <- c("cip6", "cip6name")
exercise_cip <- pass02[, ..cols_we_want]
exercise_cip

## -----------------------------------------------------------------------------
filter_search(cip, c("^1410", "^1419")) |>
    kableExtra::kbl(align = "rlrlrl") |>
    kableExtra::kable_paper(lightable_options = "basic", full_width = TRUE) |>
    kableExtra::row_spec(0, background = "#c7eae5") |>
    kableExtra::column_spec(1:6, color = "black", background = "white")

## -----------------------------------------------------------------------------
filter_search(cip, "^54") |>
    kableExtra::kbl(align = "rlrlrl") |>
    kableExtra::kable_paper(lightable_options = "basic", full_width = TRUE) |>
    kableExtra::row_spec(0, background = "#c7eae5") |>
    kableExtra::column_spec(1:6, color = "black", background = "white")

## -----------------------------------------------------------------------------
codes_we_want <- c("^24", "^4102", "^450202")
filter_search(cip, codes_we_want) |>
    kableExtra::kbl(align = "rlrlrl") |>
    kableExtra::kable_paper(lightable_options = "basic", full_width = TRUE) |>
    kableExtra::row_spec(0, background = "#c7eae5") |>
    kableExtra::column_spec(1:6, color = "black", background = "white")

## -----------------------------------------------------------------------------
# Unsuccessful terms produce a message
sub_cip <- filter_search(cip, c("050125", "111111", "160501", "Bogus", "^55"))

# But the successful terms are returned
sub_cip

## -----------------------------------------------------------------------------
# Name and class of variables (columns) in cip
unlist(lapply(cip, FUN = class))

## -----------------------------------------------------------------------------
# Changing the number of rows to print
options(datatable.print.nrows = 15)

# Four engineering programs
study_program <- filter_search(cip, c("^1408", "^1410", "^1419", "^1427", "^1435", "^1436", "^1437"))

# Retain the needed columns
study_program <- study_program[, .(cip6, cip4name)]

# Examine the result
study_program[]

## -----------------------------------------------------------------------------
# Assign a new column
study_program[, program := NA_character_]

# Examine the result
study_program[]

## -----------------------------------------------------------------------------
# Recode program using the 4-digit name
study_program[cip4name %ilike% "electrical",  program := "EE"]

# Examine the result
study_program[]

## -----------------------------------------------------------------------------
# Recode program using the 4-digit code
study_program[cip6 %like% "^1408",  program := "CE"]

# Examine the result
study_program[]

## -----------------------------------------------------------------------------
# Recode all program values
study_program[, program := fcase(
    cip6 %like% "^1408", "CE", 
    cip6 %like% "^1410", "EE", 
    cip6 %like% "^1419", "ME", 
    cip6 %chin% c("142701", "143501", "143601", "143701"), "ISE"
)]

# Examine the result
study_program[]

## -----------------------------------------------------------------------------
# Delete a column
study_program[, cip4name := NULL]

# Examine the result
study_program[]

## ----echo = FALSE-------------------------------------------------------------
# exercise solution
exercise_program <- copy(exercise_cip)
exercise_program[, program := cip6name]
exercise_program[
  cip6name %ilike% "General",
  program := "General History"
]
exercise_program[
  cip6name %ilike% "Other",
  program := "General History"
]
exercise_program[
  cip6name %ilike% "Philosophy",
  program := "Sci/Tech History"
]
exercise_program[
  cip6name %ilike% "Public",
  program := "Public/Applied History"
]
exercise_program[
  cip6name %ilike% "United States",
  program := "US History"
]
exercise_program[, cip6name := NULL]
exercise_program[]

