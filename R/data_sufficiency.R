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
#' Build a data sufficiency data frame
#'
#' Assembles a data frame with one row per student per institution with
#' columns for student ID, their initial term and timely completion term,
#' the institution and its data range limits, and the *data sufficiency*
#' assessment to include (or not) the student in the study population.
#' Depends on `timely_term()` being run beforehand.
#'
#' *Data sufficiency* is an assessment whether a student record lies
#' sufficiently within their institution's data range to unambiguously
#' assess their completion status and if so include them in the study
#' population. Not performing the necessary exclusions produces biased
#' counts of completers and non-completers. Such biases occur at the lower
#' and upper bounds of an institution's data range.
#'
#' The student ID, initial term, and timely completion term are pulled
#' from `dframe`; all other columns are dropped. Institutions and their
#' data range limits (upper and lower) are extracted and joined from
#' `midfield_table.` Rows are labeled with data sufficiency values as
#' follows: "exclude-lower" when the initial term matches the data range
#' lower limit; "exclude-upper" when the timely completion term exceeds
#' the data range upper limit; and "include" otherwise.
#'
#' If a student is enrolled in more than one institution in the database, an
#' exclusion at any institution is applied to all rows with that ID.
#'
#' @param dframe `r dframe` with required variables
#'        `{mcid, term_i, timely_term}.`
#'
#' @param midfield_table `r midfield_x("term")` with required variables
#'        `{mcid, term, institution}.`
#'
#' @returns Data frame with the following properties:
#' * `r df_class_preserved`
#' * One row per student per institution (accounts for the possibility of
#'   a student enrolled in more than one institution in the database).
#' * Columns returned:
#'   - `mcid` &nbsp; Pulled from `dframe.`
#'   - `term_i` &nbsp; Pulled from `dframe.`
#'   - `timely_term` &nbsp; Pulled from `dframe.`
#'   - `institution.` &nbsp; Joined from `midfield_table.`
#'   - `lower_limit.` &nbsp; Character. Initial term of an institution's
#'      data range, encoded `YYYYT`. Extracted from `midfield_table.`
#'   - `upper_limit.` &nbsp; Character. Final term of an institution's
#'      data range, encoded `YYYYT`. Extracted from `midfield_table.`
#'   - `data_sufficiency.` &nbsp; Character. Possible values are "include",
#'      "exclude-lower," and "exclude-upper."
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

  # join institutions, allows for student enrolled in more than one institution
  x <- midf_table[, .(mcid, institution)]
  x <- unique(x)
  dframe <- x[dframe, on = "mcid"]

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

  # for rare case of student enrolled in two institutions  ##### have to add test
  # may be "include" at one but "exclude" at the other
  incl <- dframe[data_sufficiency %ilike% "include"]
  excl <- dframe[data_sufficiency %ilike% "exclude"]
  common_ids <- intersect(incl[["mcid"]], excl[["mcid"]])
  for (j in seq_along(common_ids)) {
    excl_value <- excl[mcid == common_ids[j], (data_sufficiency)]
    # all rows with this ID get the exclusion
    dframe[mcid == common_ids[j], data_sufficiency := excl_value]
  }

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
