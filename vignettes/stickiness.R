## ----setup, echo = FALSE, message = FALSE--------------------------------
knitr::opts_knit$set(root.dir = "../")
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  error = TRUE,
  purl = FALSE, 
  fig.width = 6, 
  fig.asp = 1/1.6, 
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
options(tibble.print_min = 10L, tibble.print_max = 10L)

