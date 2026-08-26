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
#' @param midf_table `r midfield_x("term")` with required variables
#'        `{mcid, term, institution}.`
#' @returns Data frame with the following properties:
#' * `r df_class_preserved`
#' * `r rows_not_modified`
#' * `r new_cols_added`
#'   - `data_range` &nbsp; Character. Institution data range, encoded
#'     `YYYYT-YYYYT,` indicating the institution's first and last term in the
#'     database. Extracted from `midf_table.`
#'   - `data_sufficiency` &nbsp; Character. Possible values are "include",
#'      "exclude-lower," and "exclude-upper."
#' @references R. Layton, R. Long, M. Ohland, M. Orr, and S. Lord (2026), "Data sufficiency,"  \url{https://midfieldr.github.io/midfieldr/articles/art-020-data-sufficiency.html}
#' @example man/examples/exa_data_sufficiency.R
#' @export
#'
data_sufficiency <- function(dframe, midf_table = term) {
  #
  # ---------- initial assertions
  
  # data frames
  qassert(dframe, "d+")
  qassert(midf_table, "d+")

  # ---------- declarations

  # active column names
  reqd_dframe_vars <- c("mcid", "term_i", "timely_term")
  reqd_table_vars <- c("mcid", "term", "institution")
  added_vars <- c("data_range", "data_sufficiency")

  # bind names for R CMD check
  data_range <- NULL
  term_i <- NULL
  IDX <- NULL
  LOWER_LIMIT <- NULL
  UPPER_LIMIT <- NULL

  # ---------- variable assertions
  
  utils_check_reqd_vars(dframe, reqd_dframe_vars)
  utils_check_reqd_vars(midf_table, reqd_table_vars)
  
  # ---------- preparation

  # to restore class except grouped tibbles
  prior_class <- setdiff(class(dframe), "grouped_df")

  # prevent by-ref changes propagating to global env
  dframe <- copy(dframe)
  midf_table <- copy(midf_table)

  # setDT then reqd_vars as.char, na.omit, unique
  dframe <- utils_prep_DT(dframe, reqd_dframe_vars)
  midf_table <- utils_prep_DT(midf_table, reqd_table_vars)

  # dframe columns to protect and return
  protected_vars <- setdiff(colnames(dframe), added_vars)
  returned_vars <- c(protected_vars, added_vars)

  # select columns
  dframe <- dframe[, .SD, .SDcols = protected_vars]
  midf_table <- midf_table[, .SD, .SDcols = reqd_table_vars]

  # prevent overwriting by temporary columns
  temp_vars <- c("idx", "lower_limit", "upper_limit", "institution")
  temp_vars <- utils_edit_colnames(dframe, temp_vars)
  idx <- temp_vars[1]
  lower_limit <- temp_vars[2]
  upper_limit <- temp_vars[3]
  institution <- temp_vars[4]

  # for restoring row order
  dframe[, IDX := .I, env = list(IDX = idx)]

  # ---------- do the work
  
  # add institution data range limits
  midf_table[, `:=`(
    LOWER_LIMIT = min(term),
    UPPER_LIMIT = max(term)
  ),
  by = "institution",
  env = list(
    LOWER_LIMIT = lower_limit,
    UPPER_LIMIT = upper_limit
  )
  ]
  midf_table[, term := NULL]

  # edit name before join
  setnames(midf_table, old = "institution", new = institution)
  dframe <- midf_table[dframe, on = "mcid"]

  # compare student terms to institution range limits
  dframe[, data_sufficiency := fcase(
    timely_term > UPPER_LIMIT, "exclude-upper",
    term_i == LOWER_LIMIT, "exclude-lower",
    default = "include"
  ), env = list(
    LOWER_LIMIT = lower_limit,
    UPPER_LIMIT = upper_limit
  )]

  # combine limits for the data_range variable
  dframe[, data_range := paste(LOWER_LIMIT, UPPER_LIMIT, sep = "-"),
    env = list(
      LOWER_LIMIT = lower_limit,
      UPPER_LIMIT = upper_limit
    )
  ]

  # ---------- prepare to return
  # restore row and column order, select return columns, restore class
  dframe <- utils_prepare_return(dframe, idx, returned_vars, prior_class)

  # done
  dframe[]
}


# ========== deprecated version ==========
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
