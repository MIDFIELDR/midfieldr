## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(fig.path = here::here("man/figures", 
                                            "art-01-multiway-graphs-"))
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
library("midfieldr")
library("data.table")
library("ggplot2")

## -----------------------------------------------------------------------------
# optional code to control data.table printing
options(datatable.print.nrows = 10, 
        datatable.print.topn  = 5, 
        datatable.print.class = TRUE)

## -----------------------------------------------------------------------------
# examine the built-in data 
study_stickiness

## -----------------------------------------------------------------------------
# create a new memory location 
DT <- copy(study_stickiness)

## -----------------------------------------------------------------------------
# first category is a character
class(DT$program)

# second category is a character
class(DT$race_sex)

## -----------------------------------------------------------------------------
# condition as multiway data
DT <- condition_multiway(DT)

## -----------------------------------------------------------------------------
DT

## -----------------------------------------------------------------------------
# first category is now a factor
levels(DT$program)

# second category is now a factor
levels(DT$race_sex)

## -----------------------------------------------------------------------------
# return median stickiness by category
DT_med <- condition_multiway(DT, details = TRUE)

## -----------------------------------------------------------------------------
# optional code to control data.table printing
options(datatable.print.topn  = 10)

# programs have a median stickiness across race-sex groups  
DT_med[order(program)]

## -----------------------------------------------------------------------------
# race_sex groupings have a median stickiness across programs 
DT_med[order(race_sex)]

## ----include = FALSE----------------------------------------------------------
asp_ratio <- asp_ratio_mw(DT, categories = c("program", "race_sex"))

## ----fig1, fig.asp = asp_ratio[1]---------------------------------------------
# create one multiway graph
ggplot(data = DT_med, aes(x = stick, y = race_sex)) +
  facet_wrap(vars(program), ncol = 1, as.table = FALSE) +
  geom_vline(aes(xintercept = med_program), 
             linetype = 2, 
             color = "gray70") +
  geom_point(na.rm = TRUE) +
  labs(x = "Stickiness", 
       y = "", 
       title = "Practice data (not for research)", 
       caption = "Source: midfielddata")

## ----fig2, fig.asp = asp_ratio[2]---------------------------------------------
# create the dual multiway graph
ggplot(data = DT_med, aes(x = stick, y = program)) +
  facet_wrap(vars(race_sex), ncol = 1, as.table = FALSE) +
  geom_vline(aes(xintercept = med_race_sex), 
             linetype = 2, 
             color = "gray70") +
  geom_point(na.rm = TRUE) +
  labs(x = "Stickiness", 
       y = "", 
       title = "Practice data (not for research)", 
       caption = "Source: midfielddata")

## ----echo = FALSE-------------------------------------------------------------
temp <- copy(DT)
temp[, stick := round(stick, 2)]
kable2html(temp, caption = "Table 1: Stickiness (block records)")

## ----echo = FALSE-------------------------------------------------------------
temp[, race_sex := as.character(race_sex)]
temp[, program := as.character(program)]
temp <- dcast(temp, race_sex ~ program, value.var = "stick")
setnames(temp, 
         old = c("race_sex", 
                 "Civil Engineering", 
                 "Electrical Engineering", 
                 "Industrial Engineering", 
                 "Mechanical Engineering"), 
         new = c("Race/ethnicity/sex", 
                 "Civil", 
                 "Electrical", 
                 "Industrial", 
                 "Mechanical"))
kable2html(temp, caption = "Table 2: Stickiness (row records)")

## -----------------------------------------------------------------------------
# create a new memory location  
block_form <- copy(DT)

# limit significant digits
block_form[, stick := round(stick, 2)]

## -----------------------------------------------------------------------------
# create a new memory location 
row_form <- copy(block_form)

# convert factors to characters
row_form[, race_sex := as.character(race_sex)]
row_form[, program := as.character(program)]

## -----------------------------------------------------------------------------
# reshape
row_form <- dcast(row_form, race_sex ~ program, value.var = "stick")

# examine the result
row_form

## -----------------------------------------------------------------------------
# edit column names
setnames(row_form, 
         old = c("race_sex", 
                 "Civil Engineering", 
                 "Electrical Engineering", 
                 "Industrial Engineering", 
                 "Mechanical Engineering"), 
         new = c("Race/ethnicity/sex", 
                 "Civil", 
                 "Electrical", 
                 "Industrial", 
                 "Mechanical"))

# examine the result
row_form

## ----echo = FALSE-------------------------------------------------------------
kable2html(temp, caption = "Table 2: Stickiness (row records)")

## ----eval = FALSE-------------------------------------------------------------
#  # packages used
#  library("midfieldr")
#  library("data.table")
#  library("ggplot2")
#  
#  # optional code to control data.table printing
#  options(datatable.print.nrows = 10,
#          datatable.print.topn  = 5,
#          datatable.print.class = TRUE)
#  
#  # data preparation
#  DT <- copy(study_stickiness)
#  class(DT$program)
#  class(DT$race_sex)
#  DT <- condition_multiway(DT)
#  levels(DT$program)
#  levels(DT$race_sex)
#  DT_med <- condition_multiway(DT, details = TRUE)
#  DT_med[order(program)]
#  DT_med[order(race_sex)]
#  
#  # creating a multiway graph
#  ggplot(data = DT_med, aes(x = stick, y = race_sex)) +
#    facet_wrap(vars(program), ncol = 1, as.table = FALSE) +
#    geom_vline(aes(xintercept = med_program),
#               linetype = 2) +
#    geom_point(na.rm = TRUE) +
#    labs(x = "Stickiness",
#         y = "",
#         title = "Practice data (not for research)",
#         caption = "Source: midfielddata")
#  
#  # creating the dual multiway graph
#  ggplot(data = DT_med, aes(x = stick, y = program)) +
#    facet_wrap(vars(race_sex), ncol = 1, as.table = FALSE) +
#    geom_vline(aes(xintercept = med_race_sex),
#               linetype = 2) +
#    geom_point(na.rm = TRUE) +
#    labs(x = "Stickiness",
#         y = "",
#         title = "Practice data (not for research)",
#         caption = "Source: midfielddata")
#  
#  # creating a table for publication
#  block_form <- copy(DT)
#  block_form[, stick := round(stick, 2)]
#  row_form <- copy(block_form)
#  row_form[, race_sex := as.character(race_sex)]
#  row_form[, program := as.character(program)]
#  row_form <- dcast(row_form, race_sex ~ program, value.var = "stick")
#  setnames(row_form,
#           old = c("race_sex",
#                   "Civil Engineering",
#                   "Electrical Engineering",
#                   "Industrial Engineering",
#                   "Mechanical Engineering"),
#           new = c("Race/ethnicity/sex",
#                   "Civil",
#                   "Electrical",
#                   "Industrial",
#                   "Mechanical"))
#  

## ----echo = FALSE-------------------------------------------------------------
# to change the CSS file for block quotes
# per https://github.com/rstudio/rmarkdown/issues/732
knitr::opts_chunk$set(echo = FALSE)

