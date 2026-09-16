# See R/roxygen.R for documentation below that uses inline R code

#' Initialize FYE proxies for imputing missing data
#'
#' Assembles a data frame of students ever enrolled in First-Year Engineering
#' (FYE) programs. Where practicable, a 6-digit CIP code is added to the data
#' frame as a proxy for the student's preferred engineering major. If
#' indeterminate, the proxy is NA and treated as missing data. The result is
#' suitably formatted for input to the R mice package for multiple imputation.
#'
#' At some US institutions, engineering students are required to complete a First-Year Engineering (FYE) curriculum before they can be admitted to a degree-granting major such as Civil, Electrical, or Mechanical Engineering. This poses a problem when trying to count the number of students starting in one of these programs: the students don't start in Civil, Electrical, or Mechanical Engineering; they start in FYE.
#'
#' For some metrics---graduation rate for example---correctly identifying starters is imperative. The problem posed by FYE programs is that we don't know the engineering starting majors these students would have selected had FYE not been required. We address the problem by constructing an *FYE proxy* variable.
#'
#' The FYE proxy has one of two values:
#' \enumerate{
#' \item{If the record of an FYE student includes a degree-granting
#'       engineering program, the 6-digit CIP code of the first such program is
#'       returned as the student's FYE proxy.}
#' \item{If not, the proxy is NA and is treated as a missing value to be
#'       imputed later using the R mice package.}
#' }
#' This function does not perform the imputation. It produces a data
#' frame suitably formatted for input to the R mice package for multiple
#' imputation.
#'
#' @param m_student `r dframe` with required character variables
#'        `{mcid, race, sex}.` Typically the original, unfiltered
#'        `student` source data.
#' @param m_term `r dframe` with required character variables
#'        `{mcid, term, cip6, institution}.` Typically the original,
#'         unfiltered `term` source data.
#' @param fye_cip Character, one 6-digit CIP code used for FYE programs. Default
#'        "140102", applied to all institutions except those (if any)
#'        optionally defined by user in `alt_fye.`
#' @param ... `r param_dots`
#' @param alt_fye `r dframe` with character variables
#'        `{institution, alt_cip}.` For users with institutions that use
#'        a 6-digit CIP code other than the value in `fye_cip` for their FYE
#'        programs. One FYE code only per institution.
#' @returns Data frame with the following properties:
#' * `r preserv_class_not_grp_keys`
#' * Rows: One row for every degree-seeking FYE student. Rows in `m_student`
#'   or `m_term` with NA values in any of the required variables are removed.
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
#' @example man/examples/exa_initialize_fye_proxies.R
#' @export
#'
initialize_fye_proxies <- function(m_student,
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

  # to restore class except grouped tibbles
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

  return_vars <- c("mcid", "institution", "race", "sex", "proxy")

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

  # join proxy to ever FYE, introduces proxy NAs, output nearly complete
  dframe <- engr_proxy[ever_fye, on = "mcid"]

  # convert to factors to prepare for mice()
  factor_cols <- setdiff(return_vars, "mcid")
  dframe[, names(.SD) := lapply(.SD, factor), .SDcols = factor_cols]

  # ---------- prepare to return

  # NULL keys, return vars, unique, class
  dframe <- utils_prep_return(dframe, return_vars, prior_class)

  # done
  dframe[]
}


# ========== deprecated version ==========
#
#' midfieldr deprecated functions
#' @param midfield_student `r midfield_x("*student*")`
#' @param midfield_term `r midfield_x("*term*")`
#' @param fye_codes Character, one 6-digit CIP code used for FYE programs.
#'        Default "140102"
#' @rdname midfieldr-deprecated
#' @export
prep_fye_mice <- function(midfield_student,
                          midfield_term,
                          fye_codes = NULL) {
  .Deprecated(
    new = "initialize_fye_proxies",
    package = "midfieldr",
    msg = "This function was deprecated as part of an update to all
    midfieldr functions. Please use `initialize_fye_proxies()` instead."
  )

  # invoking the old function calls the new function
  initialize_fye_proxies(
    m_student = midfield_student,
    m_term = midfield_term,
    fye_cip = fye_codes,
    alt_fye = NULL
  )
}
