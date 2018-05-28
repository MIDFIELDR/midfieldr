## ----echo = FALSE, message = FALSE---------------------------------------
library(knitr)
opts_knit$set(root.dir = "../")
opts_chunk$set(collapse = TRUE, comment = "#>")
opts_chunk$set(warning = FALSE, message = FALSE)
opts_chunk$set(error = TRUE, purl = FALSE)
opts_chunk$set(fig.width = 6)
options(tibble.print_min = 6L, tibble.print_max = 6L)
knit_hooks$set(inline = function(x) {
  if (!is.numeric(x)) {
    x
  } else if (x >= 10000) {
    prettyNum(round(x, 2), big.mark = ",")
  } else {
    prettyNum(round(x, 2))
  }
})

