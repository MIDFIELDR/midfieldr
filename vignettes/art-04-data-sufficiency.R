## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(fig.path = here::here(
  "man/figures",
  "art-04-data-sufficiency-"
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
library("data.table")
library("ggplot2")

# parameters
callout_color <- "gray60"
callout_line_size <- 0.3
anno_size <- 3.5 # 3.5 approx 10 point
vert_baseline <- 1.07

# construct coordinates
y <- c(1.4, 1.75, 2.0)
y_lim <- c(min(y) - 0.3, max(y) + 0.1)
x <- c(1986, 1990, 1992, 1995, 1996, 1997)
x_lim <- c(min(x) - 0.5, max(x) + 1.5)

# arrows
df_arrow <- wrapr::build_frame(
  "x", "x_end", "y" |
    x[1], x[5], y[3] |
    x[2], x[4], y[2] |
    x[3], x[6], y[1]
)
setDT(df_arrow)
df_arrow[, x_mid := (x + x_end) / 2]

# dimension lines
del <- 0.03
dim_lines <- wrapr::build_frame(
  "x", "y", "y_end" |
    x[1], y[3], y[3] |
    x[5], y[1], y[3] |
    x[2], y[2], y[2] |
    x[4], y[2], y[2] |
    x[3], y[1], y[1] |
    x[6], y[1], y[1]
)
setDT(dim_lines)
dim_lines[, `:=`(y = y - 1.5 * del, y_end = y_end + del)]
dim_lines[x == 1996, y := y - 4 * del]

# graph
ggplot(data = df_arrow) +
  scale_x_continuous(
    limits = x_lim,
    breaks = x
  ) +
  scale_y_continuous(limits = y_lim) +
  labs(
    y = "",
    x = "Year",
    title = "Illustrating data sufficiency"
  ) +
  theme_light() +
  theme(
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  ) +
  # horizontal arrows
  geom_segment(aes(x = x, xend = x_end, y = y, yend = y),
    color = callout_color,
    size = callout_line_size,
    arrow = arrow(
      type = "closed",
      ends = c("both", "both", "both"), # both, first, last
      length = unit(c(2, 2, 2), "mm") # "0" length = no arrow head
    ),
    arrow.fill = callout_color
  ) +
  # dimension lines
  geom_segment(
    data = dim_lines,
    aes(x = x, xend = x, y = y, yend = y_end),
    color = callout_color,
    size = callout_line_size,
    linetype = 1
  ) +
  # student labels
  annotate("text",
    x = df_arrow$x[2] - 0.7,
    y = df_arrow$y[c(2, 3)],
    size = anno_size,
    label = c("student A:", "student B:"),
    vjust = 0.5,
    hjust = 1
  ) +
  # label arrows
  annotate("text",
    x = df_arrow$x_mid,
    y = df_arrow$y,
    size = anno_size,
    label = c("institution data range", "timely span", "timely span"),
    vjust = -0.5
  ) +
  # label dimension lines
  annotate("text",
    x = dim_lines$x,
    y = dim_lines$y,
    size = anno_size,
    label = c(
      "",
      "data limit",
      "enter",
      "TC term",
      "enter",
      "TC term"
    ),
    vjust = 1,
    hjust = c(-0.1, 0.5, -0.1, 1.1, -0.1, -0.1)
  )

## -----------------------------------------------------------------------------
# packages used
library("midfieldr")
library("midfielddata")
library("data.table")

# optional code to format data.table printing
options(
  datatable.print.nrows = 10,
  datatable.print.topn = 5,
  datatable.print.class = TRUE
)

## -----------------------------------------------------------------------------
# load data tables from midfielddata
data(student, term, degree)

## -----------------------------------------------------------------------------
study_programs

## -----------------------------------------------------------------------------
case_students <- filter_match(term,
  match_to = study_programs,
  by_col = "cip6",
  select = c("mcid", "cip6")
)
case_students

## -----------------------------------------------------------------------------
case_students <- unique(case_students)
case_students

## -----------------------------------------------------------------------------
# limit population to degree-seeking students
DT <- filter_match(case_students,
  match_to = student,
  by_col = "mcid"
)

# examine the result
DT <- unique(DT)
DT

## -----------------------------------------------------------------------------
# estimate the timely completion term
DT <- add_timely_term(DT, midfield_term = term)
DT

## -----------------------------------------------------------------------------
# show details
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
x <- add_timely_term(DT, term, details = TRUE)

## ----echo = FALSE-------------------------------------------------------------
x[adj_span == 6, .SD[1], by = cip6]

## -----------------------------------------------------------------------------
# add institutions
DT <- add_institution(DT,
  midfield_term = term
)

# examine the result
DT

## -----------------------------------------------------------------------------
# add column with details
DT <- add_data_sufficiency(DT,
  midfield_term = term,
  details = TRUE
)
# examine the result
DT

## -----------------------------------------------------------------------------
# without details
DT <- add_data_sufficiency(DT,
  midfield_term = term,
  details = FALSE
)
# examine the result
DT

## -----------------------------------------------------------------------------
# select columns from term
cols_we_want <- c("institution", "term")
x <- term[order(institution, term), ..cols_we_want]

## ----include = FALSE----------------------------------------------------------
options(datatable.print.nrows = 12)
x[, .SD[.N], by = institution]

## -----------------------------------------------------------------------------
y <- add_data_sufficiency(DT,
  midfield_term = term,
  details = TRUE
)

## ----results = 'hide'---------------------------------------------------------
y[institution == "Institution A", .SD[1:5]]

## -----------------------------------------------------------------------------
# limit population to data sufficient
DT <- DT[data_sufficiency == TRUE]

# examine the result
DT

## -----------------------------------------------------------------------------
DT <- DT[, .(mcid, cip6)]

## -----------------------------------------------------------------------------
study_students

## -----------------------------------------------------------------------------
DT <- DT[order(mcid)]
study_students <- study_students[order(mcid)]
all.equal(DT, study_students)

## -----------------------------------------------------------------------------
# packages used
library("midfieldr")
library("midfielddata")
library("data.table")

# load data tables from midfielddata
data(student, term, degree)

# Case study students
case_students <- filter_match(term,
  match_to = study_programs,
  by_col = "cip6",
  select = c("mcid", "cip6")
)
case_students <- unique(case_students)

# Estimate the timely completion term
DT <- filter_match(case_students,
  match_to = student,
  by_col = "mcid"
)
DT <- unique(DT)
DT <- add_timely_term(DT, midfield_term = term)

# Determine data sufficiency
DT <- add_institution(DT, midfield_term = term)
DT <- add_data_sufficiency(DT,
  midfield_term = term,
  details = TRUE
)

# Subset data for data sufficiency
DT <- DT[data_sufficiency == TRUE]
DT <- DT[, .(mcid, cip6)]

