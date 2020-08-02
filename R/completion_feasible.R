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
#' @param ... not used for values. Forces optional arguments to be usable
#' by name only.
#' @param span numeric scalar, number of years to define feasibility, default
#' is 6 years
#' @param terms_transfer_max numeric scalar, the term equivalent of the
#' maximum number of transfer credit hours, default is 4 terms
#' @param data_students data frame of student attributes
#' @param data_terms data frame of term attributes
#' @param data_degrees data frame of degree attributes
#'
#' @return character vector of student IDs, a subset of the input
#'
#' @examples
#' # placeholder
#'
#' @family data_carpentry
#'
#' @export
#'
completion_feasible <- function(id = NULL,
                                ...,
                                span = NULL,
                                terms_transfer_max = NULL,
                                data_students = NULL,
                                data_terms = NULL,
                                data_degrees = NULL) {
  wrapr::stop_if_dot_args(
    substitute(list(...)), "Arguments after ... must be named,"
  )

  # default data sets and constants
  span <- span %||% 6
  terms_transfer_max <- terms_transfer_max %||% 4
  data_students <- data_students %||% midfielddata::midfieldstudents
  data_terms    <- data_terms %||% midfielddata::midfieldterms
  data_degrees  <- data_degrees %||% midfielddata::midfielddegrees

  # check arguments
  assert_class(id, "character")
  assert_class(span, "numeric")
  assert_class(data_students, "data.frame")
  assert_class(data_terms, "data.frame")
  assert_class(data_degrees, "data.frame")

  # bind names
  median_hr_per_term <- NULL
  terms_transfer <- NULL
  hours_transfer <- NULL
  matric_limit <- NULL
  institution <- NULL
  term_enter <- NULL
  hours_term <- NULL
  degree <- NULL

  # does not require preservation of data frame extension
  # because the function returns a vector

  # gather degree data
  degree_data <- filter_by_id(data_degrees,
                              keep_id = id,
                              keep_col = c("id", "institution", "degree"),
                              first_degree = TRUE,
                              unique_row = TRUE)

  # separate the grads from nongrads
  nongrad_rows <- is.na(degree_data$degree)
  nongrads <- degree_data[nongrad_rows]
  nongrads_id <- nongrads$id
  grads <- degree_data[!nongrad_rows]
  grads_id <- grads$id

  if (length(nongrads_id) > 0){
    transfer_data <- filter_by_id(
      data_students,
      keep_id = nongrads_id,
      keep_col = c("id", "term_enter", "hours_transfer"),
      unique_row = TRUE
    )

    # join
    nongrads <- transfer_data[nongrads, on = "id"]

    # get median hours per term of graduates by institution
    institution_nongrads <- nongrads[, .(institution)]
    institution_nongrads <- unique(institution_nongrads)
    keep_institution     <- institution_nongrads$institution

    # gather institution data for feasible completion
    data_terms_specific_inst <- data_terms[institution %chin% keep_institution]
    inst_limits <- get_institution_limits(data = data_terms_specific_inst,
                                          span = span)

    # get institution hours per term
    # IDs are ALL grads in the institutions in keep_institution
    institution_all_grad <- data_degrees[
      !is.na(degree) & institution %chin% keep_institution, .(id)
    ]
    all_grad_id <- institution_all_grad$id

    # now go to terms with these IDs
    all_grad <- data_terms[id %in% all_grad_id, .(institution, hours_term)]
    hr_per_term <- all_grad[order(institution),
                            .(median_hr_per_term = stats::median(hours_term)),
                            by = institution]

    # join the inst data
    institutions <- hr_per_term[inst_limits, on = "institution"]

    # join student and institution data
    fc_data <- institutions[nongrads, on = "institution"]
    data.table::setnafill(fc_data,
                          type = "const",
                          fill = 0,
                          cols = c("hours_transfer")
    )

    # convert transfer hours to terms
    fc_data[, terms_transfer := floor(hours_transfer / median_hr_per_term)]

    # max transfer of 4 terms
    fc_data[
      terms_transfer > terms_transfer_max,
      terms_transfer := terms_transfer_max
    ]

    # advance matriculation limit by transfer terms
    fc_data <- term_addition(fc_data,
                             term_col = "matric_limit",
                             add_col = "terms_transfer"
    )

    # filter
    nongrad_fc <- fc_data[matric_limit >= term_enter]
    nongrad_fc_id <- nongrad_fc$id

    # output if we have any nongrads
    feasible_id <- sort(unique(c(grads_id, nongrad_fc_id)))

  } else {

    # output when we have grads only
    feasible_id <- sort(unique(grads_id))
  }
}
