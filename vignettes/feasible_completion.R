## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  fig.path = "../man/figures/vignette-feasible-completion-"
  )
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

## ----fig1, echo = FALSE, fig.asp = 5/10---------------------------------------
yyyyt <- c(1988, 2005, 2010)
df <- data.frame(yyyyt = yyyyt, y = 1)

library("ggplot2")
callout_color <- "gray60"
callout_line_size <- 0.3
anno_size <- 3.5 # 3.5 approx 10 point
vert_baseline <- 1.07

ggplot(df, aes(x = yyyyt, y = y)) +

  # vertical dimension lines
  geom_segment(aes(x = 1988, xend = 1988, y = vert_baseline, yend = 1.55),
    color = callout_color, size = callout_line_size
  ) +
  annotate("text",
    x = 1988, y = 0.89, size = anno_size,
    label = "first record", hjust = 1, vjust = 0
  ) +
  annotate("text",
    x = 2005, y = 0.89, size = anno_size,
    label = "matriculation limit", hjust = 1, vjust = 0
  ) +
  geom_segment(aes(x = 2005, xend = 2005, y = vert_baseline, yend = 1.3),
    color = callout_color, size = callout_line_size
  ) +
  annotate("text",
    x = 2010, y = 0.89, size = anno_size,
    label = "data limit", hjust = 0, vjust = 0
  ) +
  geom_segment(aes(x = 2010, xend = 2010, y = vert_baseline, yend = 1.55),
    color = callout_color, size = callout_line_size
  ) +

  # horiz arrows
  annotate("text",
    x = 2000,
    y = 1.55,
    size = anno_size,
    label = "range of institution's data"
  ) +
  geom_segment(aes(x = 1988, xend = 2010, y = 1.5, yend = 1.5),
    color = callout_color,
    size = callout_line_size,
    arrow = arrow(
      type = "closed",
      ends = "both",
      length = unit(2, "mm")
    ),
    arrow.fill = callout_color
  ) +
  annotate("text",
    x = 1992.5,
    y = 1.26,
    size = anno_size,
    # label = "entry terms for feasibility"
    label = "matriculate with\ncompletion feasible",
    hjust = 0,
    vjust = 0.5
  ) +
  geom_segment(aes(x = 1988, xend = 2005, y = 1.25, yend = 1.25),
    color = callout_color,
    size = callout_line_size,
    arrow = arrow(
      type = "closed",
      ends = "both",
      length = unit(2, "mm")
    ),
    arrow.fill = callout_color
  ) +
  annotate("text",
    x = 2007.5,
    y = 1.26,
    size = anno_size,
    label = "x\nyears",
    hjust = 0.5,
    vjust = 0.5
  ) +
  geom_segment(aes(x = 2005, xend = 2010, y = 1.25, yend = 1.25),
    color = callout_color,
    size = callout_line_size,
    arrow = arrow(
      type = "closed",
      ends = "both",
      length = unit(2, "mm")
    ),
    arrow.fill = callout_color
  ) +

  # geom_line(color = callout_color, size = callout_line_size) +
  geom_point(size = 2) +
  scale_x_continuous(limits = c(1980, 2020), breaks = seq(1980, 2020, 10)) +
  scale_y_continuous(limits = c(0.7, 1.7)) +
  labs(
    y = "",
    x = "Start of academic year",
    title = "A representative timeline for feasible completion"
  ) +
  theme_light() +
  theme(
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )

## -----------------------------------------------------------------------------
# packages used
library(midfieldr)

# print max 20 rows, otherwise 10 rows each head/tail
options(datatable.print.nrows = 20, datatable.print.topn = 10)

## -----------------------------------------------------------------------------
# view the example IDs
str(rep_ever)

## -----------------------------------------------------------------------------
# filter IDs for feasible program completion within data limit
feasible_id <- subset_feasible(rep_ever)

# examine the result
str(feasible_id)

## ----include = FALSE----------------------------------------------------------
# load all the fc intermediate results: fc01--fc08
load(system.file("extdata", "fc-vignette-data.rda", package = "midfieldr"))

## ----echo = FALSE-------------------------------------------------------------
# degrees data set
fc01

## ----echo = FALSE-------------------------------------------------------------
# re-coded degree column
fc02

## ----echo = FALSE-------------------------------------------------------------
# student matriculation information
fc03

## ----echo = FALSE-------------------------------------------------------------
# institution data limit
fc04

## ----echo = FALSE-------------------------------------------------------------
# initial matriculation limit
fc05

## ----echo = FALSE-------------------------------------------------------------
# data collection complete
fc06

## ----echo = FALSE-------------------------------------------------------------
# matriculation limit advanced by transfer credit
fc07

## ----echo = FALSE-------------------------------------------------------------
# subset complete for feasible completion
fc08

## ----echo = FALSE-------------------------------------------------------------
# resulting ID vector
str(fc08$id)

## ----eval = FALSE-------------------------------------------------------------
#  # packages used
#  library(midfieldr)
#  
#  # part 1:  How to use subset_feasible()
#  feasible_id <- subset_feasible(rep_ever)
#  
#  # part 2:  How subset_feasible() works
#  # no reproducible code

