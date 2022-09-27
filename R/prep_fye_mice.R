
#' Prepare FYE data for multivariate imputation
#' 
#' Constructs a data frame of Student Unit Records (SURs) of First-Year 
#' Engineering (FYE) programs and conditions the data for later use as an 
#' input to the mice R package for multivariate imputation. Sets up three 
#' variables as predictors (institution, race, and sex) and one variable to 
#' be predicted (program CIP code). Requires  MIDFIELD \code{student} and 
#' \code{term} data frames in the environment.
#' 
#' At some US institutions, engineering students are required to complete a  
#' First-Year Engineering (FYE) program as a prerequisite for declaring an 
#' engineering major. Administratively, degree-granting engineering programs 
#' such as Electrical Engineering or Mechanical Engineering treat their 
#' incoming post-FYE students as their "starting" cohorts.  However, when 
#' computing a metric that requires a count of starters---graduation rate, 
#' for example---FYE records must be treated with special care to avoid a 
#' miscount. 
#' 
#' To illustrate the potential for miscounting starters, suppose we wish to 
#' calculate a Mechanical Engineering (ME) graduation rate. Students 
#' starting in ME constitute the starting pool and the fraction of that pool 
#' graduating in ME is the graduation rate. At FYE institutions, an ME program 
#' would typically define their starting 
#' pool as the post-FYE cohort entering their program. This may be the best 
#' information available, but it invariably undercounts starters by failing to 
#' account for FYE students who do not transition (post-FYE) to degree-granting 
#' engineering programs---students who may have left the institution or 
#' switched to non-engineering majors. In either case, in the absence of the 
#' FYE requirement, some of these students would have been ME starters. By 
#' neglecting these students, the count of ME starters is artificially low 
#' resulting in an ME graduation rate that is artificially high. The same is 
#' true for every degree-granting engineering discipline in an FYE institution. 
#' 
#' Therefore, to avoid miscounting starters at FYE institutions, we have to 
#' predict an "FYE proxy", that is, the 6-digit CIP codes of the 
#' degree-granting engineering programs that FYE students would have declared 
#' had they not been required to enroll in FYE. The purpose of 
#' \code{prep_fye_mice()} is to prepare the data for making that prediction. 
#'
#' @param midfield_student Data frame of Student Unit Record (SUR) student 
#'         observations, keyed by student ID. Default is \code{student}. 
#'         Required variables are \code{mcid}, \code{race}, and \code{sex}.
#'        
#' @param midfield_term Data frame of SUR term observations keyed 
#'         by student ID. Default is \code{term}. Required variables are 
#'         \code{mcid}, \code{institution}, \code{term}, and \code{cip6}.
#'        
#' @param ... Not used, forces later arguments to be used by name.
#' 
#' @param fye_codes Optional character vector of 6-digit CIP codes to
#'        identify FYE programs, default "140102". Codes must be 6-digit
#'        strings of numbers; regular expressions are prohibited.
#'        Non-engineering codes---those that do not start with
#'        14---are ignored.
#'        
#' @return A \code{data.table} conditioned for later use as an input to the 
#' mice R package for multivariate imputation. The data have the following 
#' properties:
#' \itemize{
#'  \item One row for every FYE student.  
#'  \item Grouping structures are not preserved.
#'  \item  Columns returned: 
#'  \describe{
#'    \item{\code{mcid}}{Character, anonymized student identifier. Returned 
#'            as-is.}
#'    \item{\code{race}}{Factor, race/ethnicity as self-reported by the 
#'            student. An imputation predictor variable.}
#'    \item{\code{sex}}{Factor, sex as self-reported by the 
#'            student. An imputation predictor variable.} 
#'    \item{\code{institution}}{Factor, anonymized institution name. An 
#'            imputation predictor variable.} 
#'    \item{\code{proxy}}{Factor, 6-digit CIP code of a student's known, 
#'            post-FYE engineering program or NA representing missing 
#'            values to be imputed.}
#'  }}
#'
#' @section Method: 
#' The function extracts all terms for all FYE students, including those who 
#' change majors to enter Engineering after their first term, and identifies 
#' the first post-FYE program in which they enroll, if any. This 
#' treatment yields two possible outcomes for values returned in the 
#' \code{proxy} column:
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
#'     data treated as missing values to be imputed by \code{mice()}.}
#' }
#' 
#' In cases where students enter FYE, change programs, and re-enter FYE, only 
#' the first group of FYE terms is considered. Any programs before FYE are 
#' ignored.
#' 
#' The resulting data frame is ready for use as input for the mice package, 
#' with all variables except \code{mcid} returned as factors.
#'
#'
#'
#' @example man/examples/prep_fye_mice_exa.R
#'
#'
#'
#' @export
#'
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
  x <- as.data.table(fye_codes)
  x[, cip2 := substr(fye_codes, 1, 2)]
  assert_subset(
    x[, cip2],
    choices = c("14")
  )

  # inputs modified (or not) by reference
  # dframe <- copy(as.data.table(midfield_student)) # dframe not the function output
  setDT(midfield_student) # immediately subset, so side-effect OK
  setDT(midfield_term) # immediately subset, so side-effect OK

  # required columns
  assert_names(colnames(midfield_student),
    must.include = c("mcid", "race", "sex")
  )
  assert_names(colnames(midfield_term),
    must.include = c("mcid", "institution", "term", "cip6")
  )
  
  # extract minimum set of columns
  dframe <- midfield_student[, .(mcid, race, sex)]

  # class of required columns
  qassert(dframe[, mcid], "s+")
  qassert(dframe[, race], "s+")
  qassert(dframe[, sex], "s+")
  qassert(midfield_term[, mcid], "s+")
  qassert(midfield_term[, institution], "s+")
  qassert(midfield_term[, term], "s+")
  qassert(midfield_term[, cip6], "s+")

  # bind names due to NSE notes in R CMD check
  next_cip6 <- NULL
  next_cip2 <- NULL
  cip2 <- NULL
  x <- NULL

  # do the work
  # all degree-seeking engineering students
  latest_id <- dframe[, unique(mcid)]

  # degree-seeking engr and an FYE term
  rows_we_want <- midfield_term$mcid %chin% latest_id &
    midfield_term$cip6 %chin% fye_codes
  fye <- midfield_term[rows_we_want, .(mcid, institution)]

  # remove key when finished
  on.exit(setkey(fye, NULL), add = TRUE)

  # fye has ID and institution columns
  fye <- unique(fye)

  # institution in fye replaces institution (if any) in dframe
  # if ("institution" %chin% names(dframe)) {
  #   dframe[, institution := NULL]
  # }

  # join, result has FYE ID, institution, race, sex
  fye <- merge(fye, dframe, by = "mcid", all.x = TRUE)

  # subset midfield data table
  # DT <- filter_match(
  #   dframe = midfield_term,
  #   match_to = fye,
  #   by_col = "mcid",
  #   select = c("mcid", "term", "cip6")
  # )
  
  # Inner join using three columns of term
  # x <- midfield_term[, .(mcid, term, cip6)]
  # y <- unique(fye[, .(mcid)])
  # DT <- y[x, on = .(mcid), nomatch = NULL]
  DT <- fye[midfield_term, .(mcid, term, cip6), on = c("mcid"), nomatch = NULL]
  on.exit(setkey(DT, NULL), add = TRUE)
  
  # order rows by setting keys
  setkeyv(DT, c("mcid", "term"))

  # determine the CIP in the immediately following term, keyed by ID
  DT[, next_cip6 := shift(.SD, n = 1, fill = NA, type = "lead"),
    by = "mcid",
    .SDcols = "cip6"
  ]

  # omit rows for which the next term is FYE
  DT <- DT[!next_cip6 %chin% fye_codes]

  # omit rows in which consecutive CIPs are identical
  DT <- DT[cip6 != next_cip6]

  # add 2-digit codes
  DT[, `:=`(
    cip2 = substr(cip6, 1, 2),
    next_cip2 = substr(next_cip6, 1, 2)
  )]

  # at least one of the cip2 must be engineering
  DT <- DT[cip2 == "14" | next_cip2 == "14"]

  # keep rows in which the cip6 (term, not next term) is FYE
  DT <- DT[cip6 %chin% fye_codes]

  # keep the first term instance (some students enter FYE twice)
  DT <- DT[, .SD[1], by = "mcid"]

  # subset to retain those who transition to engr major after FYE
  DT <- DT[next_cip2 == "14"]

  # assign predicted engr major to replace FYE code
  DT[, cip6 := next_cip6]

  # drop unneeded columns
  DT <- DT[, .(mcid, cip6)]

  # fye currently has ID, institution, race, sex
  # join to original, introduces NA to cip6
  fye <- merge(fye, DT, by = "mcid", all.x = TRUE)

  # predictor variables and target variables to factors
  # rename cip6 as proxy
  fye[, `:=`(
    institution = as.factor(institution),
    proxy = as.factor(cip6),
    race = as.factor(race),
    sex = as.factor(sex)
  )]

  # keep required columns only
  cols_we_want <- c("mcid", "institution", "race", "sex", "proxy")
  fye <- fye[, .SD, .SDcols = cols_we_want]
  setcolorder(fye, cols_we_want)

  # reorder rows
  setkeyv(fye, c("institution", "proxy", "sex", "race"))

  # enable printing (see data.table FAQ 2.23)
  fye[]
}
