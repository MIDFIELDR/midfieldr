## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(fig.path = "../man/figures/vignette-multiway-graphs-")
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
library(data.table)
library(ggplot2)

# print max 20 rows, otherwise 10 rows each head/tail
options(datatable.print.nrows = 20, datatable.print.topn = 10)

## -----------------------------------------------------------------------------
# load stickiness data from case study
pre_mw <- copy(rep_stickiness)

# examine the result
pre_mw

## -----------------------------------------------------------------------------
# prepare rows
rows_we_want <- pre_mw$ever >= 5
pre_mw <- pre_mw[rows_we_want]

# examine the result
pre_mw

## -----------------------------------------------------------------------------
# remove rows of ambiguous or underrepresented populations
rows_we_want <- !pre_mw$race %in% c(
  "Unknown",
  "International",
  "Other",
  "Native American"
)
pre_mw <- pre_mw[rows_we_want]

# examine the result
unique(pre_mw$race)

## -----------------------------------------------------------------------------
# begin transformation to multiway form
data_mw <- copy(pre_mw)

# create a new combined framing variable
data_mw[, race_sex := paste(race, sex, sep = " ")]

# examine the result
data_mw

## -----------------------------------------------------------------------------
# select the multiway variables
cols_we_want <- c("program", "race_sex", "stick")
data_mw <- data_mw[, ..cols_we_want]

# examine the result
data_mw

## -----------------------------------------------------------------------------
# transform characters to factors ordered by median stickiness
data_mw <- prepare_multiway(data_mw)

# examine the result
data_mw

## ----include = FALSE, eval = FALSE--------------------------------------------
#  # run this manually to save external data
#  rep_stickiness_mw <- copy(data_mw)
#  usethis::use_data(
#    rep_stickiness_mw,
#    internal  = FALSE,
#    overwrite = TRUE
#  )

## ----include = FALSE----------------------------------------------------------
asp_ratio <- asp_ratio_mw(data_mw, categories = c("program", "race_sex"))

## ----fig1, fig.asp = asp_ratio[1]---------------------------------------------
# create one multiway graph
ggplot(data = data_mw, aes(x = stick, y = race_sex)) +
  facet_wrap(vars(program), ncol = 1, as.table = FALSE) +
  geom_point(na.rm = TRUE) +
  labs(x = "Stickiness", y = "")

## ----fig2, fig.asp = asp_ratio[2]---------------------------------------------
# create the dual multiway graph
ggplot(data = data_mw, aes(x = stick, y = program)) +
  facet_wrap(vars(race_sex), ncol = 1, as.table = FALSE) +
  geom_point(na.rm = TRUE) +
  labs(x = "Stickiness", y = "")

## ----results = "hide"---------------------------------------------------------
# tabulate data in block record ("long") form
blockf <- copy(data_mw)

# limit significant digits
blockf[, stick := round(stick, 2)]

# examine the result
blockf

## ----echo = FALSE-------------------------------------------------------------
kable2html(blockf, caption = "Table 1: Stickiness (block records)")

## ----echo = FALSE-------------------------------------------------------------
temp <- copy(blockf)
temp <- temp[, race_sex := as.character(race_sex)]
temp <- temp[, program := as.character(program)]
temp <- dcast(temp, race_sex ~ program, value.var = "stick")
names(temp) <- gsub("engineering", "", names(temp), ignore.case = TRUE)
names(temp) <- gsub("race_sex",
  "Race/ethnicity/sex",
  names(temp),
  ignore.case = TRUE
)
names(temp) <- gsub(" ", "", names(temp))
kable2html(temp, caption = "Table 2: Stickiness (row records)")

## -----------------------------------------------------------------------------
# convert factors to characters
temp <- copy(blockf)
temp <- temp[, race_sex := as.character(race_sex)]
temp <- temp[, program := as.character(program)]

## -----------------------------------------------------------------------------
# reshape
rowf <- dcast(temp, race_sex ~ program, value.var = "stick")

## -----------------------------------------------------------------------------
# shorten column names
names(rowf) <- gsub("engineering", "", names(rowf), ignore.case = TRUE)

# remove white space
names(rowf) <- gsub(" ", "", names(rowf))

# edit the first column name
names(rowf) <- gsub("race_sex",
  "Race/ethnicity/sex",
  names(rowf),
  ignore.case = TRUE
)

# examine the result
rowf

## ----eval=FALSE---------------------------------------------------------------
#  # packages used
#  library(midfieldr)
#  library(data.table)
#  library(ggplot2)
#  
#  # load stickiness data from case study
#  pre_mw <- copy(rep_stickiness)
#  
#  # prepare rows
#  rows_we_want <- pre_mw$ever >= 5
#  pre_mw <- pre_mw[rows_we_want]
#  
#  rows_we_want <- !pre_mw$race %in% c(
#    "Unknown",
#    "International",
#    "Other",
#    "Native American"
#  )
#  pre_mw <- pre_mw[rows_we_want]
#  
#  
#  # complete the transformation to multiway form
#  data_mw <- copy(pre_mw)
#  data_mw[, race_sex := paste(race, sex, sep = " ")]
#  cols_we_want <- c("program", "race_sex", "stick")
#  data_mw <- data_mw[, ..cols_we_want]
#  
#  # transform characters to factors ordered by median stickiness
#  data_mw <- prepare_multiway(data_mw)
#  
#  # create one multiway graph
#  ggplot(data = data_mw, aes(x = stick, y = race_sex)) +
#    facet_wrap(vars(program), ncol = 1, as.table = FALSE) +
#    geom_point(na.rm = TRUE) +
#    labs(x = "Stickiness", y = "")
#  
#  # create the dual multiway graph
#  ggplot(data = data_mw, aes(x = stick, y = program)) +
#    facet_wrap(vars(race_sex), ncol = 1, as.table = FALSE) +
#    geom_point(na.rm = TRUE) +
#    labs(x = "Stickiness", y = "")
#  
#  # tabulate data in block record ("long") form
#  blockf <- copy(data_mw)
#  blockf[, stick := round(stick, 2)]
#  blockf
#  
#  # tabulate data in row record ("wide") form
#  temp <- copy(blockf)
#  temp <- temp[, race_sex := as.character(race_sex)]
#  temp <- temp[, program := as.character(program)]
#  rowf <- dcast(temp, race_sex ~ program, value.var = "stick")
#  names(rowf) <- gsub("engineering", "", names(rowf), ignore.case = TRUE)
#  names(rowf) <- gsub(" ", "", names(rowf))
#  names(rowf) <- gsub("race_sex",
#    "Race/ethnicity/sex",
#    names(rowf),
#    ignore.case = TRUE
#  )

