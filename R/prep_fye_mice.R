# See R/roxygen.R for documentation below that uses inline R code

#' Prepare FYE data for imputation
#'
#' Constructs a data frame of students ever enrolled in First-Year Engineering
#' (FYE) programs based on information in the MIDFIELD
#' (or equivalent) `student` and `term` data tables. Conditions the data for
#' use as an input to the mice R package for multiple imputation. Sets up
#' three variables as predictors  (institution, race/ethnicity, and sex) and
#' one variable to be imputed (program CIP code) keyed by student ID.
#'
#' @section Background:  At some US institutions, engineering students are
#' required to complete a First-Year Engineering (FYE) program as a
#' prerequisite for enrolling in an engineering major. When one of these
#' programs calculates a metric that requires a count of starters, e.g.,
#' graduation rate, typically only those students entering the degree-granting
#' program post-FYE are counted.
#'
#' Some FYE students do not subsequently enter an engineering major---they may
#' switch to a non-engineering program or leave the database entirely. Had FYE
#' not been required, they would have instead been admitted to a degree-granting engineering program of their choice, increasing the count of starters in those
#' programs resulting in a lower graduation rate when they switched majors or
#' left the database.
#'
#' To improve the count of starters for FYE institutions, we introduce the
#' concept of  "FYE proxies", that is, 6-digit CIP codes of the degree-granting
#' engineering programs that FYE students might have declared had they not
#' been required to enroll in FYE.
#'
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
#' This function does not perform the imputation. It produces a data frame
#' that is ready to be used as an input to the `mice()` function in a
#' separate step.
#'
#'
#' Notes:
#' * Missing values (NA) in the required columns are removed. However, a
#'   value of "unknown" in a predictor column, e.g., race/ethnicity or sex,
#'   is acceptable.
#' * Accommodates only one 6-digit FYE CIP code per institution.
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
#' @param fye_cip Character, one 6-digit CIP code used for FYE programs. Default
#'        "140102", applied to all institutions except those (if any)
#'        optionally defined by user in `alt_fye.`
#' @param ... `r param_dots`
#' @param alt_fye `r dframe` with character variables
#'        `{institution, alt_cip}.` For users with institutions that use
#'        a 6-digit CIP code other than the value in `fye_cip` for their FYE
#'        programs. One FYE code per institution.
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
#'      first degree-granting engineering program or NA representing missing
#'      values to be imputed.
#' @example man/examples/exa_prep_fye_mice.R
#' @export
#'
prep_fye_mice <- function(m_student,
                          m_term,
                          fye_cip = NULL,
                          ...,
                          alt_fye = NULL) {
  #
  # ---------- initial assertions
  
  # data frames
  qassert(m_student, "d+")
  qassert(m_term, "d+")

  # arguments after ... must be named
  wrapr::stop_if_dot_args(
    substitute(list(...)),
    "Arguments after ... must be named, as in arg = val."
  )
  
  # ---------- declarations

  # active column names
  reqd_student_vars <- c("mcid", "race", "sex")
  reqd_term_vars <- c("mcid", "institution", "term", "cip6")
  reqd_fye_alt_vars <- c("institution", "alt_cip")
  returned_vars <- c("mcid", "institution", "race", "sex", "proxy")

  # optional defaults
  fye_cip <- fye_cip %?% "140102"
  alt_fye <- alt_fye %?% data.frame(
    institution = character(),
    alt_cip = character()
  )
  
  # bind names for R CMD check
  fye_code <- NULL
  proxy <- NULL
  
  # ---------- variable assertions
  
  utils_check_reqd_vars(m_student, reqd_student_vars)
  utils_check_reqd_vars(m_term, reqd_term_vars)
  utils_check_reqd_vars(alt_fye, reqd_fye_alt_vars)
  qassert(fye_cip, "s1") # string, length 1
  qassert(alt_fye, "d*") # data frame, any length

  # FYE CIP codes
  codes_var <- unique(c(fye_cip, alt_fye[["alt_cip"]]))
  cip_digits <- sort(unique(unlist(strsplit(codes_var, split = character(0)))))

  # -- 6 characters per code
  qassert(unique(nchar(codes_var)), "I1[6,6]")

  # -- must be engineering (start with "14")
  assert_subset(
    substr(codes_var, 1, 2),
    choices = c("14")
  )
  # -- string of numbers only
  assert_subset(
    cip_digits,
    choices = c("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
  )

  # ---------- preparation

  # for restoring class except grouped tibbles
  prior_class <- setdiff(class(m_student), "grouped_df")

  # prevent by-ref changes propagating to global env
  m_student <- copy(m_student)
  m_term <- copy(m_term)
  alt_fye <- copy(alt_fye)
  
  # setDT then reqd_vars as.char, na.omit, unique
  m_student <- utils_prep_DT(m_student, reqd_student_vars)
  m_term <- utils_prep_DT(m_term, reqd_term_vars)
  alt_fye <- utils_prep_DT(alt_fye, reqd_fye_alt_vars)

  # select columns
  m_student <- m_student[, .SD, .SDcols = reqd_student_vars]
  m_term <- m_term[, .SD, .SDcols = reqd_term_vars]
  alt_fye <- alt_fye[, .SD, .SDcols = reqd_fye_alt_vars]
  
  # ---------- do the work
  
  # limit to degree-seeking
  m_term <- m_student[m_term, on = "mcid", nomatch = NULL]

  # construct data frame of institutions
  m_inst <- m_term[, .(institution)]
  m_inst <- unique(m_inst)

  # left-join, add fye_code column to institutions
  m_inst <- alt_fye[m_inst, on = "institution"]
  setnames(m_inst, old = "alt_cip", new = "fye_code")
  
  # replace CIP NAs with standard FYE code
  m_inst[is.na(fye_code), fye_code := fye_cip]
  
  # construct ever in engineering
  ever_engr <- m_term[cip6 %like% "^14"]

  # join fye_code by institution
  ever_engr <- m_inst[ever_engr, on = "institution"]

  # ever in FYE, one row per ID (drop term and cip codes)
  ever_fye <- ever_engr[cip6 == fye_code, .(mcid, race, sex, institution)]
  ever_fye <- unique(ever_fye)

  # fye ever in a non-FYE engr major
  ever_fye_ID <- ever_fye[, .(mcid)]
  fye_engr <- ever_fye_ID[ever_engr, on = "mcid", nomatch = NULL]
  fye_engr <- fye_engr[cip6 != fye_code, .(mcid, term, cip6)]

  # proxy is first non-FYE engr major
  setkeyv(fye_engr, c("mcid", "term"))
  engr_proxy <- fye_engr[, .SD[1], by = "mcid"]
  engr_proxy <- engr_proxy[, .(mcid, proxy = cip6)]
  setkey(engr_proxy, NULL)

  # join proxy to ever FYE, introduces proxy NAs
  fye <- engr_proxy[ever_fye, on = "mcid"]

  # convert to factors to prepare for mice()
  factor_cols <- setdiff(returned_vars, "mcid")
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
