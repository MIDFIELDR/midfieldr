# See R/roxygen.R for documentation below that uses inline R code


# ---------- deprecated version ----------

#' midfieldr deprecated functions
#' @param dframe `r dframe`
#' @param midfield_term `r midfield_x("*term*")`
#' @rdname midfieldr-deprecated
#' @export
add_data_sufficiency <- function(dframe, midfield_term = term) {
  .Deprecated(
    new = "data_sufficiency",
    package = "midfieldr",
    msg = "This function was deprecated as part of an update to all
    midfieldr functions. Please use `data_sufficiency()` instead."
  )

  # original function calls the new function
  data_sufficiency(dframe = dframe, midfield_rec = midfield_term)
}
NULL



# ---------- current version ----------

#' Determine data sufficiency
#'
#' To a data frame keyed by student ID, add a column indicating that
#' an institution's data range is sufficient to reliably assess a
#' student's program completion. Columns of supporting
#' information are also added.  Unrelated columns are dropped.
#'
#' Because the time span of MIDFIELD term data varies by institution, each
#' has their own lower and upper bounds. When assessing a student's program
#' completion, an unavoidable ambiguity arises for student records at or near
#' these bounds. Such records must be identified and in most cases excluded
#' to prevent false summary counts.
#'
#' The *data sufficiency* criterion states that student records are limited to
#' those for which available data are sufficient to assess timely completion
#' without biased counts of completers or non-completers. In practice, the
#' criteria is implemented via two filters. Rows are labeled for exclusion
#' when: 1) a student ID is extant in the non-summer lower limit of an
#' institution's data range; or 2) a student ID has a timely completion term
#' that exceeds the upper limit of the institution's data range.
#'
#' The goal of determining data sufficiency is to refine a population, that
#' is, obtain a data frame of IDs that satisfy our constraints. Thus
#' `data_sufficiency()` yields a column of data sufficiency values and
#' columns of supporting information keyed by ID. All other columns in
#' `dframe` (if any) are dropped.
#'
#' The supporting information in the output is provided so that the user
#' can review the findings. After review, we usually delete all columns
#' except the IDs, yielding the refined population that was our goal.
#'
#' @param dframe `r dframe` Required variables: `{mcid, term_i, timely_term}`.
#'
#' @param midfield_rec `r midfield_x("*term*")` Required variables:
#'        `{mcid, term, institution}`.
#'
#' @returns Data frame with the following properties:
#' * Data frame class is preserved. Groups and keys are not preserved.
#' * Rows are filtered for unique `mcid` values.
#' * Columns `{mcid, term_i, timely_term}` are retained (all other columns
#'   are dropped). New columns added:
#'   - `institution.` &nbsp; Character. Institution in which the student is
#'      enrolled in the given term. Extracted from `midfield_rec.` The
#'      limits given in the next two columns are specific to the institution.
#'   - `lower_limit.` &nbsp; Character. Initial term of an institution's
#'      data range, encoded `YYYYT`. Extracted from `midfield_rec.`
#'      Compared to `term_i` to determine the lower-limit exclusion.
#'   - `upper_limit.` &nbsp; Character. Final term of an institution's
#'      data range, encoded `YYYYT`. Extracted from `midfield_rec.`
#'      Compared to `timely_term` to determine upper-limit exclusion.
#'   - `data_sufficiency.` &nbsp; Character. Possible values are "include",
#'      if the data are sufficient; and "exclude-lower" or "exclude-upper"
#'      if not, indicating at which boundary of the data range the ambiguity
#'      occurs.
#'
#' @example man/examples/exa_data_sufficiency.R
#' @export
#'
data_sufficiency <- function(dframe, midfield_rec = term) {
  # define required columns and variables to be added
  dframe_vars <- c("mcid", "term_i", "timely_term")
  record_vars <- c("mcid", "term", "institution")
  added_vars <- c("institution", "lower_limit", "upper_limit", "data_sufficiency")
  return_vars <- c(dframe_vars, added_vars)

  # ---------- base R checks (all data frame classes)

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

  # ---------- preparation

  # to restore class except for groups in tibbles
  prior_class <- setdiff(class(dframe), "grouped_df")

  # prevent by-ref changes propagating to global env
  dframe <- copy(dframe)
  setDT(dframe)
  reqd_record <- copy(midfield_rec)
  setDT(reqd_record)

  # subset required variables
  dframe <- dframe[, .SD, .SDcols = dframe_vars]
  dframe <- unique(dframe, na.rm = TRUE)
  reqd_record <- reqd_record[, .SD, .SDcols = record_vars]
  reqd_record <- unique(reqd_record, na.rm = TRUE)

  # bind names due to NSE notes in R CMD check
  data_sufficiency <- NULL
  lower_limit <- NULL
  term_i <- NULL
  timely_term <- NULL
  upper_limit <- NULL

  # ---------- do the work

  # subset required variables
  dframe <- dframe[, .SD, .SDcols = dframe_vars]
  dframe <- unique(dframe, na.rm = TRUE)
  reqd_record <- reqd_record[, .SD, .SDcols = record_vars]
  reqd_record <- unique(reqd_record, na.rm = TRUE)

  # join institutions
  dframe <- reqd_record[dframe, on = "mcid"]

  # find lower and upper limits by institution
  inst <- reqd_record[, .(term, institution)]
  inst <- unique(inst)
  inst <- inst[, .(lower_limit = min(term), upper_limit = max(term)),
    by = "institution"
  ]
  # join institution limits
  dframe <- inst[dframe, on = "institution"]
  dframe <- unique(dframe)

  # ---------- data sufficiency labels

  # one row per ID
  dframe[, data_sufficiency := fcase(
    timely_term > upper_limit, "exclude-upper",
    term_i == lower_limit, "exclude-lower",
    default = "include"
  )]

  # ---------- prepare to return

  dframe <- dframe[, .SD, .SDcols = return_vars]
  setkey(dframe, NULL)
  setattr(dframe, "class", prior_class)
  dframe[]
}
