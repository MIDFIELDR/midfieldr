# See R/roxygen.R for documentation below that uses inline R code

#' Calculate timely completion terms
#'
#' To a data frame keyed by student ID, add a column indicating the
#' student's timely completion term. Columns of supporting
#' information are also added.
#'
#' In many studies, students must complete their programs in a specified time
#' span to be considered "timely", for example 4, 6, or 8 years after
#' admission. The latest term by which program completion would be considered
#' timely is the *timely completion term.* By "completion" we mean an
#' undergraduate earning their first baccalaureate degree (or degrees, for
#' students earning more than one degree in the same term).
#'
#' The timely completion term is required for determining data sufficiency
#' as well as timely completion status. The goal in either case is to refine
#' a population, that is, obtain a data frame of IDs that satisfy our
#' constraints. Thus `add_timely_term()` yields a column of  timely term
#' values and columns of supporting information keyed by ID. All other columns
#' in `dframe` (if any) are dropped.
#'
#' Our heuristic assigns `span` number of years (default 6) to every
#' student. For students admitted at second-year level or higher, the span is
#' reduced by one year for each full year the student is assumed to have
#' completed. For example, a student admitted at the second-year level is
#' assumed to have completed one year of a program, so their span is reduced by
#' one year. The adjusted span is added to their initial term to create the
#' `timely_term` values.
#'
#' The supporting information in the output is provided so that the user
#' can review the findings. Moreover, `data_sufficiency()` and
#' `completion_status()` require one or both of the added columns
#' `{term_i, timely_term}.`
#'
#'
#' @param dframe `r dframe` Required variable: `{mcid}`.
#'
#' @param midfield_rec `r midfield_x("*term*")` Required variables:
#'        `{mcid, term, level}`.
#'
#' @param ... `r param_dots`
#'
#' @param sched_span Integer scalar (default 4), the number of years an institution
#'        officially schedules for completing a program.
#'
#' @param span Integer scalar (default 6), number of years to define timely
#'        completion, typically 4, 6, or 8 years (100%, 150%, 200% respectively
#'        of `sched_span`).
#'
#' @returns Data frame with the following properties:
#' * Data frame class is preserved. Groups and keys are not preserved.
#' * Rows are filtered for unique `mcid` values.
#' * Column `{mcid}` is retained (all other columns are dropped). New columns added:
#'   - `term_i.` &nbsp; Initial term of a student's longitudinal record,
#'      encoded `YYYYT`. Extracted from `midfield_rec.`
#'   - `level_i.` &nbsp; Character. Student level (01 Freshman, 02 Sophomore,
#'      etc.) in their initial term. Extracted from `midfield_rec.`
#'   - `adj_span.` &nbsp; Numeric. Integer span of years for timely completion
#'      adjusted for a student's initial level.
#'   - `timely_term.` &nbsp; Character. Latest term by which program completion
#'      would be considered timely for every student. Encoded `YYYYT.`

#'
#' @family add_*
#' @example man/examples/exa_add_timely_term.R
#' @export
#'
add_timely_term <- function(dframe,
                            midfield_rec = term,
                            ...,
                            sched_span = NULL,
                            span = NULL) {
  # define required columns and variables to be added
  dframe_vars <- c("mcid")
  record_vars <- c("mcid", "term", "level")
  added_vars <- c("term_i", "level_i", "adj_span", "timely_term")
  return_vars <- c(dframe_vars, added_vars)

  # ---------- base R checks (all data frame classes)
  #
  # arguments after ... must be named
  wrapr::stop_if_dot_args(
    substitute(list(...)),
    "Arguments after ... must be named, as in arg = val."
  )

  # data frame assessment
  qassert(dframe, "d+")
  qassert(midfield_rec, "d+")

  # required columns
  assert_names(colnames(dframe), must.include = dframe_vars)
  assert_names(colnames(midfield_rec), must.include = record_vars)

  # class of required columns
  for (i in seq_along(dframe_vars)) {
    qassert(dframe[[dframe_vars[i]]], "s+")
  }
  for (i in seq_along(record_vars)) {
    qassert(midfield_rec[[record_vars[i]]], "s+")
  }

  # other arguments
  span <- span %?% 6
  sched_span <- sched_span %?% 4

  assert_int(sched_span, lower = 0)
  assert_int(span, lower = sched_span)

  # ---------- preparation

  # to restore class except for groups in tibbles
  prior_class <- setdiff(class(dframe), "grouped_df")

  # prevent by-ref changes propagating to global env
  dframe <- copy(dframe)
  setDT(dframe)
  reqd_record <- copy(midfield_rec)
  setDT(reqd_record)

  # bind names due to NSE notes in R CMD check
  adj_span <- NULL
  delta <- NULL
  level_i <- NULL
  term_i <- NULL
  timely_term <- NULL
  yyyy <- NULL

  # ---------- do the work

  # subset required variables
  dframe <- dframe[, .SD, .SDcols = dframe_vars]
  dframe <- unique(dframe, na.rm = TRUE)
  reqd_record <- reqd_record[, .SD, .SDcols = record_vars]
  reqd_record <- unique(reqd_record, na.rm = TRUE)

  # inner-join IDs and term vars
  x <- reqd_record[dframe, on = "mcid", nomatch = NULL]
  x <- unique(x)

  # keep the row of the first term, lowest level
  setorderv(x, c("mcid", "term"), order = 1)
  x <- x[, .SD[1], by = "mcid"]

  # rename term and level
  x <- x[, .(mcid, term_i = term, level_i = level)]

  # left-join term_i and level_i to dframe
  dframe <- x[dframe, on = "mcid"]

  # ---------- construct timely term

  dframe[, `:=`(
    yyyy = substr(term_i, 1, 4),
    t    = substr(term_i, 5, 5)
  )]

  # for month terms, (letters A, B, C, ...), set first term to zero
  dframe <- dframe[t %chin% LETTERS | t %chin% letters, t := "0"]

  # make year and term numeric
  dframe[, `:=`(
    yyyy = as.numeric(yyyy),
    t    = as.numeric(t)
  )]

  # if first term is in summer, delay to the subsequent Fall
  dframe[t > 3, `:=`(yyyy = yyyy + 1, t = 1)]

  # reduce span by assumed number of completed years by level
  dframe[, delta := fcase(
    level_i %like% "04", 3,
    level_i %like% "03", 2,
    level_i %like% "02", 1,
    default = 0
  )]
  dframe[, adj_span := span - delta]

  # use adj_span to construct estimated timely-completion term
  dframe[t == 0 | t == 1, timely_term := paste0(yyyy + adj_span - 1, 3)]
  dframe[t > 1, timely_term := paste0(yyyy + adj_span, 1)]

  # ---------- prepare to return

  dframe <- dframe[, .SD, .SDcols = return_vars]
  setkey(dframe, NULL)
  setattr(dframe, "class", prior_class)
  dframe[]
}
