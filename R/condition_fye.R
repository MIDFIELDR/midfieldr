

#' @import data.table
#' @importFrom checkmate assert_choice assert_subset
#' @importFrom checkmate qassert assert_names assert_false
NULL


#' Condition FYE data for multiple imputation
#'
#' Filter first-year-engineering (FYE) students and prepare variables for
#' predicting unknown starting majors. The prepared variables are institution,
#' race, and sex (predictors) and cip6 (with missing values to be imputed). The
#' function returns a data frame formatted for multiple imputation using
#' the mice package.
#'
#' Some US institutions have first year engineering (FYE) programs, typically
#' a common first year curriculum that is a prerequisite for declaring
#' an engineering major. FYE programs are problematic for some persistence
#' metrics. For example, in the conventional graduation rate metric, the only
#' students who count as graduates are those who complete the same
#' program in which they were admitted. But students cannot graduate in FYE;
#' instead, upon completing FYE, they transition to a degree-granting
#' engineering program.
#'
#' Therefore, to include FYE students in any persistence metric requiring a
#' degree-granting "starting" program, we have to predict the engineering
#' program the FYE student would have declared had they not been required to
#' enroll in FYE. \code{predict_fye()} sorts students into two categories:
#'
#' \enumerate{
#' \item{Students who complete an FYE and declare an engineering major.
#'     This is the easy case--at the student's first opportunity, they
#'     enrolled in an engineering program of their choosing. We use that
#'     program as the predicted  starting program.}
#' \item{Students who, after FYE, do not declare an engineering major.
#'     This is the more complicated case---the data provide no information
#'     regarding what engineering program the student would have declared
#'     originally had the institution not required them to enroll in FYE.
#'     For these students, we treat the starting program as missing data be
#'     predicted using multiple imputation.}
#' }
#'
#' The function extracts all terms for all FYE students from
#' \code{midfield_table}. In cases where students enter FYE, change programs,
#' and re-enter FYE, only the first group of FYE terms is considered. Any
#' programs before FYE are ignored. The first (if any) post-FYE program is
#' identified. If the program is in engineering, the CIP is retained as
#' their predicted starting major. If not, the CIP is replaced with NA to
#' be treated as missing data for the imputation.
#'
#' Lastly, the predictor variables (institution, race, sex) and the imputed
#' variable (cip6) are converted to unordered factors. The resulting data
#' frame is ready for use as input for the mice package.
#'
#' @param dframe Data frame of all degree-seeking engineering students in the
#'        database, with required variables \code{mcid}, \code{race},
#'        and \code{sex}.
#' @param midfield_table MIDFIELD \code{term} data table or equivalent
#'        with required variables \code{mcid}, \code{institution},
#'        \code{term}, and \code{cip6}.
#' @param ... Not used, forces later arguments to be used by name.
#' @param fye_codes Optional character vector of 6-digit CIP codes to
#'        identify FYE programs, default 140102. Codes must be 6-digit
#'        strings of numbers; regular expressions are prohibited.
#'        Non-engineering codes---those that do not start with
#'        14"---are ignored.
#' @return A \code{data.table} with the following properties:
#' \itemize{
#'     \item One row for every FYE student.
#'     \item Columns for ID, institution, race, sex, and CIP code, all
#'     except ID converted to factors. Additional columns in \code{dframe}
#'     are dropped.
#'     \item Grouping structures are not preserved.
#' }
#'
#'
#' @family condition_*
#'
#'
#' @examples
#' # Using toy data
#' DT <- toy_student[, .(mcid, race, sex)]
#' condition_fye(dframe = DT, midfield_table = toy_term)
#'
#'
#' # Overwrites institution if present in dframe
#' DT <- toy_student[, .(mcid, institution, race, sex)]
#' condition_fye(dframe = DT, midfield_table = toy_term)
#'
#'
#' # Other columns, if any, are dropped
#' colnames(toy_student)
#' colnames(condition_fye(toy_student, toy_term))
#'
#'
#' # Optional argument permits multiple CIP codes for FYE
#' condition_fye(DT, toy_term, fye_codes = c("140101", "140102"))
#'
#'
#' \dontrun{
#' # Constraints on the \vode{fye_codes} argument
#' DT <- toy_student[, .(mcid, race, sex)]
#'
#'
#' # Must be an engineering CIP (starts with 14)
#' condition_fye(DT, toy_term, fye_codes = c("140101", "540102"))
#'
#'
#' # Must have 6-digits
#' condition_fye(DT, toy_term, fye_codes = "1401")
#'
#'
#' # Must contain numerals only (no regular expressions)
#' condition_fye(DT, toy_term, fye_codes = "^14010")
#' }
#'
#'
#' @export
#'
#'
condition_fye <- function(dframe,
                          midfield_table,
                          ...,
                          fye_codes = NULL) {

  # remove all keys
  on.exit(setkey(dframe, NULL))
  on.exit(setkey(midfield_table, NULL), add = TRUE)

  # assert arguments after dots used by name
  wrapr::stop_if_dot_args(
    substitute(list(...)),
    paste(
      "Arguments after ... must be named.\n",
      "* Did you forget to write `fye_codes = `?\n *"
    )
  )

  # required arguments
  qassert(dframe, "d+")
  qassert(midfield_table, "d+")

  # optional arguments: fye_codes default value(s)
  fye_codes  <- fye_codes %||% c("140102")
  assert_choice(unique(nchar(fye_codes)), choices = 6) # 6 digits only

  # fye_codes: number strings only, no regular expressions
  assert_subset(
    unlist(strsplit(fye_codes, split = character(0))),
    choices = c("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
  )

  # fye_codes must be engineering (start with "14")
  assert_false(length(fye_codes) != length(fye_codes[fye_codes %like% "^14"]))

  # fye_codes: string, length >= 1
  qassert(fye_codes, "s+")

  # inputs modified (or not) by reference
  dframe <- copy(as.data.table(dframe)) # not the output
  setDT(midfield_table) # immediately subset, so side-effect OK

  # required columns
  assert_names(colnames(dframe),
               must.include = c("mcid", "race", "sex"))
  assert_names(colnames(midfield_table),
               must.include = c("mcid", "institution", "term", "cip6"))

  # class of required columns
  qassert(dframe[, mcid], "s+")
  qassert(dframe[, race], "s+")
  qassert(dframe[, sex], "s+")
  qassert(midfield_table[, mcid], "s+")
  qassert(midfield_table[, institution], "s+")
  qassert(midfield_table[, term], "s+")
  qassert(midfield_table[, cip6], "s+")

  # bind names due to NSE notes in R CMD check
  next_cip6 <- NULL
  next_cip2 <- NULL
  cip2 <- NULL

  # do the work
  # all degree-seeking engineering students
  latest_id <- dframe[, unique(mcid)]

  # degree-seeking engr and an FYE term
  rows_we_want <- midfield_table$mcid %chin% latest_id &
    midfield_table$cip6 %chin% fye_codes
  fye <- midfield_table[rows_we_want, .(mcid, institution)]

  # remove key when finished
  on.exit(setkey(fye, NULL), add = TRUE)

  # fye has ID and institution columns
  fye <- unique(fye)

  # institution in fye replaces institution (if any) in dframe
  if("institution" %chin% names(dframe)){dframe[, institution := NULL]}

  # join, result has FYE ID, institution, race, sex
  fye <- merge(fye, dframe, by = "mcid", all.x = TRUE)

  # subset midfield data table
  DT <- filter_match(
    dframe = midfield_table,
    match_to = fye,
    by_col = "mcid",
    select = c("mcid", "term", "cip6")
  )

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
  fye[, `:=`(
    institution = as.factor(institution),
    cip6 = as.factor(cip6),
    race = as.factor(race),
    sex = as.factor(sex)
  )]

  # keep required columns only
  cols_we_want <- c("mcid", "institution", "race", "sex", "cip6")
  fye <- fye[, cols_we_want, with = FALSE]
  setcolorder(fye, cols_we_want)

  # reorder rows
  keys <- c("institution", "cip6", "sex", "race")
  setkeyv(fye, keys)

  # enable printing (see data.table FAQ 2.23)
  fye[]
}
