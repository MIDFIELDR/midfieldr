
#' Add columns for student race/ethnicity and sex
#'
#' Add columns for students' self-reported race/ethnicity and sex using
#' student ID as the join-by variable. Obtains the information from the
#' MIDFIELD \code{student} data table or equivalent.
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
#' @example man/examples/add_race_sex_exa.R
#'
#'
#' @export
#'
#'
add_race_sex <- function(dframe, midfield_student = student) {

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
