# See R/roxygen.R for documentation below that uses inline R code

#' Determine timely completion terms
#'
#' Determine the *timely completion term* for each student in a data frame
#' and add columns that support the findings.
#'
#' Completing an academic program in a "timely" manner means that a student
#' completes the requirements for a degree within a set time span, typically
#' 4, 6, or 8 years after admission depending on the definition adopted in a
#' particular study. The final term of that span is the
#' *timely completion term.*
#'
#' Our heuristic assigns a time span of 6 academic years for timely completion
#' (other values can be assigned via the `span` argument). For students
#' admitted at second-year level or higher, the span value is reduced by
#' one academic year for each full year the student is assumed to have
#' completed. The adjusted span is added to their initial term at an
#' institution to create the `timely_term` value for each observation.
#'
#' `r redundant_cols("timely_term")`
#'
#' @param dframe `r dframe` with required variable `{mcid}.`
#' @param midf_table `r midfield_x("term")` with required variables
#'        `{mcid, term, level}.`
#' @param ... `r param_dots`
#' @param span Integer scalar (default 6), number of years to define timely
#'        completion, typically 4, 6, or 8 years (100%, 150%, 200% respectively
#'        of `sched_span`).#'
#' @param sched_span Integer scalar (default 4), the number of years an
#'        institution officially schedules for completing a program.
#' @returns Data frame with the following properties:
#' * `r keep_class_rm_groups_rm_keys`
#' * `r keep_row_order_rm_NA_rm_duplic_rows`
#' * `r add_new_cols` The new variables are:
#'   - `entry_term` &nbsp; Character. Initial term of a student's longitudinal
#'      record, encoded `YYYYT`. Extracted from `midf_table.`
#'   - `entry_level` &nbsp; Character. Student level (01 Freshman, 02 Sophomore,
#'      etc.) in their initial term. Extracted from `midf_table.`
#'   - `adj_span` &nbsp; Numeric. Integer span of years for timely
#'      completion adjusted for a student's initial level.
#'   - `timely_term` &nbsp; Character. Latest term by which program completion
#'      would be considered timely. Encoded `YYYYT.`
#' @example man/examples/exa_timely_term.R
#' @export
#'
timely_term <- function(dframe,
                        midf_table = term,
                        ...,
                        span = NULL,
                        sched_span = NULL) {
  #
  # ---------- initial assertions

  # data frames
  qassert(dframe, "d+")
  qassert(midf_table, "d+")

  # arguments after ... must be named
  wrapr::stop_if_dot_args(
    substitute(list(...)),
    "Arguments after ... must be named, as in arg = val."
  )

  # ---------- declarations

  # active column names
  reqd_dframe_vars <- c("mcid")
  reqd_table_vars <- c("mcid", "term", "level")

  # optional defaults
  span <- span %?% 6
  sched_span <- sched_span %?% 4

  # bind names for R CMD check
  ADJ_SPAN <- NULL
  ENTRY_LEVEL <- NULL
  ENTRY_TERM <- NULL
  DELTA <- NULL
  IDX <- NULL
  TERM_CODE <- NULL
  TIMELY_TERM <- NULL
  YYYY <- NULL

  # ---------- variable assertions

  utils_check_reqd_vars(dframe, reqd_dframe_vars)
  utils_check_reqd_vars(midf_table, reqd_table_vars)
  assert_int(sched_span, lower = 0)
  assert_int(span, lower = sched_span)

  # ---------- preparation

  # for restoring class except grouped tibbles
  prior_class <- setdiff(class(dframe), "grouped_df")

  # prevent by-ref changes propagating to global env
  dframe <- copy(dframe)
  midf_table <- copy(midf_table)

  # setDT then reqd_vars as.char, na.omit, unique
  dframe <- utils_prep_DT(dframe, reqd_dframe_vars)
  midf_table <- utils_prep_DT(midf_table, reqd_table_vars)

  # select columns
  midf_table <- midf_table[, .SD, .SDcols = reqd_table_vars]

  # ---------- prevent overwriting

  added_vars <- c("entry_term", "entry_level", "adj_span", "timely_term")
  temp_vars <- c("idx", "yyyy", "term_code", "delta")
  proposed <- c(added_vars, temp_vars)

  new_vars <- utils_edit_colnames(dframe, proposed)

  q_entry_term <- new_vars[1]
  q_entry_level <- new_vars[2]
  q_adj_span <- new_vars[3]
  q_timely_term <- new_vars[4]
  q_idx <- new_vars[5]
  q_yyyy <- new_vars[6]
  q_term_code <- new_vars[7]
  q_delta <- new_vars[8]

  return_vars <- c(names(dframe), new_vars[1:4])

  # ---------- do the work

  # for restoring row order
  dframe[, IDX := .I, env = list(IDX = q_idx)]

  # edit names before joining
  setnames(midf_table,
    old = c("term", "level"),
    new = c(q_entry_term, q_entry_level)
  )

  # inner-join IDs, terms, levels
  ID_only <- unique(dframe[, .(mcid)])
  ID_term <- midf_table[ID_only, on = "mcid", nomatch = NULL]
  ID_term <- unique(ID_term)

  # keep the row of the first term by ID
  setorderv(ID_term, c("mcid", q_entry_term))
  ID_term <- ID_term[, .SD[1L], by = c("mcid")]

  # left-join the results back to dframe
  dframe <- ID_term[dframe, on = "mcid"]

  # separate year and term codes
  dframe[, `:=`(
    YYYY = substr(ENTRY_TERM, 1, 4),
    TERM_CODE = substr(ENTRY_TERM, 5, 5)
  ),
  env = list(
    ENTRY_TERM = q_entry_term,
    TERM_CODE = q_term_code,
    YYYY = q_yyyy
  )
  ]

  # for month terms, (letters A, B, ..., a, b, ...), set first term to zero
  dframe[TERM_CODE %chin% c(LETTERS, letters), TERM_CODE := "0",
    env = list(TERM_CODE = q_term_code)
  ]

  # make year and term numeric
  dframe[, names(.SD) := lapply(.SD, as.numeric), .SDcols = c(q_yyyy, q_term_code)]

  # if first term is in summer, delay to the subsequent Fall
  dframe[TERM_CODE > 3, `:=`(
    YYYY = YYYY + 1,
    TERM_CODE = 1
  ),
  env = list(
    TERM_CODE = q_term_code,
    YYYY = q_yyyy
  )
  ]

  # reduce span by assumed number of completed years by level
  dframe[, DELTA := fcase(
    ENTRY_LEVEL %like% "04", 3,
    ENTRY_LEVEL %like% "03", 2,
    ENTRY_LEVEL %like% "02", 1,
    default = 0
  ),
  env = list(
    DELTA = q_delta,
    ENTRY_LEVEL = q_entry_level
  )
  ]
  dframe[, ADJ_SPAN := span - DELTA,
    env = list(
      ADJ_SPAN = q_adj_span,
      DELTA = q_delta
    )
  ]

  # construct the timely-completion term
  dframe[, TIMELY_TERM := fcase(
    TERM_CODE == 0, paste0(YYYY + ADJ_SPAN - 1, 3),
    TERM_CODE == 1, paste0(YYYY + ADJ_SPAN - 1, 3),
    TERM_CODE > 1, paste0(YYYY + ADJ_SPAN, 1)
  ), env = list(
    TIMELY_TERM = q_timely_term,
    TERM_CODE = q_term_code,
    ADJ_SPAN = q_adj_span,
    YYYY = q_yyyy
  )]

  # ---------- prepare to return

  # restore row order
  setkeyv(dframe, q_idx)

  # NULL keys, return vars, unique, class
  dframe <- utils_prep_return(dframe, return_vars, prior_class)

  # drop cols or cols.1 duplicates if any
  dframe <- rm_redundant_cols(dframe)

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

  # invoking the old function calls the new function
  timely_term(
    dframe = dframe,
    midf_table = midfield_term,
    ...,
    sched_span = sched_span,
    span = span
  )
}
