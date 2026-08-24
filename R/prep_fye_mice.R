# See R/roxygen.R for documentation below that uses inline R code

#' Prepare FYE data for imputation
#'
#' Constructs a data frame of students ever enrolled in First-Year Engineering
#' (FYE) programs at their institutions based on information in the MIDFIELD
#' (or equivalent) `student` and `term` data tables. Conditions the data for
#' use as an input to the mice R package for multiple imputation. Sets up
#' three variables as predictors  (institution, race/ethnicity, and sex) and
#' one variable to be imputed (program CIP code) keyed by student ID.
#'
#' @section Background:  At some US institutions, engineering students are
#' required to complete a First-Year Engineering (FYE) program as a prerequisite
#' for declaring an engineering major. FYE students who then transition to a
#' degree-granting engineering program are  typically counted as "starters" in
#' that program for purposes of calculating, for example, graduation rates.
#'
#' This approach invariably undercounts starters and over-estimates associated
#' metrics because it fails to account for FYE students who change majors
#' (never enrolling in an engineering major) or drop out of the database
#' altogether. Had the FYE program not been required, they would have enrolled
#' in their preferred engineering program---the count of starters would have
#' increased and a metric such as graduation rate would have decreased.
#'
#' To include FYE students when a count of starters is needed, we estimate an
#' "FYE proxy", that is, the 6-digit CIP codes of the degree-granting
#' engineering programs that FYE students would have declared had they not been
#' required to enroll in FYE. The purpose of `prep_fye_mice()` is to prepare
#' the data for imputing the unknown CIP codes.
#'
#' @section Method: The function extracts all terms for all FYE students and
#' identifies all engineering programs in which they were ever enrolled. A
#' `proxy` variable is added with one of the following values:
#' \enumerate{
#' \item{If a student record includes at least one, non-FYE, degree-granting
#'       engineering program, the CIP code of the first such program is
#'       returned as the student's FYE proxy.}
#' \item{If not, the proxy is NA and is treated as a missing value to be
#'       imputed by `mice()`.}
#' }
#'
#' Notes:
#' * Missing values (NA) in the required columns are removed. However, a
#'   value of "unknown" in a predictor column, e.g., race/ethnicity or sex,
#'   is acceptable.
#' * After running `prep_fye_mice()` but before running `mice()`, one can edit
#'   the predictor variables if desired. The institution variable should remain
#'   to ensure that a student's imputed program is available at their
#'   institution.
#' * The resulting data frame is ready for use as input for the mice package,
#'   with all variables except `mcid` returned as factors.
#'
#' @param m_student `r dframe` with required character variables
#'        `{mcid, race, sex}.` Typically based on one's original,
#'        unfiltered `student` source data without regard to data sufficiency.
#' @param m_term `r dframe` with required character variables
#'        `{mcid, term, cip6, institution}.` Typically based on one's original,
#'        unfiltered `term` source data without regard to data sufficiency.
#' @param fye_cip `r dframe` with required character variables
#'        `{institution, fye_cip6}.` Default has one institution
#'        value (`"Institution J"`) and one CIP code value (`"140102"`),
#'        compatible with midfielddata practice data and the midfieldr "toy"
#'        datasets.
#' @returns Data frame with the following properties:
#' * `r df_class_preserved`
#' * Rows: One row for every degree-seeking FYE student.
#' * Columns: Conditioned for later use as an input to the mice R
#'   package for multiple imputation as follows:
#'   - `mcid` &nbsp; Character, anonymized student identifier.
#'   - `race` &nbsp; Factor, race/ethnicity from the `student` input data
#'      frame. An imputation predictor variable.
#'   - `sex` &nbsp; Factor, sex from the `student` input data
#'      frame. An imputation predictor variable.
#'   - `institution` &nbsp; Factor, anonymized institution name from the
#'      `term` data frame. An imputation predictor variable.
#'   - `proxy` &nbsp; Factor, 6-digit CIP code of a student's known,
#'            first degree-granting engineering program or NA representing missing
#'            values to be imputed.
#' @example man/examples/exa_prep_fye_mice.R
#' @export
#'
prep_fye_mice <- function(m_student, m_term, fye_cip = NULL) {
  #
  # data frame with at least one column, missing values acceptable
  qassert(m_student, "d+")
  qassert(m_term, "d+")

  # ---------- declarations

  fye_cip <- fye_cip %?%
    data.frame(
      institution = "Institution J",
      fye_cip6 = "140102"
    )

  # active column names
  reqd_student_vars <- c("mcid", "race", "sex")
  reqd_term_vars <- c("mcid", "institution", "term", "cip6")
  reqd_fye_cip_vars <- c("institution", "fye_cip6")
  returned_vars <- c("mcid", "institution", "race", "sex", "proxy")

  # bind names for R CMD check
  fye_cip6 <- NULL
  proxy <- NULL

  # ---------- base R checks (all data frame classes)

  # data frame with at least one column, missing values prohibited
  qassert(fye_cip, "D+")

  # FYE CIP codes
  codes_var <- unique(fye_cip[["fye_cip6"]])
  cip_digits <- sort(unique(unlist(strsplit(codes_var, split = character(0)))))

  # - 6 characters per code
  qassert(unique(nchar(codes_var)), "I1[6,6]")

  # - must be engineering (start with "14")
  assert_subset(
    substr(codes_var, 1, 2),
    choices = c("14")
  )

  # - string of numbers only
  assert_subset(
    cip_digits,
    choices = c("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
  )

  # ---------- preparation

  # to restore class except grouped tibbles
  prior_class <- setdiff(class(m_student), "grouped_df")

  # prevent by-ref changes propagating to global env
  m_student <- copy(m_student)
  m_term <- copy(m_term)
  fye_cip <- copy(fye_cip)

  # setup with setDT() and unique() plus checks on required variables
  m_student <- utils_reqd_variables(m_student, reqd_student_vars)
  m_term <- utils_reqd_variables(m_term, reqd_term_vars)
  fye_cip <- utils_reqd_variables(fye_cip, reqd_fye_cip_vars)

  # ---------- do the work

  # select columns
  m_student <- m_student[, .SD, .SDcols = reqd_student_vars]
  m_term <- m_term[, .SD, .SDcols = reqd_term_vars]
  fye_cip <- fye_cip[, .SD, .SDcols = reqd_fye_cip_vars]

  # limit to degree-seeking
  m_term <- m_student[m_term, on = "mcid", nomatch = NULL]

  # ever in engineering
  ever_engr <- m_term[cip6 %like% "^14"]

  # join FYE CIP codes from fye_cip input
  ever_engr <- fye_cip[ever_engr, on = "institution"]

  # ever in FYE, one row per ID
  ever_fye <- ever_engr[cip6 == fye_cip6, .(mcid, race, sex, institution)]
  ever_fye <- unique(ever_fye)

  # fye IDs ever in another engineering program
  ever_fye_ID <- ever_fye[, .(mcid)]
  fye_engr <- ever_fye_ID[ever_engr, on = "mcid", nomatch = NULL]
  fye_engr <- fye_engr[cip6 != fye_cip6, .(mcid, term, cip6)]

  # proxy is first non-FYE engr major
  setkeyv(fye_engr, c("mcid", "term"))
  engr_proxy <- fye_engr[, .SD[1], by = "mcid"]
  engr_proxy <- engr_proxy[, .(mcid, proxy = cip6)]
  setkey(engr_proxy, NULL)

  # join proxy to ever FYE, introduces proxy NAs
  fye <- engr_proxy[ever_fye, on = "mcid"]

  # convert to factors to prepare for mice()
  factor_cols <- c("race", "sex", "institution", "proxy")
  fye[, names(.SD) := lapply(.SD, factor), .SDcols = factor_cols]

  # ---------- prepare to return
  # restore row and column order, select return columns, restore class
  fye <- utils_prepare_return(fye,
    idx = NULL,
    returned_vars,
    prior_class
  )
  # done
  fye[]
}
