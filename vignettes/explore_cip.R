## ----setup, include = FALSE---------------------------------------------------
source("vignette-knitr-opts.R")
knitr::opts_chunk$set(fig.path = "../man/figures/vignette-explore-cip-")

## -----------------------------------------------------------------------------
# packages used
library(midfieldr)
library(data.table)

# print max 20 rows, otherwise 5 rows each head/tail
options(datatable.print.nrows = 20, datatable.print.topn = 5)

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
# examine the data
cip

## ----echo=FALSE---------------------------------------------------------------
sub_cip <- filter_by_text(cip, "^41")
kable2html(sub_cip)

## -----------------------------------------------------------------------------
# examine variable types
sapply(cip, FUN = class)

## -----------------------------------------------------------------------------
# filter basics
sub_cip <- filter_by_text(cip, keep_any = "engineering")

# examine the result
sub_cip

## -----------------------------------------------------------------------------
# only the drop_any argument must be named
sub_cip <- filter_by_text(cip, "civil engineering", drop_any = "technology")

# examine the result
sub_cip

## -----------------------------------------------------------------------------
# example 1 filter using keywords
sub_cip <- filter_by_text(cip, keep_any = "civil")

# examine the result
sub_cip

## ----echo = FALSE-------------------------------------------------------------
# using kable_styling() for output but conceal from novice user
kable2html(sub_cip)

## ----results = "hide"---------------------------------------------------------
# first pass
sub_cip <- filter_by_text(cip, keep_any = "civil")

# refine the search
sub_cip <- filter_by_text(sub_cip, keep_any = "engineering")

# refine further
sub_cip <- filter_by_text(sub_cip, drop_any = "technology")

## ----echo = FALSE-------------------------------------------------------------
kable2html(sub_cip)

## ----results = "hide"---------------------------------------------------------
sub_cip <- filter_by_text(cip, keep_any = "civil engineering", drop_any = "technology")

## ----echo = FALSE-------------------------------------------------------------
kable2html(sub_cip)

## ----results = "hide"---------------------------------------------------------
# example 2 filter using numerical codes
sub_cip <- filter_by_text(cip, keep_any = "german")

## ----echo = FALSE-------------------------------------------------------------
kable2html(sub_cip)

## ----results = "hide"---------------------------------------------------------
sub_cip <- filter_by_text(cip, keep_any = c("050125", "160501"))

## ----echo = FALSE-------------------------------------------------------------
kable2html(sub_cip)

## ----results = "hide"---------------------------------------------------------
# example 3 filter using regular expressions
sub_cip <- filter_by_text(cip, keep_any = c("^1407", "^1408"))

## ----echo = FALSE-------------------------------------------------------------
kable2html(sub_cip)

## ----results = "hide"---------------------------------------------------------
# 2-digit example
sub_cip <- filter_by_text(cip, keep_any = "^54")

## ----echo = FALSE-------------------------------------------------------------
kable2html(sub_cip)

## ----results = "hide"---------------------------------------------------------
# a series with 2, 4, and 6-digits specified
sub_cip <- filter_by_text(cip, keep_any = c("^24", "^4102", "^450202"))

## ----echo = FALSE-------------------------------------------------------------
kable2html(sub_cip)

## ----message = TRUE-----------------------------------------------------------
# unsuccessful terms produce a message
sub_cip <- filter_by_text(cip, keep_any = c("050125", "111111", "160501", "Bogus", "^55"))

# but the successful terms are returned
sub_cip

## ----results = "hide"---------------------------------------------------------
sub_cip <- filter_by_text(cip, keep_any = "engineering", drop_any = "technology")
sub_cip <- filter_by_text(sub_cip, keep_any = c("civil", "electrical", "industrial", "mechanical"))

## ----echo = FALSE-------------------------------------------------------------
kable2html(sub_cip)

## -----------------------------------------------------------------------------
exa_cip <- filter_by_text(cip, keep_any = c("^1408", "^1410", "^1419", "^1435"))

## ----echo = FALSE-------------------------------------------------------------
kable2html(exa_cip)

## ----eval=FALSE---------------------------------------------------------------
#  # load packages
#  library("midfieldr")
#  
#  # examine variable types
#  str(cip)
#  
#  # filter basics
#  sub_cip <- filter_by_text(cip, keep_any = "engineering")
#  sub_cip <- filter_by_text(cip, "civil engineering", drop_any = "technology")
#  
#  # example 1 filter using keywords
#  sub_cip <- filter_by_text(cip, keep_any = "civil")
#  sub_cip <- filter_by_text(sub_cip, keep_any = "engineering")
#  sub_cip <- filter_by_text(sub_cip, drop_any = "technology")
#  sub_cip <- filter_by_text(cip, keep_any = "civil engineering", drop_any = "technology")
#  
#  # example 2 filter using numerical codes
#  sub_cip <- filter_by_text(cip, keep_any = "german")
#  sub_cip <- filter_by_text(cip, keep_any = c("050125", "160501"))
#  
#  # example 3 filter using regular expressions
#  sub_cip <- filter_by_text(cip, keep_any = c("^1407", "^1408"))
#  sub_cip <- filter_by_text(cip, keep_any = "^54")
#  sub_cip <- filter_by_text(cip, keep_any = c("^24", "^4102", "^450202"))
#  
#  # example 4 search terms that cannot be found
#  sub_cip <- filter_by_text(cip, keep_any = c("050125", "111111", "160501", "Bogus", "^55"))
#  
#  # case study data set
#  filter_by_text(cip, keep_any = c("^1408", "^1410", "^1419", "^1435"))
#  print(exa_cip)

