# Documentation described below using an inline R code chunk, e.g.,
# "`r midfield_student_prep_fye_mice`" or "`r return_prep_fye_mice`", are 
# documented in the R/roxygen.R file.



#' Prepare FYE data for multiple imputation
#'
#' Constructs a data frame of student-level records of First-Year Engineering
#' (FYE) programs and conditions the data for later use as an input to the mice
#' R package for multiple imputation. Sets up three variables as predictors
#' (institution, race/ethnicity, and sex) and one variable to be estimated
#' (program CIP code).
#'
#' At some US institutions, engineering students are required to complete a
#' First-Year Engineering (FYE) program as a prerequisite for declaring an
#' engineering major. Administratively, degree-granting engineering programs
#' such as Electrical Engineering or Mechanical Engineering treat their incoming
#' post-FYE students as their "starting" cohorts.  However, when computing a
#' metric that requires a count of starters---graduation rate, for example---FYE
#' records must be treated with special care to avoid a miscount.
#'
#' To illustrate the potential for miscounting starters, suppose we wish to
#' calculate a Mechanical Engineering (ME) graduation rate. Students starting in
#' ME constitute the starting pool and the fraction of that pool graduating in
#' ME is the graduation rate. At FYE institutions, an ME program would typically
#' define their starting pool as the post-FYE cohort entering their program.
#' This may be the best information available, but it invariably undercounts
#' starters by failing to account for FYE students who do not transition
#' (post-FYE) to degree-granting engineering programs---students who may have
#' left the institution or switched to non-engineering majors. In either case,
#' in the absence of the FYE requirement, some of these students would have been
#' ME starters. By neglecting these students, the count of ME starters is
#' artificially low resulting in an ME graduation rate that is artificially
#' high. The same is true for every degree-granting engineering discipline in an
#' FYE institution.
#'
#' Therefore, to avoid miscounting starters at FYE institutions, we have to
#' estimate an "FYE proxy", that is, the 6-digit CIP codes of the
#' degree-granting engineering programs that FYE students would have declared
#' had they not been required to enroll in FYE. The purpose of
#' `prep_fye_mice()`` is to prepare the data for making that estimation.
#'
#' After running `prep_fye_mice()` but before running `mice()`, one can edit
#' variables or add variables to create a custom set of predictors. The mice
#' package expects all predictors and the proxy variables to be factors. Do not
#' delete the institution variable because it ensures that a student's imputed
#' program is available at their institution.
#'
#' In addition, ensure that the only missing values are in the proxy column.
#' Other variables are expected to be complete (no NA values). A value of
#' "unknown" in a predictor column, e.g., race/ethnicity or sex, is an
#' acceptable value, not missing data. Observations with missing or unknown
#' values in the ID or institution columns (if any) should be removed.
#'
#' @param midfield_student `r midfield_student_prep_fye_mice`
#' @param midfield_term    `r midfield_term_prep_fye_mice`
#' @param ...              `r param_dots`
#' @param fye_codes Optional character vector of 6-digit CIP codes to identify
#'   FYE programs, default "140102". Codes must be 6-digit strings of numbers;
#'   regular expressions are prohibited. Non-engineering codes---those that do
#'   not start with 14---produce an error.
#'        
#' @return `r return_prep_fye_mice`
#'  \describe{
#'    \item{`mcid`}{Character, anonymized student identifier. Returned 
#'            as-is.}
#'    \item{`race`}{Factor, race/ethnicity as self-reported by the 
#'            student. An imputation predictor variable.}
#'    \item{`sex`}{Factor, sex as self-reported by the 
#'            student. An imputation predictor variable.} 
#'    \item{`institution`}{Factor, anonymized institution name. An 
#'            imputation predictor variable.} 
#'    \item{`proxy`}{Factor, 6-digit CIP code of a student's known, 
#'            post-FYE engineering program or NA representing missing 
#'            values to be imputed.}
#'  }
#'
#' @section Method: The function extracts all terms for all FYE students,
#'   including those who migrate to enter Engineering after their first term,
#'   and identifies the first post-FYE program in which they enroll, if any.
#'   This treatment yields two possible outcomes for values returned in the
#'   `proxy` column:
#' 
#' \enumerate{
#' \item{The student completes FYE and enrolls in an engineering major. For 
#'     this outcome, we know that at the student's first opportunity, they 
#'     enrolled in an engineering program of their choosing. The CIP code of 
#'     that program is returned as the student's FYE proxy.}
#' \item{The student does not enroll post-FYE in an engineering major. Such 
#'     students have no further records in the database or switched from 
#'     Engineering to another program. For this outcome, the data provide no 
#'     information regarding what engineering program the student would have 
#'     declared originally had the institution not required them to enroll in 
#'     FYE. For these students a proxy value of NA is returned. These are the 
#'     data treated as missing values to be imputed by `mice()`.}
#' }
#' 
#' In cases where students enter FYE, change programs, and re-enter FYE, only 
#' the first group of FYE terms is considered. Any programs before FYE are 
#' ignored.
#' 
#' The resulting data frame is ready for use as input for the mice package, 
#' with all variables except `mcid` returned as factors.
#' 
#' @example man/examples/prep_fye_mice_exa.R
#' @export
#'
prep_fye_mice <- function(midfield_student = student,
                           midfield_term = term,
                           ...,
                           fye_codes = NULL) {

  # remove all keys
  on.exit(setkey(midfield_student, NULL))
  on.exit(setkey(midfield_term, NULL), add = TRUE)
  
  # assert arguments after dots used by name
  wrapr::stop_if_dot_args(
    substitute(list(...)),
    paste(
      "Arguments after ... must be named.\n",
      "* Did you forget to write `fye_codes = `?\n *"
    )
  )

  # optional arguments: fye_codes default value(s)
  fye_codes <- fye_codes %?% c("140102")
  
  # required arguments
  qassert(midfield_student, "d+")
  qassert(midfield_term, "d+")
  qassert(unique(nchar(fye_codes)), "I1[6,6]")

  # fye_codes: number strings only, no regular expressions
  assert_subset(
    unlist(strsplit(fye_codes, split = character(0))),
    choices = c("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
  )

  # fye_codes: string, length >= 1
  qassert(fye_codes, "s+")

  # fye_codes: must be engineering (start with "14")
  assert_subset(
      substr(fye_codes, 1, 2),
      choices = c("14")
  )

  # inputs modified (or not) by reference
  setDT(midfield_student) # immediately subset, so side-effect OK
  setDT(midfield_term) # immediately subset, so side-effect OK

  # required columns
  assert_names(colnames(midfield_student),
    must.include = c("mcid", "race", "sex")
  )
  assert_names(colnames(midfield_term),
    must.include = c("mcid", "institution", "term", "cip6")
  )
  
  # class of required columns
  qassert(midfield_student[, mcid], "s+")
  qassert(midfield_student[, race], "s+")
  qassert(midfield_student[, sex], "s+")
  qassert(midfield_term[, mcid], "s+")
  qassert(midfield_term[, institution], "s+")
  qassert(midfield_term[, term], "s+")
  qassert(midfield_term[, cip6], "s+")

  # bind names due to NSE notes in R CMD check
  proxy <- NULL

  # Do the work
  
  # All FYE students, all terms
  fye <- midfield_term[cip6 %chin% fye_codes, .(mcid, institution)]
  on.exit(setkey(fye, NULL), add = TRUE)
  
  # Limit to degree-seeking IDs (inner join)
  # The fye data frame is the function output after we add 
  # the FYE proxy CIP variable, institution, race, and sex
  fye <- midfield_student[fye, .(mcid, institution), on = c("mcid"), nomatch = NULL]
  fye <- unique(fye)
  
  # Working data frame to gather proxies (left-outer join)
  DT <- midfield_term[fye, .(mcid, institution, term, cip6), on = c("mcid")]
  on.exit(setkey(DT, NULL), add = TRUE)
  DT <- unique(DT)
  
  # Order rows and create proxy variable as CIP in following term 
  setkeyv(DT, c("mcid", "term"))
  DT[, proxy := shift(.SD, n = 1, fill = NA, type = "lead"),
     by = "mcid",
     .SDcols = "cip6"
  ]
  
  # Omit rows for which the proxy is FYE, retaining 
  # rows with student's last FYE term
  DT <- DT[!proxy %chin% fye_codes]
  
  # Omit rows in which consecutive CIPs are identical
  DT <- DT[cip6 != proxy]
  
  # Keep rows in which the term cip6 is FYE
  DT <- DT[cip6 %chin% fye_codes]
  
  # Ensure row order, keep the first instance by ID, thereby
  # omitting rows for students entering FYE twice
  setkeyv(DT, c("mcid", "term"))
  DT <- DT[, .SD[1], by = c("mcid")]
  
  # subset to retain those who transition to engr major after FYE
  DT <- DT[proxy %like% "^14"]
  
  # Drop unnecessary columns. This DT contains the known CIPs of 
  # FYE students who transition to an ENGR major post-FYE
  DT <- DT[, .(mcid, proxy)]
  
  # Merge known transition CIPs to ever FYE (left-outer join)
  fye <- DT[fye, on = c("mcid")]
  
  # Add race and sex (left-outer join). Ensure uniqueness.
  fye <- midfield_student[fye, .(mcid, race, sex, institution, proxy), on = c("mcid")]
  fye <- unique(fye)
  
  # Convert to factors to prepare for mice()
  fye[, `:=`(
      race = as.factor(race),
      sex = as.factor(sex), 
      institution = as.factor(institution),
      proxy = as.factor(proxy)
  )]
  
  # reorder rows
  setkeyv(fye, c("institution", "proxy", "sex", "race"))
  
  # enable printing (see data.table FAQ 2.23)
  fye[]
}
