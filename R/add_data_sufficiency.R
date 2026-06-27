# See R/roxygen.R for documentation below that uses inline R code

#' Determine data sufficiency for every student
#'
#' Add columns to a data frame of student-level records that indicate whether
#' an observation should be included or excluded based on sufficient
#' information from the institution. Because the time span of MIDFIELD term
#' data varies by institution, each has their own lower and upper bounds. For
#' some student records, being at or near these bounds creates unavoidable
#' ambiguity when trying to assess degree completion. Such records must be
#' identified and in most cases excluded to prevent false summary counts.
#'
#' The data sufficiency criterion states that student records are limited to
#' those for which available data are sufficient to assess timely completion
#' without biased counts of completers or non-completers. In practice, the
#' criteria is implemented via two filters. Rows are labeled for exclusion
#' when: 1) a student ID is extant in the non-summer lower limit of an
#' institution's data range; or 2) a student ID has a timely completion term
#' that exceeds the upper limit of the institution's data range.
#'
#' The new columns are:
#'
#' * `term_i` Initial term of a student's longitudinal record, encoded `YYYYT`.
#'    Extracted from `term`.
#'
#' * `lower_limit` Character. Initial term of an institution's data range,
#'    encoded `YYYYT`. Extracted from `term`.
#'
#' * `upper_limit` Character. Final term of an institution's data range,
#'    encoded `YYYYT`. Extracted from `term`.
#'
#' * `data_sufficiency` Character. Possible values are "include",
#'    "exclude_lower", and "exclude-upper". A row is labeled "include" if the
#'    data are sufficient; and "exclude-lower" or "exclude-upper" if not,
#'    indicating at which boundary of the data range the ambiguity occurs.
#'
#' @param dframe Working data frame of student-level records to which
#'        data-sufficiency columns are to be added. Required variables are
#'        `mcid` and `timely_term`.
#'
#' @param midfield_term MIDFIELD `term` data table or equivalent with
#'        required variables `mcid`, `institution`, and `term`.
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
#' @example man/examples/exa_add_data_sufficiency.R
#' @export
#'
add_data_sufficiency <- function(dframe, midfield_term = term) {
  # ---------- checks, use base R syntax

  # required arguments
  qassert(dframe, "d+")
  qassert(midfield_term, "d+")

  # required columns
  assert_names(colnames(dframe),
    must.include = c("mcid", "timely_term")
  )
  assert_names(colnames(midfield_term),
    must.include = c("mcid", "institution", "term")
  )

  # class of required columns
  qassert(dframe[["mcid"]], "s+")
  qassert(dframe[["timely_term"]], "s+")
  qassert(midfield_term[["mcid"]], "s+")
  qassert(midfield_term[["institution"]], "s+")
  qassert(midfield_term[["term"]], "s+")

  # ---------- preparation

  # to restore class (tibble, data.frame, etc.) before return
  prior_class <- class(dframe)

  # Copy and setDT() non-DT input. Prevents by-ref changes.
  # No change to DT class input. By-ref changes remain active.
  dframe <- copy_setDT_non_DT(dframe)
  midfield_term <- copy_setDT_non_DT(midfield_term)

  # bind names due to NSE notes in R CMD check
  data_sufficiency <- NULL
  timely_term <- NULL
  upper_limit <- NULL
  lower_limit <- NULL
  term_i <- NULL

  # ---------- do the work

  # variables added by this function and functions called (if any)
  inst_limits_cols <- c("lower_limit", "upper_limit")
  new_cols <- c("term_i", inst_limits_cols, "data_sufficiency")

  # retain original variables NOT in the vector of new columns
  old_cols <- find_old_cols(dframe, new_cols)
  dframe <- dframe[, .SD, .SDcols = old_cols]

  # begin
  DT <- copy(dframe)

  # add initial term term_i
  DT <- add_initial_term(DT, midfield_term)

  # obtain lower and upper institution data limits
  DT <- add_inst_limits(DT, midfield_term)

  # default is include
  DT[, data_sufficiency := "include"]

  # exclude if TC term exceeds upper limit
  DT <- DT[timely_term > upper_limit, data_sufficiency := "exclude-upper"]

  # exclude if term_i == lower_limit
  DT <- DT[term_i == lower_limit, data_sufficiency := "exclude-lower"]

  # remove all but essential variables
  DT <- DT[, .SD, .SDcols = c("mcid", new_cols)]

  # ensure no duplicate rows
  setkeyv(DT, "mcid")
  DT <- DT[, .SD[1], by = "mcid"]

  # left join new columns to dframe by key(s)
  setkeyv(dframe, "mcid")
  dframe <- DT[dframe]

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

# ------------------------------------------------------------------------

# Add upper and lower limits of institution data range

add_inst_limits <- function(dframe, midfield_term) {
  # remove keys if any
  on.exit(setkey(dframe, NULL))
  on.exit(setkey(midfield_term, NULL), add = TRUE)

  # ensure data.table format, changes by reference
  setDT(dframe)
  setDT(midfield_term)

  # add_institution() in utils.R
  if (!"institution" %chin% names(dframe)) {
    dframe <- add_institution(dframe, midfield_term = midfield_term)
  }

  # variables added by this function
  new_cols <- c("lower_limit", "upper_limit")

  # retain original variables NOT in the vector of new columns
  old_cols <- find_old_cols(dframe, new_cols)
  dframe <- dframe[, .SD, .SDcols = old_cols]

  # obtain new_cols keyed by institution,
  cols_we_want <- c("institution", "term")
  DT <- midfield_term[, .SD, .SDcols = cols_we_want]
  DT <- DT[, list(
    lower_limit = min(term),
    upper_limit = max(term)
  ), by = "institution"]

  # ensure no duplicate rows
  DT <- unique(DT)

  # left join new columns to dframe by key(s)
  setkeyv(DT, "institution")
  setkeyv(dframe, "institution")
  dframe <- DT[dframe]

  # enable printing (see data.table FAQ 2.23)
  dframe[]
}
