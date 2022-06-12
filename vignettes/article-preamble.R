# set knitr options for Rmd scripts

# code chunks
knitr::opts_chunk$set(
  echo = TRUE,
  message = FALSE,
  warning = FALSE,
  collapse = TRUE,
  comment = "#>",
  error = FALSE
)

# figures
knitr::opts_chunk$set(
    fig.width = 6,
    fig.asp = 1 / 1.6,
    out.width = "70%",
    fig.align = "center"
)

# inline numbers
knitr::knit_hooks$set(inline = function(x) {
  if (!is.numeric(x)) {
    x
  } else if (x >= 10000) {
    prettyNum(round(x, 2), big.mark = ",")
  } else {
    prettyNum(round(x, 2))
  }
})

# path to man directory for figures
set_readme_fig_path <- function(prefix){
    knitr::opts_chunk$set(fig.path = paste0("man/figures/", prefix))
}
set_vignette_fig_path <- function(prefix){
    knitr::opts_chunk$set(fig.path = paste0("../man/figures/", prefix))
}

