## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(fig.path = here::here("man/figures", 
                                            "art-02-program-codes-"))
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
library("midfieldr")
library("data.table")

# optional code to control data.table printing
options(datatable.print.nrows = 10, 
        datatable.print.topn  = 5, 
        datatable.print.class = TRUE)

## ----echo = FALSE-------------------------------------------------------------
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

cip <- filter_search(cip) # removes data.frame class if present

## ----echo=FALSE---------------------------------------------------------------
sub_cip <- filter_search(cip, "^41")
kable2html(sub_cip)

## -----------------------------------------------------------------------------
str(cip)

## -----------------------------------------------------------------------------
cip

## -----------------------------------------------------------------------------
# at the 2-digit level
sort(unique(cip$cip2))

# at the 4-digit level
sort(unique(cip$cip4))

# at the 6-digit level
length(unique(cip$cip6))

## ----echo = FALSE-------------------------------------------------------------
set.seed(20210613)

## -----------------------------------------------------------------------------
some_programs <- cip[, cip4name, drop = FALSE]
sample(some_programs, 20)

## ----echo = FALSE-------------------------------------------------------------
set.seed(NULL)

## -----------------------------------------------------------------------------
# filter basics
filter_search(dframe = cip, keep_text = "engineering")

## -----------------------------------------------------------------------------
# applying optional argument drop_text and select
filter_search(cip, 
            "engineering", 
            drop_text = c("engineering-related", 
                          "engineering related", 
                          "engineering technology", 
                          "engineering technologies"), 
            select = c("cip6", "cip6name"))

## -----------------------------------------------------------------------------
# applying optionalk argument drop_text and select
filter_search(cip, 
            c("engineering"), 
            drop_text = c("engineering-related", 
                          "engineering related", 
                          "engineering technology", 
                          "engineering technologies"), 
            select = c("cip4", "cip4name"))

## -----------------------------------------------------------------------------
# example 1 filter using keywords
filter_search(cip, "civil")

## ----echo = FALSE-------------------------------------------------------------
sub_cip <- filter_search(cip, "civil")
# using kable_styling() for output but conceal from novice user
kable2html(sub_cip)

## ----results = "hide"---------------------------------------------------------
# first search
first_pass <- filter_search(cip, "civil")

# refine the search
second_pass <- filter_search(first_pass, "engineering")

# refine further
third_pass <- filter_search(second_pass, drop_text = "technology")

## ----echo = FALSE-------------------------------------------------------------
kable2html(third_pass)

## ----results = "hide"---------------------------------------------------------
# example 2 filter using numerical codes
filter_search(cip, "german")

## ----echo = FALSE-------------------------------------------------------------
sub_cip <- filter_search(cip, "german")
kable2html(sub_cip)

## ----echo = FALSE-------------------------------------------------------------
sub_cip <- filter_search(cip, c("050125", "160501"))
kable2html(sub_cip)

## ----echo = FALSE-------------------------------------------------------------
sub_cip <- filter_search(cip, c("^1407", "^1408"))
kable2html(sub_cip)

## ----echo = FALSE-------------------------------------------------------------
sub_cip <- filter_search(cip, "^54")
kable2html(sub_cip)

## ----results = "hide"---------------------------------------------------------
# character vector of search terms 
codes_we_want <- c("^24", "^4102", "^450202")

# a series with 2, 4, and 6-digits specified
filter_search(cip, codes_we_want)

## ----echo = FALSE-------------------------------------------------------------
sub_cip <- filter_search(cip, codes_we_want)
kable2html(sub_cip)

## ----message = TRUE-----------------------------------------------------------
# unsuccessful terms produce a message
sub_cip <- filter_search(cip, c("050125", "111111", "160501", "Bogus", "^55"))

# but the successful terms are returned
sub_cip

## -----------------------------------------------------------------------------
# name and class of variables (columns) in cip
unlist(lapply(cip, FUN = class))

## ----eval=FALSE---------------------------------------------------------------
#  # packages used
#  library("midfieldr")
#  library("data.table")
#  
#  # optional code to control data.table printing
#  options(datatable.print.nrows = 10,
#          datatable.print.topn  = 5,
#          datatable.print.class = TRUE)
#  # cip
#  str(cip)
#  sort(unique(cip$cip2))
#  sort(unique(cip$cip4))
#  length(unique(cip$cip6))
#  some_programs <- cip[, cip4name, drop = FALSE]
#  sample(some_programs, 20)
#  
#  # filter using keywords
#  filter_search(dframe = cip, keep_text = "engineering")
#  filter_search(cip,
#              "engineering",
#              drop_text = c("engineering-related",
#                            "engineering related",
#                            "engineering technology",
#                            "engineering technologies"),
#              select = c("cip6", "cip6name"))
#  filter_search(cip,
#              c("engineering"),
#              drop_text = c("engineering-related",
#                            "engineering related",
#                            "engineering technology",
#                            "engineering technologies"),
#              select = c("cip4", "cip4name"))
#  filter_search(cip, "civil")
#  first_pass  <- filter_search(cip, "civil")
#  second_pass <- filter_search(first_pass, "engineering")
#  third_pass  <- filter_search(second_pass, drop_text = "technology")
#  filter_search(cip, "civil engineering", drop_text = "technology")
#  
#  # filter using numerical codes
#  filter_search(cip, "german")
#  filter_search(cip, c("050125", "160501"))
#  filter_search(cip, c("^1407", "^1408"))
#  filter_search(cip, "^54")
#  codes_we_want <- c("^24", "^4102", "^450202")
#  filter_search(cip, codes_we_want)
#  
#  # when search terms cannot be found
#  sub_cip <- filter_search(cip, c("050125", "111111", "160501", "Bogus", "^55"))
#  sub_cip

