# vignette setup script

knitr::opts_chunk$set(
    echo = TRUE,
    message = FALSE,
    warning = FALSE,
    collapse = TRUE,
    comment = "#>",
    error = FALSE,
    fig.width = 6,
    fig.asp = 1 / 1.6,
    out.width = "80%",
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
