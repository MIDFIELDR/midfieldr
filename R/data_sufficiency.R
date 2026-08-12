# See R/roxygen.R for documentation below that uses inline R code

#' Determine data sufficiency
#'
#' Determine institutional *data sufficiency* for each student in a data frame
#' and add columns that support the findings.
#'
#' In most studies, the population must satisfy the *data sufficiency*
#' criterion, developed as follows:
#' - Program *completion* means satisfying the requirements for a first
#' baccalaureate degree.
#' - Completion *status* is "timely" if accomplished within a set time
#' span, typically 4, 6, or 8 years after admission depending on the
#' definition one adopts. The *timely-completion term* is the term at the
#' end of that span.
#' - The *data sufficiency* test identifies students whose actual admission
#' term and projected timely completion term both lie within their
#' institution's data range. These are the students for whom completion
#' status---timely or otherwise---can be positively asserted, and are
#' therefore the only students included a population.
#'
#' To apply this criterion, our heuristic labels a row (keyed by student ID)
#' "exclude-upper" when a student's timely completion term exceeds the upper
#' limit of their institution's data range;  "exclude-lower" when their initial
#' term matches the non-summer, lower limit of the data range; and "include"
#' otherwise. The rationale for these specific filters is explained in our
#' data sufficiency article (see references).
#'
#' @param dframe `r dframe` with required variables
#'        `{mcid, term_i, timely_term}.`
#'
#' @param midf_table `r midfield_x("term")` with required variables
#'        `{mcid, term, institution}.`
#'
#' @returns Data frame with the following properties:
#' * `r df_class_preserved`
#' * `r rows_not_modified`
#' * `r new_cols_added`
#'   - `institution` &nbsp; Character. Name of the institution at which a
#'      student is enrolled in a term.
#'   - `lower_limit` &nbsp; Character. Initial term of an institution's
#'      data range, encoded `YYYYT`. Extracted from `midf_table.`
#'   - `upper_limit` &nbsp; Character. Final term of an institution's
#'      data range, encoded `YYYYT`. Extracted from `midf_table.`
#'   - `data_sufficiency` &nbsp; Character. Possible values are "include",
#'      "exclude-lower," and "exclude-upper."
#'
#' @references R. Layton, R. Long, M. Ohland, M. Orr, and S. Lord (2026), "Data sufficiency,"  \url{https://midfieldr.github.io/midfieldr/articles/art-020-data-sufficiency.html}
#'
#' @example man/examples/exa_data_sufficiency.R
#' @export
#'
data_sufficiency <- function(dframe, midf_table = term) {
  #
  # ---------- assign active column names

  reqd_dframe_vars <- c("mcid", "term_i", "timely_term")
  reqd_table_vars <- c("mcid", "term", "institution")
  added_vars <- c("institution", "lower_limit", "upper_limit", "data_sufficiency")

  # ---------- base R checks (all data frame classes)

  # data frame assessment
  qassert(dframe, "d+")
  qassert(midf_table, "d+")

  # required columns
  assert_names(colnames(dframe), must.include = reqd_dframe_vars)
  assert_names(colnames(midf_table), must.include = reqd_table_vars)

  # class of required columns
  for (var in reqd_dframe_vars) qassert(dframe[[var]], "s+")
  for (var in reqd_table_vars) qassert(midf_table[[var]], "s+")

  # ---------- preparation

  # to restore class except grouped tibbles
  prior_class <- setdiff(class(dframe), "grouped_df")

  # prevent by-ref changes propagating to global env
  dframe <- copy(dframe)
  setDT(dframe)
  midf_table <- copy(midf_table)
  setDT(midf_table)

  # avoid overwriting columns that match names of temporary columns
  init_temp_vars <- c("idx")
  temp_vars <- edit_new_col_names(dframe, init_temp_vars)
  idx_chr <- temp_vars[1]
  
  # avoid overwriting these variables
  potential_overwrite_vars <- c("institution")
  non_overwrite_vars <- edit_new_col_names(dframe, potential_overwrite_vars)
  inst_chr <- non_overwrite_vars[1]

  # bind names due to NSE notes in R CMD check
  data_sufficiency <- NULL
  lower_limit <- NULL
  term_i <- NULL
  timely_term <- NULL
  upper_limit <- NULL
  IDX <- NULL
  INST <- NULL

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
  dframe[, IDX := .I,
    env = list(IDX = idx_chr)
  ]

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
  setkeyv(dframe, idx_chr)

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
  data_sufficiency(dframe = dframe, midf_table = midfield_term)
}
NULL
