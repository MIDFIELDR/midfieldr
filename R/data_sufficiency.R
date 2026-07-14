# See R/roxygen.R for documentation below that uses inline R code

#' Determine data sufficiency
#'
#' Determine *data sufficiency* for each student in a data frame and add
#' columns that support the findings.
#'
#' *Data sufficiency* is a criterion for including or excluding a student
#' record based on the feasibility of determining their completion status given
#' the range of data available from their institution. If determining
#' completion status is feasible, the student record is included in the
#' study population; if not, they must be excluded to avoid biased counts
#' of completers and non-completers. Such biases occur at the upper and lower
#' bounds of an institution's data range.
#'
#' To apply this criterion, our heuristic labels a row
#' "exclude-upper" when a student's timely completion term exceeds the upper
#' limit of their institution's data range;  "exclude-lower" when their initial
#' term matches the lowest non-summer limit of the data range; and "include"
#' otherwise. The rationale for these specific filters is
#' explained in our data sufficiency article (see references). In most
#' studies, the population must satisfy the data sufficiency requirement.
#'
#' @param dframe `r dframe` with required variables
#'        `{mcid, term_i, timely_term}.`
#'
#' @param midfield_table `r midfield_x("term")` with required variables
#'        `{mcid, term, institution}.`
#'
#' @returns Data frame with the following properties:
#' * `r df_class_preserved`
#' * `r rows_not_modified`
#' * `r new_cols_added`
#'   - `institution` &nbsp; Character. Name of the institution at which a
#'      student is enrolled in a term.
#'   - `lower_limit` &nbsp; Character. Initial term of an institution's
#'      data range, encoded `YYYYT`. Extracted from `midfield_table.`
#'   - `upper_limit` &nbsp; Character. Final term of an institution's
#'      data range, encoded `YYYYT`. Extracted from `midfield_table.`
#'   - `data_sufficiency` &nbsp; Character. Possible values are "include",
#'      "exclude-lower," and "exclude-upper."
#'
#' @example man/examples/exa_data_sufficiency.R
#' @references Richard Layton, Russell Long, Matthew Ohland, Marisa Orr, and Susan Lord (2026) Data sufficiency, https://midfieldr.github.io/midfieldr/articles/art-020-data-sufficiency.html
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

  # save columns except those being added
  saved_vars <- setdiff(colnames(dframe), added_vars)
  return_vars <- c(saved_vars, added_vars)

  # drop added vars, omit NA in required vars
  dframe <- dframe[, .SD, .SDcols = saved_vars]
  dframe <- na.omit(dframe, cols = reqd_dframe_vars)
  dframe <- unique(dframe)

  # keep required vars and omit NAs
  midf_table <- midf_table[, .SD, .SDcols = reqd_table_vars]
  midf_table <- na.omit(midf_table, cols = reqd_table_vars)
  midf_table <- unique(midf_table)

  # add temp col to restore row order
  dframe[, idx := .I]

  # join institutions
  x <- midf_table[, .(mcid, institution)]
  x <- unique(x)
  dframe <- x[dframe, on = "mcid"]

  # join lower and upper limits by institution
  x <- midf_table[, .(lower_limit = min(term), upper_limit = max(term)),
    by = "institution"
  ]
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
  dframe <- dframe[, .SD, .SDcols = return_vars]
  dframe <- unique(dframe)

  # restore class
  setkey(dframe, NULL)
  setattr(dframe, "class", prior_class)

  # done
  dframe[]
}


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
