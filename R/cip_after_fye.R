#' @importFrom data.table setDT setDF first
#' @importFrom wrapr stop_if_dot_args
NULL

#' Determine the first post-FYE program by student ID
#'
#' Subset a vector of student IDs to retain students ever enrolled in FYE and
#' return the CIP code of their first post-FYE program.
#'
#' Computing some persistence metrics, e.g., graduation rate, is
#' complicated for students required to enroll in first-year engineering
#' (FYE) programs. In such cases, we must predict the students'
#' "starting majors." \code{cip_after_fye()} takes the first step in this
#' process by identifying the programs in which students enroll immediately
#' following their final FYE term.
#'
#' \describe{
#'   \item{FYE}{First year engineering program, typically a common first
#'   year curriculum that is a prerequisite for declaring an
#'   engineering major}
#'   \item{starting major}{The degree-granting engineering program---for
#'   example, Civil Engineering, Electrical Engineering, Mechanical
#'   Engineering, etc.---that we predict the student would have declared had
#'   they not been required to enroll in FYE.}
#' }
#'
#' The function accesses \code{data_students}
#' (\code{\link[midfielddata]{midfieldstudents}} or its equivalent) to
#' restrict the IDs to those enrolled in an FYE program at matriculation.
#' It also accesses \code{data_terms}
#' (\code{\link[midfielddata]{midfieldterms}} or its equivalent) to determine
#' the 6-digit CIP code of a student's first post-FYE program. For students
#' with no program after FYE, the CIP is NA.
#'
#' @param id character vector of student IDs
#' @param ... not used for values. Forces optional arguments to be usable
#' by name only.
#' @param data_students data frame of student attributes at matriculation
#' @param data_terms data frame of term attributes
#'
#' @return \code{data.frame} with the following properties:
#' \itemize{
#'   \item Rows for which student ID were ever enrolled in an FYE program
#'   \item Columns \code{id} and \code{cip6}
#'   \item Grouping structures, if any, are not preserved
#'   \item Data frame extensions \code{tbl} or \code{data.table} are preserved
#' }
#'
#' @examples
#' # placeholder
#'
#' @family data_carpentry
#'
#' @export
#'
cip_after_fye <- function(id = NULL,
                             ...,
                             data_students = NULL,
                             data_terms = NULL) {
  wrapr::stop_if_dot_args(
    substitute(list(...)), "Arguments after ... must be named,"
  )

  # default data sets and constants
  data_students <- data_students %||% midfielddata::midfieldstudents
  data_terms <- data_terms %||% midfielddata::midfieldterms

  # check arguments
  assert_class(id, "character")
  assert_class(data_students, "data.frame")
  assert_class(data_terms, "data.frame")

  # bind names
  # median_hr_per_term <- NULL
  # terms_transfer <- NULL
  # hours_transfer <- NULL
  # matric_limit <- NULL
  # institution <- NULL
  # term_enter <- NULL
  # hours_term <- NULL
  # degree <- NULL
  term <- NULL
  cip6 <- NULL

  # preserve data frame extension

  # do the work
  # extract the IDs who enrolled in FYE, using students data
  rows_we_want <- data_students$id %in% id &
    data_students$cip6 %in% c("14XXXX", "14YYYY")
  columns_we_want <- c("id")
  fye <- data_students[rows_we_want, ..columns_we_want]

  # semi-join
  rows_we_want <- data_terms$id %chin% fye$id
  all_terms <- data_terms[rows_we_want]

  # select columns
  columns_we_want <- c("id", "cip6", "term")
  all_terms <- all_terms[, ..columns_we_want]

  # initialize the last-term-only data frame
  rows_we_want <- all_terms$cip6 %in% c("14XXXX", "14YYYY")
  all_fye_terms <- all_terms[rows_we_want]

  # order by ID and descending terms so the first is the most recent term
  all_fye_terms <- all_fye_terms[order(id, -term)]

  # extract the most recent term by ID
  last_fye_terms <- all_fye_terms[, .(term_end_fye = first(term)), by = id]

  # left-join last_fye_terms to all_terms
  all_terms <- merge(all_terms, last_fye_terms, by = "id", all.x = TRUE)

  # retain terms after the final FYE term
  rows_we_want <- all_terms$term > all_terms$term_end_fye
  all_post_fye_terms <- all_terms[rows_we_want]

  # arrange rows
  all_post_fye_terms <- all_post_fye_terms[order(id, term)]

  # extract the first post-FYE term by ID
  first_post_fye_terms <- all_post_fye_terms[
    ,
    .(cip6 = first(cip6), term = first(term)),
    by = id
  ]

  # rows_we_want <- grepl("^14", first_post_fye_terms$cip6)
  # columns_we_want <- c("id", "cip6")
  # fye_to_engr <- first_post_fye_terms[rows_we_want, ..columns_we_want]
  #
  # # select all rows in fye by ID not in fye_to_engr (an "anti-join")
  # rows_we_want <- !fye$id %chin% fye_to_engr$id
  # fye_to_nonengr <- fye[rows_we_want]
  #
  # fye_to_nonengr <- fye_to_nonengr[, .(id, cip6 = NA_character_)]
  #
  # # bind the two
  # cip_post_fye <- rbind(fye_to_engr, fye_to_nonengr)
  # cip_post_fye <- cip_post_fye[, .(id, start = cip6)]

  # select columns
  first_post_fye_terms <- first_post_fye_terms[, .(id, cip6)]

  # right-join, all columns in first_post_fye_terms, all rows in fye
  cip_post_fye <- merge(first_post_fye_terms, fye, by = "id", all.y = TRUE)
  cip_post_fye <- cip_post_fye[order(id)]

}
