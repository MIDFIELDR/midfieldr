# See R/roxygen.R for documentation below that uses inline R code

#' Determine timely completion terms
#'
#' Determine the *timely completion term* for each student in a data frame
#' and add columns that support the findings.
#'
#' Completing an academic program in a timely manner means that a student
#' completes the requirements for a degree within a set time span, typically
#' 4, 6, or 8 years after admission depending on the definition adopted in a
#' particular study. The term at the end of that span is the
#' *timely completion term.*
#'
#' Our heuristic assigns a time span for timely completion to every student
#' (default is 6 academic years). For students admitted at second-year level
#' or higher, the span is reduced by one academic year for each full year the
#' student is assumed to have completed. The adjusted span is added to their
#' initial term at an institution to create the `timely_term` value for each
#' observation.
#'
#' @param dframe `r dframe` with required variable `{mcid}.`
#' @param midf_table `r midfield_x("term")` with required variables
#'        `{mcid, term, level}.`
#' @param ... `r param_dots`
#' @param sched_span Integer scalar (default 4), the number of years an
#'        institution officially schedules for completing a program.
#' @param span Integer scalar (default 6), number of years to define timely
#'        completion, typically 4, 6, or 8 years (100%, 150%, 200% respectively
#'        of `sched_span`).
#' @returns Data frame with the following properties:
#' * `r df_class_preserved`
#' * `r rows_not_modified`
#' * `r new_cols_added`
#'   - `term_i` &nbsp; Character. Initial term of a student's longitudinal
#'      record, encoded `YYYYT`. Extracted from `midf_table.`
#'   - `level_i` &nbsp; Character. Student level (01 Freshman, 02 Sophomore,
#'      etc.) in their initial term. Extracted from `midf_table.`
#'   - `adj_span` &nbsp; Numeric. Integer span of years for timely
#'      completion adjusted for a student's initial level.
#'   - `timely_term` &nbsp; Character. Latest term by which program completion
#'      would be considered timely. Encoded `YYYYT.`
#'
#' @example man/examples/exa_timely_term.R
#' @export
#'
timely_term <- function(dframe,
                        midf_table = term,
                        ...,
                        sched_span = NULL,
                        span = NULL) {
  #
  # ---------- declarations

  span <- span %?% 6
  sched_span <- sched_span %?% 4

  # active column names
  reqd_dframe_vars <- c("mcid")
  reqd_table_vars <- c("mcid", "term", "level")
  added_vars <- c("term_i", "level_i", "adj_span", "timely_term")

  # bind names due to NSE notes in R CMD check
  adj_span <- NULL
  level_i <- NULL
  term_i <- NULL
  DELTA <- NULL
  IDX <- NULL
  TERM_CODE <- NULL
  YYYY <- NULL

  # ---------- base R checks (all data frame classes)

  # arguments after ... must be named
  wrapr::stop_if_dot_args(
    substitute(list(...)),
    "Arguments after ... must be named, as in arg = val."
  )

  # data frame assessment
  qassert(dframe, "d+")
  qassert(midf_table, "d+")

  # required columns
  assert_names(colnames(dframe), must.include = reqd_dframe_vars)
  assert_names(colnames(midf_table), must.include = reqd_table_vars)

  # class of required columns
  for (var in reqd_dframe_vars) qassert(dframe[[var]], c("s+", "f+"))
  for (var in reqd_table_vars) qassert(midf_table[[var]], c("s+", "f+"))

  # other arguments
  assert_int(sched_span, lower = 0)
  assert_int(span, lower = sched_span)

  # ---------- preparation

  # to restore class except grouped tibbles
  prior_class <- setdiff(class(dframe), "grouped_df")

  # prevent by-ref changes propagating to global env
  dframe <- copy(dframe)
  midf_table <- copy(midf_table)

  # convert class for analysis
  setDT(dframe)
  setDT(midf_table)

  # ensure character vars
  psi <- function(x, sel_cols) {
    x[, names(.SD) := lapply(.SD, as.character), .SDcols = sel_cols]
  }
  dframe <- psi(dframe, reqd_dframe_vars)
  midf_table <- psi(midf_table, reqd_table_vars)

  # ---------- do the work

  # dframe columns to retain and return
  keep_dframe_vars <- setdiff(colnames(dframe), added_vars)
  return_vars <- c(keep_dframe_vars, added_vars)

  # select columns
  dframe <- dframe[, .SD, .SDcols = keep_dframe_vars]
  midf_table <- midf_table[, .SD, .SDcols = reqd_table_vars]

  # filter NAs in reqd vars
  phi <- function(x, reqd_vars) {
    x <- na.omit(x, cols = reqd_vars)
    x <- unique(x)
  }
  dframe <- phi(dframe, reqd_dframe_vars)
  midf_table <- phi(midf_table, reqd_table_vars)

  # make temporary colnames unique to prevent overwriting
  temp_vars <- c("idx", "yyyy", "term_code", "delta")
  temp_vars <- edit_new_col_names(dframe, temp_vars)
  idx <- temp_vars[1]
  yyyy <- temp_vars[2]
  term_code <- temp_vars[3]
  delta <- temp_vars[4]

  # add temporary column to restore row order
  dframe[, IDX := .I, env = list(IDX = idx)]

  # edit names before joining
  setnames(midf_table,
    old = c("term", "level"),
    new = c("term_i", "level_i")
  )

  # inner-join IDs, terms, levels
  ID_only <- unique(dframe[, .(mcid)])
  ID_term <- midf_table[ID_only, on = "mcid", nomatch = NULL]
  ID_term <- unique(ID_term)

  # keep the row of the first term by ID
  setorderv(ID_term, c("mcid", "term_i"))
  ID_term <- ID_term[, .SD[1L], by = c("mcid")]

  # left-join the results back to dframe
  dframe <- ID_term[dframe, on = "mcid"]

  # separate year and term codes
  dframe[, `:=`(
    YYYY = substr(term_i, 1, 4),
    TERM_CODE = substr(term_i, 5, 5)
  ),
  env = list(
    YYYY = yyyy,
    TERM_CODE = term_code
  )
  ]

  # for month terms, (letters A, B, ..., a, b, ...), set first term to zero
  dframe <- dframe[TERM_CODE %chin% c(LETTERS, letters), TERM_CODE := "0",
    env = list(TERM_CODE = term_code)
  ]

  # make year and term numeric
  dframe[, names(.SD) := lapply(.SD, as.numeric), .SDcols = c(yyyy, term_code)]

  # if first term is in summer, delay to the subsequent Fall
  dframe[TERM_CODE > 3, `:=`(
    YYYY = YYYY + 1,
    TERM_CODE = 1
  ),
  env = list(
    YYYY = yyyy,
    TERM_CODE = term_code
  )
  ]

  # reduce span by assumed number of completed years by level
  dframe[, DELTA := fcase(level_i %like% "04", 3,
    level_i %like% "03", 2,
    level_i %like% "02", 1,
    default = 0
  ),
  env = list(DELTA = delta)
  ]
  dframe[, adj_span := span - DELTA, env = list(DELTA = delta)]

  # construct the timely-completion term
  dframe[, timely_term := fcase(
    TERM_CODE == 0, paste0(YYYY + adj_span - 1, 3),
    TERM_CODE == 1, paste0(YYYY + adj_span - 1, 3),
    TERM_CODE > 1, paste0(YYYY + adj_span, 1)
  ), env = list(
    YYYY = yyyy,
    TERM_CODE = term_code
  )]

  # ---------- prepare to return

  # restore row order
  setkeyv(dframe, idx)

  # drop temporary cols, restore original col order
  dframe <- dframe[, .SD, .SDcols = return_vars]

  # ensure unique rows
  dframe <- unique(dframe)

  # restore class
  setattr(dframe, "class", prior_class)

  # done
  dframe[]
}


# ========== deprecated version ==========

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
    midf_table = midfield_term,
    ...,
    sched_span = sched_span,
    span = span
  )
}
