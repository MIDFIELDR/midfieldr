# See R/roxygen.R for documentation below that uses inline R code

#' Determine completion status for every student
#'
#' Add columns to a data frame of student-level records that indicate whether a
#' student completed a degree, and if so, whether their completion was timely.
#' By "completion" we mean an undergraduate earning their first baccalaureate
#' degree (or degrees, for students earning more than one degree in the same
#' term). The term by which a student's completion would be considered timely
#' (the "timely completion term") is usually defined as 4-, 6-, or 8-years
#' after admission. Our default is 6 years.
#'
#' The new columns are:
#'
#' * `term_degree` Character. Term in which the first degree(s) are
#'    completed, encoded `YYYYT`. Joined from `midfield_degree`.
#'
#' * `completion_status` Character. Possible values are "timely","late",
#'    and "NA". Completion status is "timely" for students completing a
#'    degree no later than their timely completion terms; "late" for students
#'    completing their program after their timely completion term; and "NA"
#'    for non-completers.
#'
#' @param dframe Working data frame of student-level records to which
#'        completion-status columns are to be added. Required variables are
#'        `mcid` and `timely_term`.
#'
#' @param midfield_degree MIDFIELD `degree` data table or equivalent with
#'        required variables `mcid` and `term_degree.`
#'
#' @returns A data frame of the same type as `dframe`. The output has the
#' following properties:
#'
#' * Rows are not modified.
#' * Columns are added, overwriting existing columns (if any) of the same name.
#'   Other columns are not modified.
#' * Groups are not preserved.
#' * Data frame attributes are preserved for classes `data.frame`, `data.table`,
#'   or `tbl_df`.
#'
#' @family add_*
#' @example man/examples/exa_add_completion_status.R
#' @export
#'
add_completion_status <- function(dframe, midfield_degree = degree) {
  # ---------- checks, use base R syntax

  # required arguments
  qassert(dframe, "d+")
  qassert(midfield_degree, "d+")

  # required columns
  assert_names(colnames(dframe),
    must.include = c("mcid", "timely_term")
  )
  assert_names(colnames(midfield_degree),
    must.include = c("mcid", "term_degree")
  )

  # class of required columns
  qassert(dframe[["mcid"]], "s+")
  qassert(dframe[["timely_term"]], "s+")
  qassert(midfield_degree[["mcid"]], "s+")
  qassert(midfield_degree[["term_degree"]], "s+")

  # ---------- preparation

  # to restore class (tibble, data.frame, etc.) before return
  prior_class <- class(dframe)

  # Copy and setDT() non-DT input. Prevents by-ref changes.
  # No change to DT class input. By-ref changes remain active.
  DT <- copy_setDT_non_DT(dframe)
  midfield_degree <- copy_setDT_non_DT(midfield_degree)

  # bind names due to NSE notes in R CMD check
  completion_status <- NULL
  timely_term <- NULL
  term_degree <- NULL

  # ---------- do the work

  # variables added by this function and functions called (if any)
  new_cols <- c("term_degree", "completion_status")

  # retain original variables NOT in the vector of new columns
  old_cols <- find_old_cols(DT, new_cols)
  dframe <- DT[, .SD, .SDcols = old_cols]

  # Inner join using three columns of term
  x <- midfield_degree[, .(mcid, term_degree)]
  y <- unique(dframe[, .(mcid)])
  DT <- y[x, on = .(mcid), nomatch = NULL]

  # keep the first degree term
  setorderv(DT, c("mcid", "term_degree"))
  DT <- na.omit(DT, cols = c("term_degree"))
  DT <- DT[, .SD[1], by = "mcid"]
  setkey(DT, NULL)

  # left-outer join, keep all rows of dframe
  dframe <- merge(dframe, DT, by = "mcid", all.x = TRUE)

  # completion is timely, late, or NA
  dframe[, completion_status := fifelse(term_degree <= timely_term,
    "timely",
    "late",
    na = NA_character_
  )]

  # select columns to return
  final_cols <- c(old_cols, new_cols)
  dframe <- dframe[, .SD, .SDcols = final_cols]

  # old columns as keys, order columns and rows
  set_colrow_order(dframe, old_cols)

  # ---------- restore state

  # restore prior keys
  # setkeyv(DT, prior_keys)

  # Except for grouped tibbles, restores non-data.table data frames
  # to same class as input.
  dframe <- restore_non_dt_class(dframe, prior_class)

  dframe[]
}
