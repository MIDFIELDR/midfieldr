## ----setup, echo = FALSE, message = FALSE-------------------------------------
knitr::opts_chunk$set(
  fig.path = "../man/figures/vignette-explore-multiway-", 
  fig.align = "center",
  fig.show = "hold", 
  out.width = "70%",
  fig.width = 6,
  fig.asp = 0.7,
  echo = TRUE,
  message = FALSE,
  warning = FALSE,
  collapse = TRUE,
  comment = "#>",
  error = TRUE,
  purl = FALSE
  # see note in README or error/purl settings
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

