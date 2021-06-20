

#' @import data.table
#' @importFrom wrapr stop_if_dot_args
#' @importFrom checkmate qassert assert_names
NULL


#' Add one column each for student race/ethnicity and sex
#'
#' Add two columns of character values of students' self-reported
#' race/ethnicity and sex using student ID as the join-by variable.
#' Based on information in the MIDFIELD \code{student} data table or
#' equivalent.
#'
#' Existing columns with the same names as the added columns are overwritten.
#'
#' @param dframe Data frame with required variable \code{mcid}.
#' @param midfield_student MIDFIELD \code{student} data table or equivalent
#'        with required variables \code{mcid}, \code{race}, and \code{sex}.
#' @return A \code{data.table}  with the following properties:
#' \itemize{
#'     \item Rows are not modified.
#'     \item Columns \code{race} and \code{sex} are added.
#'     \item Grouping structures are not preserved.
#' }
#'
#'
#' @family add_*
#'
#'
#' @examples
#' # Add race and sex to a data frame of graduates
#' dframe <- toy_degree[1:5, c("mcid", "cip6")]
#' add_race_sex(dframe, midfield_student = toy_student)
#'
#'
#' # Add race and sex to a data frame from the term table
#' dframe <- toy_term[21:26, c("mcid", "institution", "level")]
#' add_race_sex(dframe, midfield_student = toy_student)
#'
#'
#' # If present, existing race and sex columns are overwritten
#' # Using dframe from above,
#' DT1 <- add_race_sex(dframe, midfield_student = toy_student)
#' DT2 <- add_race_sex(DT1, midfield_student = toy_student)
#' all.equal(DT1, DT2)
#' @export
#'
#'
add_race_sex <- function(dframe,
                         midfield_student) {

  # remove all keys
  on.exit(setkey(dframe, NULL))
  on.exit(setkey(midfield_student, NULL), add = TRUE)

  # required arguments
  qassert(dframe, "d+")
  qassert(midfield_student, "d+")

  # optional arguments
  # NA

  # inputs modified (or not) by reference
  setDT(dframe)
  setDT(midfield_student) # immediately subset, so side-effect OK

  # required columns
  assert_names(colnames(dframe),
    must.include = c("mcid")
  )
  assert_names(colnames(midfield_student),
    must.include = c("mcid", "race", "sex")
  )

  # class of required columns
  qassert(dframe[, mcid], "s+")
  qassert(midfield_student[, mcid], "s+")
  qassert(midfield_student[, race], "s+")
  qassert(midfield_student[, sex], "s+")

  # bind names due to NSE notes in R CMD check
  # NA

  # do the work
  # preserve column order except columns that match new columns
  names_dframe <- colnames(dframe)
  added_cols <- c("race", "sex")
  key_names <- names_dframe[!names_dframe %chin% added_cols]
  dframe <- dframe[, key_names, with = FALSE]

  DT <- filter_match(
    dframe = midfield_student,
    match_to = dframe,
    by_col = "mcid",
    select = c("mcid", added_cols)
  )

  # left-outer join, keep all rows of dframe
  dframe <- merge(dframe, DT, by = "mcid", all.x = TRUE)

  # restore column and row order
  set_colrow_order(dframe, key_names)

  # enable printing (see data.table FAQ 2.23)
  dframe[]
}
