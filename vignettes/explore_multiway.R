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
  fig.path = "../man/figures/vign-explore-multiway-"
)

## -----------------------------------------------------------------------------
# packages
library(midfieldr)
library(ggplot2)

# data.table printing options
options(datatable.print.nrows = 20, datatable.print.topn = 5)

# load stickiness data from case study
pre_mw <- exa_stickiness

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
rows_we_want <- !pre_mw$race %in% c("Unknown", 
                                    "International", 
                                    "Other", 
                                    "Native American")
pre_mw <- pre_mw[rows_we_want]

# examine the result
unique(pre_mw$race)

## -----------------------------------------------------------------------------
# complete the transformation to multiway form
data_mw <- pre_mw

# create a new combined framing variable
data_mw[, race_sex := paste(race, sex, sep = " ")]

# examine the result
data_mw

## -----------------------------------------------------------------------------
# select the multiway variables
columns_we_want <- c("program", "race_sex", "stick")
data_mw <- data_mw[, ..columns_we_want]

# examine the result
data_mw

## -----------------------------------------------------------------------------
# transform characters to factors ordered by median stickiness
data_mw <- order_multiway(data_mw)

# examine the result
data_mw

## ----echo = FALSE-------------------------------------------------------------
nlevel1 <- nlevels(data_mw$program)
nlevel2 <- nlevels(data_mw$race_sex)
r <- nlevel1 * nlevel2
q <- 32
asp_ratio1 <- (r + 2 * nlevel1) / q
asp_ratio2 <- (r + 2 * nlevel2) / q

## ----fig1, fig.asp = asp_ratio1-----------------------------------------------
# create one multiway graph 
ggplot(data = data_mw, aes(x = stick, y = race_sex)) +
  facet_wrap(vars(program), ncol = 1, as.table = FALSE) +
  geom_point(na.rm = TRUE) +
  labs(x = "Stickiness", y = "")

## ----fig1-dual, fig.asp = asp_ratio2------------------------------------------
# create the dual multiway graph 
ggplot(data = data_mw, aes(x = stick, y = program)) +
  facet_wrap(vars(race_sex), ncol = 1, as.table = FALSE) +
  geom_point(na.rm = TRUE) +
  labs(x = "Stickiness", y = "")

## ----results = "hide"---------------------------------------------------------
# tabulate data in block record ("long") form
blockf <- data_mw

# limit significant digits
blockf$stick <- round(blockf$stick, 2)

# examine the result
blockf

## ----echo = FALSE-------------------------------------------------------------
kable2html(blockf, caption = "Table 1: Stickiness (block records)")

## ----echo = FALSE-------------------------------------------------------------
temp <- reshape(data = blockf,
                 idvar     = "race_sex",  # rowKeyColumns
                 timevar   = "program",   # columnToTakeKeysFrom
                 v.names   = "stick",     # columnToTakeValuesFrom
                 direction = "wide")
row.names(temp) <- NULL
names(temp) <- c("Group", 
                  "Civil", 
                  "Electrical", 
                  "Industrial", 
                  "Mechanical")
kable2html(temp, caption = "Table 2: Stickiness (row records)")

## -----------------------------------------------------------------------------
# tabulate data in row record ("wide") form
rowf <- reshape(data = blockf,
                idvar     = "race_sex", # column of row keys to copy 
                timevar   = "program",  # column to take keys from
                v.names   = "stick",    # column to take values from
                direction = "wide")

# reset the row numbers
row.names(rowf) <- NULL

# edit columns names
names(rowf) <- c("Group", "Civil", "Electrical", "Industrial", "Mechanical")

# examine the result
rowf

## ----eval=FALSE---------------------------------------------------------------
#  # packages
#  library(midfieldr)
#  library(ggplot2)
#  
#  # load stickiness data from case study
#  pre_mw <- exa_stickiness
#  
#  # prepare rows
#  rows_we_want <- pre_mw$ever >= 5 &
#    !pre_mw$race %in% c("Unknown",
#                        "International",
#                        "Other",
#                        "Native American")
#  pre_mw <- pre_mw[rows_we_want, , drop = FALSE]
#  
#  # prepare columns
#  pre_mw$race_sex <- paste(pre_mw$race, pre_mw$sex, sep = " ")
#  columns_we_want <- c("program", "race_sex", "stick")
#  pre_mw <- pre_mw[, columns_we_want, drop = FALSE]
#  
#  # transform characters to factors ordered by median stickiness
#  data_mw <- order_multiway(pre_mw)
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
#  blockf <- data_mw
#  blockf$stick <- round(blockf$stick, 2)
#  columns_we_want <- c("race_sex", "program", "stick")
#  blockf <- blockf[, columns_we_want, drop = FALSE]
#  blockf
#  
#  # tabulate data in row record ("wide") form
#  rowf <- reshape(data = blockf,
#                  idvar     = "race_sex", # column of row keys to copy
#                  timevar   = "program",  # column to take keys from
#                  v.names   = "stick",    # column to take values from
#                  direction = "wide")
#  row.names(rowf) <- NULL
#  names(rowf) <- c("Group", "Civil", "Electrical", "Industrial", "Mechanical")
#  rowf

