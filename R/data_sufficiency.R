# See R/roxygen.R for documentation below that uses inline R code
#
# ---------- deprecated version
#
#' midfieldr deprecated functions
#' @param dframe `r dframe`
#' @param midfield_term `r midfield_x("\\[term\\]")`
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
  data_sufficiency(dframe = dframe, midfield_table = midfield_term)
}
NULL
#
# ---------- current version
#
#' Determine data sufficiency
#'
#' For each student in a data frame, determine whether or not their record
#' lies sufficiently within their institution's data range to unambiguously
#' assess their completion status and if so include them in the study
#' population. Label  each row with this *data sufficiency* result (include
#' or exclude) and add columns that support the findings.
#'
#' *Timely completion* means completing a program no later than a specified
#' interval---typical values are 4, 6, or 8 years after admission. The
#' *data sufficiency* criterion states that student records must be limited
#' to those for which available data from an institution are sufficient to
#' assess timely completion without biased counts of completers or
#' non-completers. Such biases occur at the lower and upper bounds of an
#' institution's data range. Affected students must be identified and
#' excluded to prevent false summary counts.
#'
#' In our heuristic, the criteria is implemented via two filters. Rows are
#' labeled for exclusion when: 1) a student ID is extant in the non-summer
#' lower limit of an institution's data range; or 2) a student ID has a
#' timely completion term that exceeds the upper limit of the institution's
#' data range. The results are documented in the output.
#'
#' @param dframe `r dframe` with required variables
#'        `{mcid, term_i, timely_term}.` The latter two variables are
#'        provided by `timely_term().`
#'
#' @param midfield_table `r midfield_x("term")` with required variables
#'        `{mcid, term, institution}.`
#'
#' @returns Data frame with the following properties:
#' * `r df_class_preserved`
#' * `r rows_not_modified`
#' * Variables `{mcid, term_i, timely_term}` are retained. All other
#'   columns (if any) are dropped and the following variables are added:
#'   - `institution.` &nbsp; Character. Institution in which the student is
#'      enrolled in the given term. Extracted from `midfield_table.` The
#'      limits given in the next two columns are specific to the institution.
#'   - `lower_limit.` &nbsp; Character. Initial term of an institution's
#'      data range, encoded `YYYYT`. Extracted from `midfield_table.`
#'      Compared to `term_i` to determine the lower-limit exclusion.
#'   - `upper_limit.` &nbsp; Character. Final term of an institution's
#'      data range, encoded `YYYYT`. Extracted from `midfield_table.`
#'      Compared to `timely_term` to determine upper-limit exclusion.
#'   - `data_sufficiency.` &nbsp; Character. Possible values are "include",
#'      if the data are sufficient; and "exclude-lower" or "exclude-upper"
#'      if not, indicating at which boundary of the data range the ambiguity
#'      occurs.
#' * `r not_preserved`
#'
#' @example man/examples/exa_data_sufficiency.R
#' @export
#'
data_sufficiency <- function(dframe, midfield_table = term) {
  #
  # ---------- assign active column names
  
  reqd_dframe_vars <- c("mcid", "term_i", "timely_term")
  reqd_table_vars <- c("mcid", "term", "institution")
  added_vars <- c("institution", "lower_limit", "upper_limit", "data_sufficiency")
  
  # ---------- base R checks (all data frame classes)
  
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
  
  # ---------- preparation
  
  # to restore class except for groups in tibbles
  prior_class <- setdiff(class(dframe), "grouped_df")

  # prevent by-ref changes propagating to global env
  dframe <- copy(dframe)
  setDT(dframe)
  midf_table <- copy(midfield_table)
  setDT(midf_table)

  # bind names due to NSE notes in R CMD check
  data_sufficiency <- NULL
  idx <- NULL
  lower_limit <- NULL
  term_i <- NULL
  timely_term <- NULL
  upper_limit <- NULL
  
  # ---------- do the work
  
  # subset required variables
  dframe <- dframe[, .SD, .SDcols = reqd_dframe_vars]
  dframe <- unique(dframe, na.rm = TRUE)
  midf_table <- midf_table[, .SD, .SDcols = reqd_table_vars]
  midf_table <- unique(midf_table, na.rm = TRUE)

  # add temp col to restore row order
  dframe[, idx := .I]

  # join institutions
  dframe <- midf_table[dframe, on = "mcid"]

  # find lower and upper limits by institution
  x <- midf_table[, .(term, institution)]
  x <- unique(x)
  x <- x[, .(lower_limit = min(term), upper_limit = max(term)),
    by = "institution"
  ]
  # join institution limits
  dframe <- x[dframe, on = "institution"]
  
  # ---------- data sufficiency labels
  
  # one row per ID
  dframe[, data_sufficiency := fcase(
    timely_term > upper_limit, "exclude-upper",
    term_i == lower_limit, "exclude-lower",
    default = "include"
  )]
  
  # ---------- prepare to return
  
  # restore row order
  setkey(dframe, idx)

  # drop temp cols, restore col order, ensure unique rows
  dframe <- dframe[, .SD, .SDcols = c(reqd_dframe_vars, added_vars)]
  dframe <- unique(dframe)

  # restore class
  setkey(dframe, NULL)
  setattr(dframe, "class", prior_class)

  # done
  dframe[]
}
