## ----setup, echo = FALSE------------------------------------------------------
knitr::opts_knit$set(root.dir = "../")
knitr::opts_chunk$set(
  echo = TRUE,
  error = TRUE, 
  message = FALSE,
  warning = FALSE,
  collapse = TRUE,
  comment = "#>",
  fig.width = 6,
  fig.asp = 1 / 1.6,
  out.width = "70%",
  fig.align = "center",
  fig.path = "../man/figures/vign-feasible-completion-"
)

## ----relationships, echo = FALSE, fig.asp = 5/10------------------------------
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

## ----message = FALSE----------------------------------------------------------
# packages used in the vignette
library(midfieldr)
library(midfielddata)

## -----------------------------------------------------------------------------
# identify the group of students
enrollees_id <- exa_ever

# examine the result
str(enrollees_id)

## -----------------------------------------------------------------------------
# filter IDs for feasible program completion within data limit 
enrollees_fc <- completion_feasible(id = enrollees_id)

# examine the result
str(enrollees_fc)

## -----------------------------------------------------------------------------
# gather student degree data 
enrollees_id <- exa_ever
degree_data  <- get_status_degrees(midfielddegrees, keep_id = enrollees_id)

# examine the result
str(degree_data)

## -----------------------------------------------------------------------------
# subset students with degrees and without
grad_rows <- !is.na(degree_data$degree)
grads     <- degree_data[grad_rows]
nongrads  <- degree_data[!grad_rows]

# extract the IDs
grads_id    <- grads$id
nongrads_id <- nongrads$id

# examine the result
str(grads_id)
str(nongrads_id)

## -----------------------------------------------------------------------------
# gather transfer data for non-grads
transfer_data <- get_status_transfers(midfieldstudents, keep_id = nongrads_id)

# examine the result
str(transfer_data)

## -----------------------------------------------------------------------------
# join transfer data to non-grads
nongrads <- merge(nongrads, transfer_data, by = "id", all.x = TRUE)

# examine the result
str(nongrads)

## -----------------------------------------------------------------------------
# gather data limits and matriculation limits
institution_limits <- get_institution_limits(midfieldterms)

# examine the result
institution_limits

## -----------------------------------------------------------------------------
# find median hours per term of students with degrees
hr_per_term <- get_institution_hours_term(midfieldterms, keep_id = grads_id)

# examine the result
hr_per_term

## -----------------------------------------------------------------------------
# join the two sets of institution data 
institutions <- merge(institution_limits, 
                      hr_per_term, 
                      by = "institution", 
                      all.x = TRUE)

# examine the result
institutions

## -----------------------------------------------------------------------------
# join student and institution data
fc_data <- merge(nongrads, institutions, by = "institution", all.x = TRUE)

# examine the result
str(fc_data)

## -----------------------------------------------------------------------------
# set NA transfer hours to zero
rows_to_zero <- is.na(fc_data$hours_transfer)
fc_data[rows_to_zero, hours_transfer := 0]

# examine the result
str(fc_data)

## -----------------------------------------------------------------------------
# estimate the term-equivalent of transfer credit hours
fc_data[, terms_transfer := floor(hours_transfer / median_hr_per_term )]

# examine the result
str(fc_data)

## -----------------------------------------------------------------------------
# omit columns no longer necessary 
fc_data$degree <- NULL
fc_data$data_limit <- NULL
fc_data$institution <- NULL
fc_data$hours_transfer <- NULL
fc_data$median_hr_per_term <- NULL

# examine the result
head(fc_data)

## -----------------------------------------------------------------------------
# transfer terms limited to a maximum of 4
rows_to_limit <- fc_data$terms_transfer > 4
fc_data[rows_to_limit, terms_transfer := 4]

## -----------------------------------------------------------------------------
# advance the matriculation limit 
fc_data <- term_addition(fc_data,
                         term_col = "matric_limit",
                         add_col = "terms_transfer")

# examine the result
str(fc_data)

## -----------------------------------------------------------------------------
# completion is feasible if the entry term does not exceed 
# the matriculation limit
rows_we_want <- fc_data$term_enter <= fc_data$matric_limit
nongrad_fc <- fc_data[rows_we_want]

# examine the result
str(nongrad_fc)

## -----------------------------------------------------------------------------
# gather the IDs of all students with completion feasible 
nongrad_fc_id <- nongrad_fc$id

# concatenate
feasible_id <- c(grads_id, nongrad_fc_id)
feasible_id <- sort(unique(feasible_id))

# examine the result
str(feasible_id)

## ----eval = FALSE-------------------------------------------------------------
#  # packages used in the vignette
#  library("midfieldr")
#  
#  # filter IDs for feasible program completion within data limit
#  enrollees_id <- exa_ever
#  enrollees_fc <- completion_feasible(id = enrollees_id)

## -----------------------------------------------------------------------------
library(midfieldr)
library(midfielddata)

# subset students with and without degrees 
enrollees_id <- exa_ever
degree_data  <- get_status_degrees(midfielddegrees, keep_id = enrollees_id)
grad_rows    <- !is.na(degree_data$degree)
grads        <- degree_data[grad_rows]
nongrads     <- degree_data[!grad_rows]
grads_id     <- grads$id
nongrads_id  <- nongrads$id

# gather transfer data
transfer_data <- get_status_transfers(midfieldstudents, keep_id = nongrads_id)
nongrads      <- merge(nongrads, transfer_data, by = "id", all.x = TRUE)

# gather institution variables
inst_limits  <- get_institution_limits(midfieldterms)
hr_per_term  <- get_institution_hours_term(midfieldterms, keep_id = grads_id)
institutions <- merge(inst_limits, 
                      hr_per_term, 
                      by = "institution", 
                      all.x = TRUE)
fc_data      <- merge(nongrads, 
                      institutions, 
                      by = "institution", 
                      all.x = TRUE)
rows_to_zero <- is.na(fc_data$hours_transfer)
fc_data[rows_to_zero, hours_transfer := 0]

# advance the matriculation limit
fc_data[, terms_transfer := floor(hours_transfer / median_hr_per_term)]
rows_to_limit <- fc_data$terms_transfer > 4
fc_data[rows_to_limit, terms_transfer := 4]
fc_data <- term_addition(fc_data,
                         term_col = "matric_limit",
                         add_col = "terms_transfer")

# return the completion-feasible subset of student IDs 
rows_we_want  <- fc_data$term_enter <= fc_data$matric_limit
nongrad_fc    <- fc_data[rows_we_want]
nongrad_fc_id <- nongrad_fc$id
feasible_id   <- sort(unique(c(grads_id, nongrad_fc_id)))

