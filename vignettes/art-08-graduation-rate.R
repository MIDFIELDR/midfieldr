## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(fig.path = here::here(
  "man/figures",
  "art-08-graduation-rate-"
))
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

## ----echo = FALSE-------------------------------------------------------------
library("midfieldr")
library("midfielddata")
library("data.table")
Constraints <- c(
  "timely completion in:",
  "transfer students are:",
  "extended span for switchers is:",
  "part-time students are:",
  "cohort admitted in:"
)
IPEDS <- c(
  "6 years",
  "excluded",
  "excluded",
  "excluded",
  "Fall only"
)
MIDFIELD <- c(
  "6 years",
  "included",
  "planned",
  "included",
  "any term"
)
Notes <- c(
  "can be changed by user",
  "timely completion span depends on entry level",
  "heuristic in development for future release",
  "",
  ""
)

DT <- data.table(Constraints, IPEDS, MIDFIELD, Notes)
setnames(DT, old = c("Notes"), new = c("MIDFIELD notes"))
kable2html(DT, caption = "Comparing graduation rate criteria")

## -----------------------------------------------------------------------------
# packages used
library("midfieldr")
library("midfielddata")
library("data.table")
library("ggplot2")

# optional code to control data.table printing
options(
  datatable.print.nrows = 10,
  datatable.print.topn = 5,
  datatable.print.class = TRUE
)

## -----------------------------------------------------------------------------
# load data tables from midfielddata
data(student, term, degree)

## -----------------------------------------------------------------------------
# packages used
library("midfieldr")
library("midfielddata")
library("data.table")
library("ggplot2")

