
#' Add columns for student race/ethnicity and sex
#'
#' Add columns to a data frame of Student Unit Record (SUR) 
#' observations that labels each row with a student's race/ethnicity and sex. 
#' Requires a MIDFIELD \code{student} data frame in the environment. 
#' 
#' MIDFIELD student data includes the variables \code{race} (race/ethnicity) 
#' and \code{sex} as self-reported to their institution. 
#'
#' @param dframe Data frame of student unit record (SUR) observations keyed 
#'         by student ID. Required variable is \code{mcid}.
#' 
#' @param midfield_student Data frame of SUR student observations keyed 
#'         by student ID. Default is \code{student}. Required variables are 
#'         \code{mcid}, \code{race}, and \code{sex}.
#'        
#' @return A \code{data.table}  with the following properties:
#' \itemize{
#'  \item Rows are not modified.
#'  \item Grouping structures are not preserved.
#'  \item Columns listed below are added. \strong{Caution!} An existing column 
#'  with the same name as one of the added columns is silently overwritten. 
#'  Other columns are not modified. 
#' }
#' Columns added:
#' \describe{
#'  \item{\code{race}}{Character, self-reported race/ethnicity, e.g., 
#'  Asian, Black, Hispanic/LatinX, etc.}
#'  \item{\code{sex}}{Character, self-reported sex, values are Female, Male, 
#'  and Unknown}
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
