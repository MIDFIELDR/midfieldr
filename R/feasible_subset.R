#' @importFrom data.table setDT setDF
#' @importFrom wrapr stop_if_dot_args
NULL

#' Subset IDs for feasible completion
#'
#' Subset a vector of student IDs, retaining students for whom program
#' completion is feasible within a designated time limit.
#'
#' To count a non-graduating student in a persistence metric, completing
#' their instructional program must have been feasible. Completion feasibility
#' depends on the range of data from the institution, the student's
#' matriculation term, and a designated time limit (typically 6 years).
#' The relevant terminology is:
#'
#' \describe{
#'   \item{data range}{The span of terms for which student-record data
#'   are available. Varies by institution.}
#'   \item{completion feasibility}{A student may complete their program
#'   within the limits of the data range.}
#'   \item{matriculation limit}{The last term a student can matriculate
#'   and feasibly complete their program  within a designated time limit
#'   (typically 6 years). Transfer credits can advance the matriculation
#'   limit.}
#' }
#'
#' The subsetting condition is that a student has graduated, or if not, that
#' their matriculation term is no later than the matriculation limit,
#' adjusted for transfer credits if any, up to a maximum of 4 terms equivalent.
#'
#' The function accesses three of the midfielddata data sets:
#' \code{\link[midfielddata]{midfieldstudents}},
#' \code{\link[midfielddata]{midfieldterms}}, and
#' \code{\link[midfielddata]{midfielddegrees}} or their equivalents.
#'
#' @param id character vector of student IDs
#' @param ... not used, force later arguments to be used by name.
#' @param span numeric scalar, number of years to define feasibility, default
#' is 6 years
#' @param term_advance_max numeric scalar, maximum terms of transfer credit
#' that advance the matriculation limit, default is 4 terms
#' @param data_students data frame of student attributes
#' @param data_terms data frame of term attributes
#' @param data_degrees data frame of degree attributes
#'
#' @return character vector of student IDs, a subset of the input
#'
#' @examples
#' # placeholder
#' @family data_carpentry
#'
#' @export
#'
feasible_subset <- function(id,
                            ...,
                            span = NULL,
                            term_advance_max = NULL,
                            data_students = NULL,
                            data_terms = NULL,
                            data_degrees = NULL) {

  wrapr::stop_if_dot_args(
    substitute(list(...)), "Arguments after ... must be named,"
  )

  # check arguments
  assert_explicit(id)
  assert_class(id, "character")

  # bind names
  hours_transfer <- NULL
  matric_limit <- NULL
  institution  <- NULL
  hours_term  <- NULL
  term_enter  <- NULL
  term_sum  <- NULL
  degree <- NULL

  # degree -> grad or nongrad, all students in database
  all_fc <- fc_degrees(data_degrees)

  # vector of all grads IDs
  all_grads_id <- unique(all_fc[degree == "grad", id])

  # reduce to IDs in study only
  study_fc <- filter_by_id(all_fc,
                           keep_id = id,
                           keep_col = c("id", "institution", "degree"),
                           first_degree = TRUE,
                           unique_row = TRUE)

  # gather transfer information
  transfer_fc <- fc_students(data_students, id)

  # gather institution information
  inst_fc <- fc_terms(data_terms, span, all_grads_id)

  # joins
  study_fc <- transfer_fc[study_fc, on = "id"]
  study_fc <- inst_fc[study_fc, on = "institution"]

  # advance matriculation limit
  study_fc <- fc_advance_matric(study_fc, term_advance_max)

  # filter
  study_fc <- study_fc[degree == "grad" |
                       degree == "nongrad" & matric_limit >= term_enter]
  fc_id <- study_fc$id
}
