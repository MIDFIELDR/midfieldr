## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(fig.path = here::here("man/figures", 
                                            "art-05-stickiness-"))
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
library("midfielddata")
library("data.table")
library("ggplot2")

# optional code to control data.table printing
options(datatable.print.nrows = 10, 
        datatable.print.topn  = 5, 
        datatable.print.class = TRUE)

## -----------------------------------------------------------------------------
# load data tables from midfielddata
data(student, term, degree)

## ----eval=FALSE---------------------------------------------------------------
#  # packages used
#  library("midfieldr")
#  library("midfielddata")
#  library("data.table")
#  library("ggplot2")
#  
#  

