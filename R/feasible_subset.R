#' @importFrom data.table setDT setDF setnames %chin% setnafill
#' @importFrom wrapr stop_if_dot_args
NULL

#' Subset ID vector for feasible completion
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
#' adjusted for transfer credits if any, up to a maximum of 4 terms
#' equivalent.
#'
#' The function accesses three of the midfielddata data sets:
#' \code{\link[midfielddata]{midfieldstudents}},
#' \code{\link[midfielddata]{midfieldterms}}, and
#' \code{\link[midfielddata]{midfielddegrees}} or their equivalents.
#'
#' @param id character vector of student IDs
#' @param ... not used, force later arguments to be used by name.
#' @param span numeric scalar, number of years to define feasibility, default
#'     is 6 years
#' @param term_advance_max numeric scalar, maximum terms of transfer credit
#'     that advance the matriculation limit, default is 4 terms
#' @param data_students data frame of student attributes
#' @param data_terms data frame of term attributes
#' @param data_degrees data frame of degree attributes
#'
#' @return character vector of student IDs, a subset of the input
#'
#' @examples
#' # placeholder
#' @family functions
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
  matric_limit <- NULL
  hours_term  <- NULL
  term_sum  <- NULL

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

# ------------------------------------------------------------------------

# feasible completion internal functions

# ------------------------------------------------------------------------

#' Access midfielddegrees for feasible completion analysis
#'
#' Returns degrees column with "grad" and "nongrad"
#'
#' @param data degrees data
#' @noRd
fc_degrees <- function(data) {

  # defaults if NULL
  data <- data %||% midfielddata::midfielddegrees

  # argument check
  assert_class(data, "data.frame")

  # bind names
  # NA

  # label all grads and nongrads
  nongrad_rows <- is.na(data$degree)
  data[nongrad_rows, degree := "nongrad"]
  data[!nongrad_rows, degree := "grad"]
}

# ------------------------------------------------------------------------

#' Access midfieldstudents for feasible completion analysis
#'
#' Returns students' entering terms and transfer credit hours
#'
#' @param data students data
#' @param id character vector of student IDs
#' @noRd
fc_students <- function(data, id) {

  # defaults if NULL
  data <- data %||% midfielddata::midfieldstudents

  # argument check
  assert_class(data, "data.frame")
  assert_class(id, "character")

  # obtain transfer status
  transfer_data <- filter_by_id(
    data,
    keep_id = id,
    keep_col = c("id", "term_enter", "hours_transfer"),
    unique_row = TRUE
  )
}

# ------------------------------------------------------------------------

#' Access midfieldterms for feasible completion analysis
#'
#' Returns matriculation limit and median hours per term of graduating
#' students by institution
#'
#' @param data data frame
#' @param span numeric scalar, number of years to define feasibility, default
#' is 6 years
#' @param all_id character vector of student IDs
#' @noRd
fc_terms <- function(data, span, all_id) {

  # defaults if NULL
  data <- data %||% midfielddata::midfieldterms
  span <- span %||% 6

  # argument check
  assert_class(data, "data.frame")
  assert_class(span, "numeric")
  assert_class(all_id, "character")

  # bind names
  delta <- NULL
  med_hr_per_term <- NULL
  matric_limit <- NULL

  # gather institution data range for matriculation limit
  fc_inst <- term_range(data)

  # subtract span from max term
  fc_inst[, delta := -span * 2]
  fc_inst <- term_add(fc_inst, term_col = "max_term", n_col = "delta")

  # matriculation limit
  data.table::setnames(fc_inst, old = "term_sum", new = "matric_limit")
  fc_inst <- fc_inst[, .(institution, matric_limit)]

  # median hours/term of graduates by institution
  grads <- data[id %chin% all_id, .(institution, hours_term)]
  hr_per_term <- grads[,
                       .(med_hr_per_term = stats::median(hours_term)),
                       by = institution]
  # join to inst data
  fc_inst <- hr_per_term[fc_inst, on = "institution"]
}

# ------------------------------------------------------------------------

#' Derive equivalent transfer terms for feasible completion analysis
#'
#' Returns data frame prepared for advancing the matriculation limit
#'
#' @param fc_data data frame
#' @param terms_transfer_max numeric scalar, the term equivalent of the
#' maximum number of transfer credit hours, default is 4 terms
#' @noRd
fc_advance_matric <- function(fc_data, terms_transfer_max) {

  # defaults if NULL
  terms_transfer_max <- terms_transfer_max %||% 4

  # argument check
  assert_class(fc_data, "data.frame")
  assert_class(terms_transfer_max, "numeric")

  # bind names
  terms_transfer <- NULL
  med_hr_per_term <- NULL
  matric_limit <- NULL
  term_sum <- NULL

  # NAs to zero
  data.table::setnafill(fc_data,
                        type = "const",
                        fill = 0,
                        cols = c("hours_transfer")
  )

  # convert transfer hours to terms
  fc_data[, terms_transfer := floor(hours_transfer / med_hr_per_term)]

  # max transfer
  fc_data[
    terms_transfer > terms_transfer_max,
    terms_transfer := terms_transfer_max
  ]

  # advance matriculation limit by transfer terms
  fc_data <- term_add(fc_data,
                      term_col = "matric_limit",
                      n_col = "terms_transfer"
  )
  fc_data[, matric_limit := term_sum]
}
