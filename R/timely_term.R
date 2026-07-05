# See R/roxygen.R for documentation below that uses inline R code


# ---------- deprecated version ----------

#' midfieldr deprecated functions
#' @param dframe `r dframe`
#' @param midfield_term `r midfield_x("*term*")`
#' @param ... `r param_dots`
#' @param sched_span Integer scalar
#' @param span Integer scalar
#' @rdname midfieldr-deprecated
#' @export
add_timely_term <- function(dframe,
                            midfield_term = term,
                            ...,
                            sched_span = NULL,
                            span = NULL) {
  .Deprecated(
    new = "timely_term",
    package = "midfieldr",
    msg = "This function was deprecated as part of an update to all
    midfieldr functions. Please use `timely_term()` instead."
  )

  # original function calls the new function
  timely_term(
    dframe = dframe,
    midfield_table = midfield_term,
    ...,
    sched_span = sched_span,
    span = span
  )
}
NULL



# ---------- current version ----------


#' Estimate timely completion terms
#'
#' Starting with a data frame of unique student IDs, estimate the term by 
#' which a student's program completion would be considered timely and add 
#' columns to the data frame that support the finding. 
#'
#' The latest term by which program completion would be considered
#' timely is the *timely completion term,* typically 4, 6, or 8 years after 
#' admission depending on the definition adopted in a particular study. By 
#' "completion" we mean an undergraduate earning their first baccalaureate 
#' degree or degrees.
#'
#' Our heuristic assigns `span` number of years (default 6) to every
#' student. For students admitted at second-year level or higher, the span is
#' reduced by one year for each full year the student is assumed to have
#' completed. The adjusted span is added to their initial term to create the
#' `timely_term` values. These results are documented in the output. 
#' 
#' Determining completion status requires output variable `{timely_term}`; 
#' determining data sufficiency requires output variables 
#' `{term_i, timely_term}.`
#'
#' @param dframe `r dframe` Required variable: `{mcid}`.
#'
#' @param midfield_table Data frame of *term* student-level records.     
#'        Required variables: `{mcid, term, level}`.
#'
#' @param ... `r param_dots`
#'
#' @param sched_span Integer scalar (default 4), the number of years an 
#'        institution officially schedules for completing a program.
#'
#' @param span Integer scalar (default 6), number of years to define timely
#'        completion, typically 4, 6, or 8 years (100%, 150%, 200% respectively
#'        of `sched_span`).
#'
#' @returns Data frame with the following properties:
#' * Data frame class is preserved.
#' * Rows are filtered for unique student IDs. 
#' * Variable `{mcid}` is retained. All other columns are dropped and the 
#'   following variables are added: 
#'   - `term_i` &nbsp; Initial term of a student's longitudinal record,
#'      encoded `YYYYT`. Extracted from `midfield_table.`
#'   - `level_i` &nbsp; Character. Student level (01 Freshman, 02 Sophomore,
#'      etc.) in their initial term. Extracted from `midfield_table.`
#'   - `adj_span` &nbsp; Numeric. Integer span of years for timely
#'      completion adjusted for a student's initial level.
#'   - `timely_term` &nbsp; Character. Latest term by which
#'      program completion
#'      would be considered timely for every student. Encoded `YYYYT.`
#' * Groups and keys are not preserved.
#'
#' @example man/examples/exa_timely_term.R
#' @export
#'
timely_term <- function(dframe,
                        midfield_table = term,
                        ...,
                        sched_span = NULL,
                        span = NULL) {
  # ---------- assign active column names
  
  reqd_dframe_vars <- c("mcid")
  reqd_table_vars <- c("mcid", "term", "level")
  added_vars <- c("term_i", "level_i", "adj_span", "timely_term")

  # ---------- base R checks (all data frame classes)

  # arguments after ... must be named
  wrapr::stop_if_dot_args(
    substitute(list(...)),
    "Arguments after ... must be named, as in arg = val."
  )

  # data frame assessment
  qassert(dframe, "d+")
  qassert(midfield_table, "d+")

  # required columns
  assert_names(colnames(dframe), must.include = reqd_dframe_vars)
  assert_names(colnames(midfield_table), must.include = reqd_table_vars)

  # class of required columns
  for (i in seq_along(reqd_dframe_vars)) {
    qassert(dframe[[reqd_dframe_vars[i]]], "s+")
  }
  for (i in seq_along(reqd_table_vars)) {
    qassert(midfield_table[[reqd_table_vars[i]]], "s+")
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
  midf_table <- copy(midfield_table)
  setDT(midf_table)

  # bind names due to NSE notes in R CMD check
  adj_span <- NULL
  delta <- NULL
  idx <- NULL
  level_i <- NULL
  term_i <- NULL
  timely_term <- NULL
  yyyy <- NULL
  
  # ---------- do the work

  # subset required variables
  dframe <- dframe[, .SD, .SDcols = reqd_dframe_vars]
  dframe <- unique(dframe, na.rm = TRUE)
  
  midf_table <- midf_table[, .SD, .SDcols = reqd_table_vars]
  midf_table <- unique(midf_table, na.rm = TRUE)

  # add temp col to restore row order
  dframe[, idx := .I]
  
  # inner-join dframe ID-only with required table vars
  x <- unique(dframe[, .(mcid)])
  x <- midf_table[x, on = "mcid", nomatch = NULL]
  x <- unique(x)

  # keep the row of the first term, lowest level
  setorderv(x, c("mcid", "term"))
  x <- x[, .SD[1], by = "mcid"]

  # rename term and level
  x <- x[, .(mcid, term_i = term, level_i = level)]

  # left-join the results back to dframe
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
  
  # restore row order
  setkey(dframe, idx)
  
  # restore col order, drop temporary cols
  dframe <- dframe[, .SD, .SDcols = c(reqd_dframe_vars, added_vars)]
  
  # ensure unique rows
  dframe <- unique(dframe)
  
  # restore class
  setattr(dframe, "class", prior_class)
  
  # done
  dframe[]
}
