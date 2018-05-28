## ----setup, echo = FALSE, message = FALSE--------------------------------
library(knitr)
opts_knit$set(root.dir = "../")
opts_chunk$set(collapse = TRUE, comment = "#>")
opts_chunk$set(warning = FALSE, message = FALSE)
opts_chunk$set(error = TRUE, purl = FALSE)
opts_chunk$set(fig.width = 6)
options(tibble.print_max = 10L, tibble.print_min = 5L)
knit_hooks$set(inline = function(x) {
  if (!is.numeric(x)) {
    x
  } else if (x >= 10000) {
    prettyNum(round(x, 2), big.mark = ",")
  } else {
    prettyNum(round(x, 2))
  }
})

# unpack data bits
data_bits <- midfieldr:::data_bits_cip
obs_cip <- round(data_bits$data[data_bits$name == "obs_cip"] / 1e+0, 1)
var_cip <- data_bits$data[data_bits$name == "var_cip"]
size_cip <- round(data_bits$data[data_bits$name == "size_cip"] / 1e+3, 0)

