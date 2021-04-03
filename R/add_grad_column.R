#' @importFrom data.table setDT setDF setnames %chin% setnafill setkey
#' @importFrom wrapr stop_if_dot_args
NULL

#' Add column to classify graduation rate status
#'
#' Add a TRUE/FALSE column to a data frame of student IDs and starting
#' programs. TRUE indicates that a student can be counted as a program graduate
#' when computing graduation rates.
#'
#' For computing graduation rate, students are counted as graduates only if
#' they complete the same program in which they matriculate in 6 years or less.
#' Starting and ending programs are compared using the 2-digit CIP.
#'
#' Optional arguments allow editing the completion span, for example, from 6
#' years to 4 years, and the CIP level defining "completing the same program",
#' for example, from the 2-digit CIP to a 4-digit CIP.
#'
#' The \code{starters} input must have columns \code{id} and \code{cip6}.
#'
#' The function accesses these midfielddata data sets:
#' \code{\link[midfielddata]{midfieldstudents}},
#' \code{\link[midfielddata]{midfieldterms}}, and
#' \code{\link[midfielddata]{midfielddegrees}} or their equivalents.
#'
#' @param starters data frame of students starting in programs
#' @param ... not used, force later arguments to be used by name.
#' @param span numeric scalar, number of years to define successful
#'     graduation, default is 6 years
#' @param cip_level numeric scalar (2, 4, or 6), the CIP level used to
#'     determine if a student completes the program in which they matriculate,
#'     default is 2
#' @param data_students data frame of student attributes
#' @param data_terms data frame of term attributes
#' @param data_degrees data frame of degree attributes
#'
#' @return data frame with the following properties:
#' \itemize{
#'     \item Rows subset to satisfy IPEDS definition
#'     \item Columns \code{id}, \code{start}, and \code{grad_status}
#'     \item Grouping structures are not preserved
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
add_grad_column <- function(starters,
                         ...,
                         span = NULL,
                         cip_level = NULL,
                         data_students = NULL,
                         data_terms = NULL,
                         data_degrees = NULL) {
  wrapr::stop_if_dot_args(
    substitute(list(...)), "Arguments after ... must be named,"
  )

  # defaults
  span <- span %||% 6
  cip_level <- cip_level %||% 2
  data_students <- data_students %||% midfielddata::midfieldstudents
  data_terms <- data_terms %||% midfielddata::midfieldterms
  data_degrees <- data_degrees %||% midfielddata::midfielddegrees

  # check arguments
  assert_explicit(starters)
  assert_class(starters, "data.frame")
  assert_required_column(starters, "id")
  assert_required_column(starters, "cip6")

  assert_class(span, "numeric")
  assert_class(cip_level, "numeric")
  # should also check that cip_level is in {2, 4, 6} only

  assert_class(data_students, "data.frame")
  assert_required_column(data_students, "id")
  assert_required_column(data_students, "term_enter")
  assert_required_column(data_students, "transfer")

  assert_class(data_terms, "data.frame")
  assert_required_column(data_terms, "id")
  assert_required_column(data_terms, "cip6")
  assert_required_column(data_terms, "term")

  assert_class(data_degrees, "data.frame")
  assert_required_column(data_degrees, "id")
  assert_required_column(data_degrees, "cip6")
  assert_required_column(data_degrees, "term_degree")

  # bind names
  start <- NULL
  cip6_degree <- NULL
  cip6_term <- NULL
  grad_status <- NULL
  n_span <- NULL
  term_sum <- NULL
  start_level <- NULL
  degree_level <- NULL

  # gather matriculation data
  rows_we_want <- data_students$id %in% starters$id
  cols_we_want <- c("id", "term_enter", "transfer")
  matric_attr <- data_students[rows_we_want, ..cols_we_want]
  matric_attr <- unique(matric_attr)

  # remove transfer students
  DT <- merge(starters, matric_attr, by = "id", all.x = TRUE)
  # DT <- DT[transfer != "Y"]
  DT[, transfer := NULL]

  # rename starting CIP
  setnames(DT, old = c("cip6"), new = c("cip6_start"))

  # merge degree data
  rows_we_want <- data_degrees$id %in% DT$id
  cols_we_want <- c("id", "cip6", "term_degree")
  degree_attr <- data_degrees[rows_we_want, ..cols_we_want]
  degree_attr <- unique(degree_attr)
  setnames(degree_attr, old = c("cip6"), new = c("cip6_degree"))
  DT <- merge(DT, degree_attr, by = "id", all.x = TRUE)

  # merge term data
  rows_we_want <- data_terms$id %in% DT$id
  cols_we_want <- c("id", "cip6", "term")
  term_attr <- data_terms[rows_we_want, ..cols_we_want]
  DT <- merge(DT, term_attr, by = "id", all.x = TRUE)
  setnames(DT, old = "cip6", new = c("cip6_term"))

  # remove students with both NA term and NA term_degree
  rows_to_omit <- is.na(DT$term) & is.na(DT$term_degree)
  DT <- DT[!rows_to_omit]

  # if term is still NA, replace with term_degree
  DT <- DT[is.na(term), term := term_degree]

  # now we can select the last term by id
  DT <- DT[, .SD[term == max(term)], by = id]
  DT[, term := NULL]
  DT[, cip6_term := NULL]
  DT <- unique(DT)

  # term_degree - span years = term_sum
  # term_enter must be no less than term_sum
  DT <- DT[, n_span := -2 * span]
  DT <- term_add(DT, term_col = "term_degree", n_col = "n_span")
  rows_we_discount <- DT$term_enter < DT$term_sum
  DT[, n_span := NULL]
  DT[, term_sum := NULL]
  DT[rows_we_discount, cip6_degree := NA_character_]

  # apply digit level for comparing starting and ending program CIPs
  DT[, start_level  := substring(cip6_start, 1, cip_level)]
  DT[, degree_level := substring(cip6_degree, 1, cip_level)]

  # discount degree if start and degree CIP not the same
  rows_we_discount <- DT$start_level != DT$degree_level
  DT[rows_we_discount, cip6_degree := NA_character_]
  DT[, term_enter := NULL]
  DT[, term_degree := NULL]
  # DT[, start_level := NULL]
  # DT[, degree_level := NULL]

  # output
  DT[is.na(cip6_degree), grad_status := FALSE]
  DT[!is.na(cip6_degree), grad_status := TRUE]
  # DT[, cip6_degree := NULL]
  data.table::setkey(DT, NULL)
}
