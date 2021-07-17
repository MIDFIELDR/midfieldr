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

set_fig_path <- function(file_prefix) {
    knitr::opts_chunk$set(
        fig.path = here::here("man/figures", file_prefix
        ))
}

kable2html <- function(x, font_size = NULL, caption = NULL) {
    font_size <- ifelse(is.null(font_size), 11, font_size)
    kable_in <- knitr::kable(x, format = "html", caption = caption)
    kableExtra::kable_styling(kable_input = kable_in, font_size = font_size)
}

asp_ratio_mw <- function(data, categories) {
    cat1 <- categories[1] # panels
    cat2 <- categories[2] # rows
    nlevel1 <- nlevels(data[, get(cat1)])
    nlevel2 <- nlevels(data[, get(cat2)])
    r <- nlevel1 * nlevel2
    q <- 32
    asp_ratio1 <- (r + 2 * nlevel1) / q
    asp_ratio2 <- (r + 2 * nlevel2) / q
    ratios <- c(asp_ratio1, asp_ratio2)
}
