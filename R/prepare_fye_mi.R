#' @importFrom data.table %chin% setnames setDT setkey setorder
NULL

#' Prepare FYE data for multiple imputation
#'
#' Extract first-year-engineering (FYE) students from data and prepare
#' a data frame for input to the mice package for multiple imputation to
#' predict starting programs of FYE students.
#'
#' Some US institutions have first year engineering (FYE) programs, typically
#' a common first year curriculum that is a prerequisite for declaring
#' an engineering major. FYE is problematic when computing a persistence
#' metric such as graduation rate that counts a graduation successful only
#' for students who matriculate and graduate in the same program.
#'
#' We have to predict, therefore, the degree-granting engineering program the
#' FYE student would have declared had they not been required to enroll in
#' FYE. Predicting this "starting program" takes one of two forms.
#'
#' \enumerate{
#' \item{Students who complete an FYE and declare an engineering major.
#'     This is the easy case--at the student's first opportunity, they
#'     enrolled in an engineering program of their choosing. We use that
#'     program as our predicted  starting program. }
#' \item{Students who, after FYE, do not declare an engineering major.
#'     This is the more complicated case---the data provide no information
#'     regarding what engineering program the student would have declared
#'     originally had the institution not required them to enroll in FYE.
#'     For these students, we treat the starting program as missing data and
#'     impute a predicted value using multiple imputation as implemented
#'     in the mice package.}
#' }
#'
#' The function extracts all FYE students from \code{midfieldstudents} (or
#' equivalent) and from \code{midfieldterms} (or equivalent) determines
#' students' post-FYE programs. If the program is in engineering, the CIP
#' is retained. If not, the CIP is replaced with NA to represent missing
#' data for the imputation.
#'
#' Finally, the predictor variables (institution, race, sex) are converted
#' to factors. The output is ready for use as an input to the mice package.
#'
#' @param data_students data frame of student attributes
#' @param data_terms data frame of term attributes
#'
#' @return data frame with the following properties:
#' \itemize{
#'     \item One row for every FYE student in the data, keyed by ID
#'     \item Columns for ID, institution, race, sex, and CIP code
#'     \item Data frame extensions such as \code{tbl} or \code{data.table}
#'     are preserved
#' }
#'
#' @examples
#' # placeholder
#' @family functions
#'
#' @export
#'
prepare_fye_mi <- function(data_students = NULL,
                           data_terms = NULL) {

  # default arguments
  data_students <- data_students %||% midfielddata::midfieldstudents
  data_terms <- data_terms %||% midfielddata::midfieldterms

  # argument check data frames
  assert_class(data_students, "data.frame")
  assert_class(data_terms, "data.frame")

  # argument check required columns present
  assert_required_column(data_students, "id")
  assert_required_column(data_students, "cip6")
  assert_required_column(data_students, "institution")
  assert_required_column(data_students, "race")
  assert_required_column(data_students, "sex")
  assert_required_column(data_terms, "id")
  assert_required_column(data_terms, "cip6")
  assert_required_column(data_terms, "term")

  # argument check required columns correct class
  id <- data_students$id
      assert_class(id, "character")
  cip6 <- data_students$cip6
      assert_class(cip6, "character")
  institution <- data_students$institution
      assert_class(institution, "character")
  race <- data_students$race
      assert_class(race, "character")
  sex <- data_students$sex
      assert_class(sex, "character")

  id <- data_terms$id
      assert_class(id, "character")
  cip6 <- data_terms$cip6
      assert_class(cip6, "character")
  term <- data_terms$term
      assert_class(term, "numeric")

  # bind names
  # NA

  # students (fye01)
  rows_we_want <- data_students$cip6 %chin% c("14XXXX", "14YYYY")
  cols_we_want <- c("id", "cip6", "institution", "race", "sex")
  students_fye <- data_students[rows_we_want, ..cols_we_want]

  # terms produces fye02
  terms_fye <- fye_terms(data_terms, keep_id = students_fye$id)

  # prepare mi_kernel (fye03)
  students_fye <- students_fye[, .(id, institution, race, sex)]
  mi_kernel <- terms_fye[students_fye, on = "id"]
  mi_kernel <- mi_kernel[order(institution, race, sex, cip6)]

  # mi_kernel to mi_data
  mi_data <- mi_kernel[, ":="(institution = as.factor(institution),
    race = as.factor(race),
    sex = as.factor(sex),
    cip6 = as.factor(cip6))]
  mi_data <- mi_data[, .(id, institution, race, sex, cip6)]
  data.table::setorder(mi_data, id)
  data.table::setkey(mi_data, NULL)
}

# ------------------------------------------------------------------------

# FYE internal functions

# ------------------------------------------------------------------------

#' Access midfieldterms for FYE analysis
#'
#' Returns cip6 and ID of students enrolled in engineering
#' immediately following FYE
#'
#' @param data term data
#' @noRd
fye_terms <- function(data, keep_id) {

  # argument check

  # bind names
  end_fye <- NULL
  cip6 <- NULL
  term <- NULL
  id <- NULL

  rows_we_want <- data$id %in% keep_id
  cols_we_want <- c("id", "cip6", "term")
  all_fye_terms <- data[rows_we_want, ..cols_we_want]
  all_fye_terms <- all_fye_terms[order(id, term)]

  last_fye_terms <- all_fye_terms[cip6 %chin% c("14XXXX", "14YYYY")]
  last_fye_terms <- last_fye_terms[order(id, -term), .SD[1], by = "id"]
  last_fye_terms <- last_fye_terms[, .(id, term)]
  data.table::setnames(last_fye_terms, old = "term", new = "end_fye")

  fye_to_engr <- last_fye_terms[all_fye_terms, on = "id"]
  fye_to_engr <- fye_to_engr[term > end_fye]
  fye_to_engr <- fye_to_engr[order(id, term), .SD[1], by = "id"]
  fye_to_engr <- fye_to_engr[grepl("^14", cip6)]
  fye_to_engr <- fye_to_engr[, .(id, cip6)]
}
