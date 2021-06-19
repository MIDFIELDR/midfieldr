## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(fig.path = here::here(
  "man/figures",
  "art-06-timely-completion-"
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

## ----fig1, echo = FALSE, fig.asp = 5/10---------------------------------------
library("ggplot2")
library("data.table")
callout_color <- "gray60"
callout_line_size <- 0.3
anno_size <- 3.5 # 3.5 approx 10 point
vert_baseline <- 1.07

y1 <- 1.5
y2 <- 1.7
y_lim <- c(1.3, 1.8)

x1 <- 1990
x2 <- 1993
x3 <- 1994
x4 <- 1995
x_lim <- c(x1 - 1.5, x4 + 1.5)

# arrows
df_arrow <- wrapr::build_frame(
  "x", "x_end", "y" |
    x1, x4, y2 |
    x1, x2, y1
)
setDT(df_arrow)
df_arrow[, x_mid := (x + x_end) / 2]

# dimension lines
del <- 0.03
dim_lines <- wrapr::build_frame(
  "x", "y", "y_end" |
    x1, y1, y2 |
    x2, y1, y1 |
    x4, y2, y2 |
    x3, y1, y2
)
setDT(dim_lines)
dim_lines[, `:=`(y = y - 2 * del, y_end = y_end + del)]

# grad markers
grad <- wrapr::build_frame(
  "x", "y" |
    x3, y1 |
    x3, y2
)

ggplot(data = df_arrow) +
  scale_x_continuous(
    limits = x_lim,
    breaks = c(1990, 1993, 1994, 1995),
    labels = c("Fall 2010", "Spr 14", "Spr 15", "Spr 16")
  ) +
  scale_y_continuous(limits = y_lim) +
  labs(
    y = "",
    x = "Term",
    title = "Illustrating timely completion"
  ) +
  theme_light() +
  theme(
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  ) +
  # label start of student row
  annotate("text",
    x = df_arrow$x - 0.6,
    y = df_arrow$y,
    size = anno_size,
    label = c("student A", "student B"),
    vjust = 0.5,
    hjust = 1
  ) +
  # label end of student row
  # annotate("text",
  #          x = 1995.2,
  #          y = df_arrow$y,
  #          size = anno_size,
  #          label = c("timely",
  #                    "not timely"),
  #          vjust = 0.5,
  #          hjust = 0
  # ) +
  # arrows
  geom_segment(aes(x = x, xend = x_end, y = y, yend = y),
    color = callout_color,
    size = callout_line_size,
    arrow = arrow(
      type = "closed",
      ends = "both",
      length = unit(2, "mm")
    ),
    arrow.fill = callout_color
  ) +
  # label arrows
  annotate("text",
    x = df_arrow$x_mid,
    y = df_arrow$y,
    size = anno_size,
    label = "TC span",
    vjust = -0.5
  ) +
  # dimension lines
  geom_segment(
    data = dim_lines,
    aes(x = x, xend = x, y = y, yend = y_end),
    color = callout_color,
    size = callout_line_size,
    linetype = c(1, 1, 1, 2)
  ) +
  # label lines
  annotate("text",
    x = dim_lines$x,
    y = dim_lines$y,
    size = anno_size,
    label = c(
      "entry term",
      "TC term",
      "TC term",
      "degree term"
    ),
    vjust = 1,
    hjust = c(-0.1, 1.1, 1.1, -0.1)
  ) +
  # grad points
  geom_point(
    data = grad, aes(x = x, y = y),
    size = 2
  )

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
# case study IDs and CIP codes
study_students

## -----------------------------------------------------------------------------
# limit population to degree-seeking students
DT <- filter_match(study_students,
  match_to = student,
  by_col = "mcid"
)

# examine the result
DT

## -----------------------------------------------------------------------------
# estimate the timely completion term
DT <- add_timely_term(DT, midfield_term = term)
DT

## -----------------------------------------------------------------------------
# estimate the timely completion term with details shown
DT <- add_timely_term(DT,
  midfield_term = term,
  details = TRUE
)
DT

## -----------------------------------------------------------------------------
# repeat
DT <- add_timely_term(DT,
  midfield_term = term,
  details = TRUE
)
DT

## -----------------------------------------------------------------------------
# remove details
DT <- add_timely_term(DT,
  midfield_term = term,
  details = FALSE
)
DT

## -----------------------------------------------------------------------------
DT <- add_completion_timely(DT,
  midfield_degree = degree,
  details = TRUE
)
DT

# no details
DT <- add_completion_timely(DT,
  midfield_degree = degree,
  details = FALSE
)
DT

## -----------------------------------------------------------------------------
DT <- add_institution(DT,
                      midfield_term = term
)
DT

## -----------------------------------------------------------------------------
# add column with details
DT <- add_data_sufficiency(DT,
  midfield_term = term,
  details = TRUE
)
DT


# add column without details
DT <- add_data_sufficiency(DT,
  midfield_term = term,
  details = FALSE
)
DT




DT[, c("timely_term", "institution") := NULL]
DT

## -----------------------------------------------------------------------------
# limit population to data sufficient
DT <- DT[data_sufficiency == TRUE]
DT[]


DT <- DT[, grad_status := fifelse(completion_timely, "grad", "nongrad")]
DT[]

DT <- DT[, .(mcid, cip6, grad_status)]
DT[]

DT <- merge(DT, study_programs, by = "cip6", all.x = TRUE)
DT[, cip6 := NULL]
setcolorder(DT, c("mcid", "program"))
DT

