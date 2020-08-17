## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(fig.path = "../man/figures/vignette-explore-cip-")
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
library(data.table)

# print max 20 rows, otherwise 10 rows each head/tail
options(datatable.print.nrows = 20, datatable.print.topn = 10)

## ----echo = FALSE-------------------------------------------------------------
df <- filter_by_text(cip, "^41")
n41 <- nrow(df)
n4102 <- filter_by_text(df, "^4102") %>% nrow()
n4103 <- filter_by_text(df, "^4103") %>% nrow()
name41 <- df$cip2name %>% unique()

df24 <- filter_by_text(cip, "^24")
n24 <- nrow(df24)
name24 <- df24$cip2name %>% unique()

df51 <- filter_by_text(cip, "^51")
n51 <- nrow(df51)
name51 <- df51$cip2name %>% unique()

df1313 <- filter_by_text(cip, "^1313")
n1313 <- nrow(df1313)
name1313 <- df1313$cip2name %>% unique()

cip <- filter_by_text(cip) # removes data.frame class if present

## -----------------------------------------------------------------------------
# column names and class of each 
unlist(lapply(cip, FUN = class))

## -----------------------------------------------------------------------------
# 2-digit codes and names alone
cip[, .(cip2, cip2name)]

# 4-digit codes and names alone 
cip[, .(cip4, cip4name)]

# 6-digit codes and names alone 
cip[, .(cip6, cip6name)]

## ----echo=FALSE---------------------------------------------------------------
df1 <- cip[1:6]
df1[6, ] <- "---"
df2 <- cip[1580:1584]
kable2html(rbind(df1, df2))

## ----echo=FALSE---------------------------------------------------------------
sub_cip <- filter_by_text(cip, "^41")
kable2html(sub_cip)

## -----------------------------------------------------------------------------
# examine variable types
unlist(lapply(cip, FUN = class))

## -----------------------------------------------------------------------------
# filter basics
sub_cip <- filter_by_text(cip, keep_text = "engineering")

# examine the result
sub_cip

## -----------------------------------------------------------------------------
# only the drop_text argument must be named
sub_cip <- filter_by_text(cip, "civil engineering", drop_text = "technology")

# examine the result
sub_cip

## -----------------------------------------------------------------------------
# example 1 filter using keywords
sub_cip <- filter_by_text(cip, keep_text = "civil")

# examine the result
sub_cip

## ----echo = FALSE-------------------------------------------------------------
# using kable_styling() for output but conceal from novice user
kable2html(sub_cip)

## ----results = "hide"---------------------------------------------------------
# first pass
sub_cip <- filter_by_text(cip, keep_text = "civil")

# refine the search
sub_cip <- filter_by_text(sub_cip, keep_text = "engineering")

# refine further
sub_cip <- filter_by_text(sub_cip, drop_text = "technology")

## ----echo = FALSE-------------------------------------------------------------
kable2html(sub_cip)

## ----results = "hide"---------------------------------------------------------
sub_cip <- filter_by_text(cip, keep_text = "civil engineering", drop_text = "technology")

## ----echo = FALSE-------------------------------------------------------------
kable2html(sub_cip)

## ----results = "hide"---------------------------------------------------------
# example 2 filter using numerical codes
sub_cip <- filter_by_text(cip, keep_text = "german")

## ----echo = FALSE-------------------------------------------------------------
kable2html(sub_cip)

## ----results = "hide"---------------------------------------------------------
sub_cip <- filter_by_text(cip, keep_text = c("050125", "160501"))

## ----echo = FALSE-------------------------------------------------------------
kable2html(sub_cip)

## ----results = "hide"---------------------------------------------------------
# example 3 filter using regular expressions
sub_cip <- filter_by_text(cip, keep_text = c("^1407", "^1408"))

## ----echo = FALSE-------------------------------------------------------------
kable2html(sub_cip)

## ----results = "hide"---------------------------------------------------------
# 2-digit example
sub_cip <- filter_by_text(cip, keep_text = "^54")

## ----echo = FALSE-------------------------------------------------------------
kable2html(sub_cip)

## ----results = "hide"---------------------------------------------------------
# a series with 2, 4, and 6-digits specified
sub_cip <- filter_by_text(cip, keep_text = c("^24", "^4102", "^450202"))

## ----echo = FALSE-------------------------------------------------------------
kable2html(sub_cip)

## ----message = TRUE-----------------------------------------------------------
# unsuccessful terms produce a message
sub_cip <- filter_by_text(cip, keep_text = c("050125", "111111", "160501", "Bogus", "^55"))

# but the successful terms are returned
sub_cip

## -----------------------------------------------------------------------------
# selecting columns 
filter_by_text(cip, 
               keep_text = "^54", 
               keep_col = c("cip4", "cip4name"))

## -----------------------------------------------------------------------------
# remove duplicate rows 
filter_by_text(cip, 
               keep_text = "^54", 
               keep_col = c("cip4", "cip4name"), 
               unique_row = TRUE)

## ----results = "hide"---------------------------------------------------------
# explore the CIP
sub_cip <- filter_by_text(cip, keep_text = "engineering", drop_text = "technology")
sub_cip <- filter_by_text(sub_cip, keep_text = c("civil", "electrical", "industrial", "mechanical"))

## ----echo = FALSE-------------------------------------------------------------
kable2html(sub_cip)

## -----------------------------------------------------------------------------
# select the case study CIPs
case_study_cip <- filter_by_text(cip, keep_text = c("^1408", "^1410", "^1419", "^1435"))

## ----echo = FALSE-------------------------------------------------------------
kable2html(case_study_cip)

## ----eval=FALSE---------------------------------------------------------------
#  # packages used
#  library(midfieldr)
#  library(data.table)
#  
#  # examine variable types
#  str(cip)
#  
#  # filter basics
#  sub_cip <- filter_by_text(cip, keep_text = "engineering")
#  sub_cip <- filter_by_text(cip, "civil engineering", drop_text = "technology")
#  
#  # example 1 filter using keywords
#  sub_cip <- filter_by_text(cip, keep_text = "civil")
#  sub_cip <- filter_by_text(sub_cip, keep_text = "engineering")
#  sub_cip <- filter_by_text(sub_cip, drop_text = "technology")
#  sub_cip <- filter_by_text(cip, keep_text = "civil engineering", drop_text = "technology")
#  
#  # example 2 filter using numerical codes
#  sub_cip <- filter_by_text(cip, keep_text = "german")
#  sub_cip <- filter_by_text(cip, keep_text = c("050125", "160501"))
#  
#  # example 3 filter using regular expressions
#  sub_cip <- filter_by_text(cip, keep_text = c("^1407", "^1408"))
#  sub_cip <- filter_by_text(cip, keep_text = "^54")
#  sub_cip <- filter_by_text(cip, keep_text = c("^24", "^4102", "^450202"))
#  
#  # example 4 search terms that cannot be found
#  sub_cip <- filter_by_text(cip, keep_text = c("050125", "111111", "160501", "Bogus", "^55"))
#  
#  # case study data set
#  filter_by_text(cip, keep_text = c("^1408", "^1410", "^1419", "^1435"))
#  print(rep_cip)

