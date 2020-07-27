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
  fig.path = "../man/figures/vign-compute-stickiness-"
)

## ----echo = FALSE-------------------------------------------------------------
library(midfieldr)

## -----------------------------------------------------------------------------
# packages used
library(midfieldr)

# ever enrolled and completion feasible
enrollees <- exa_ever_fc

# examine the result
str(enrollees)

## ----eval=FALSE---------------------------------------------------------------
#  # TBD

