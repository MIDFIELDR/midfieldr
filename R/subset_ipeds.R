#' @importFrom data.table setDT setDF setnames %chin% setnafill setkey
#' @importFrom wrapr stop_if_dot_args
NULL

#' Subset rows for IPEDS constraints
#'
#' Subset a data frame of student IDs and starting programs, retaining
#' students satisfying the constraints of the IPEDS definition for
#' successful graduation. The results adds a yes/no column
#' \code{ipeds_grad} to indicate whether the student's graduation satisfied
#' the IPEDS constraints.
#'
#' The \code{starters} input must have columns \code{id} and \code{start}.
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
#' @param data_students data frame of student attributes
#' @param data_terms data frame of term attributes
#' @param data_degrees data frame of degree attributes
#'
#' @return data frame with the following properties:
#' \itemize{
#'     \item Rows subset to satisfy IPEDS definition
#'     \item Columns \code{id}, \code{start}, and \code{ipeds_grad}
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
subset_ipeds <- function(starters,
                         ...,
                         span = NULL,
                         data_students = NULL,
                         data_terms = NULL,
                         data_degrees = NULL) {
  wrapr::stop_if_dot_args(
    substitute(list(...)), "Arguments after ... must be named,"
  )

  # defaults
  span <- span %||% 6
  data_students <- data_students %||% midfielddata::midfieldstudents
  data_terms <- data_terms %||% midfielddata::midfieldterms
  data_degrees <- data_degrees %||% midfielddata::midfielddegrees

  # check arguments
  assert_explicit(starters)
  assert_class(starters, "data.frame")
  assert_required_column(starters, "id")
  assert_required_column(starters, "start")

  assert_class(span, "numeric")

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
  cip_degree <- NULL
  cip_term <- NULL
  ipeds_grad <- NULL
  n_span <- NULL
  term_sum <- NULL

  # gather matriculation data
  rows_we_want <- data_students$id %in% starters$id
  cols_we_want <- c("id", "term_enter", "transfer")
  matric_attr <- data_students[rows_we_want, ..cols_we_want]
  matric_attr <- unique(matric_attr)

  # remove transfer students
  DT <- merge(starters, matric_attr, by = "id", all.x = TRUE)
  DT <- DT[transfer != "Y"]
  DT[, transfer := NULL]

  # merge degree data
  rows_we_want <- data_degrees$id %in% DT$id
  cols_we_want <- c("id", "cip6", "term_degree")
  degree_attr <- data_degrees[rows_we_want, ..cols_we_want]
  degree_attr <- unique(degree_attr)
  setnames(degree_attr, old = c("cip6"), new = c("cip_degree"))
  DT <- merge(DT, degree_attr, by = "id", all.x = TRUE)

  # merge term data
  rows_we_want <- data_terms$id %in% DT$id
  cols_we_want <- c("id", "cip6", "term")
  term_attr <- data_terms[rows_we_want, ..cols_we_want]
  DT <- merge(DT, term_attr, by = "id", all.x = TRUE)
  setnames(DT, old = c("cip6"), new = c("cip_term"))

  # remove students with both NA term and NA term_degree
  rows_to_omit <- is.na(DT$term) & is.na(DT$term_degree)
  DT <- DT[!rows_to_omit]

  # if term is still NA, replace with term_degree
  DT <- DT[is.na(term), term := term_degree]

  # now we can select the last term by id
  DT <- DT[, .SD[term == max(term)], by = id]
  DT[, term := NULL]
  DT[, cip_term := NULL]
  DT <- unique(DT)

  # term_degree - span years = term_sum
  # term_enter must be no less than term_sum
  DT <- DT[, n_span := -2 * span]
  DT <- term_add(DT, term_col = "term_degree", n_col = "n_span")
  rows_we_discount <- DT$term_enter < DT$term_sum
  DT[, n_span := NULL]
  DT[, term_sum := NULL]
  DT[rows_we_discount, cip_degree := NA_character_]

  # discount degree if start and degree CIP not the same
  rows_we_discount <- DT$start != DT$cip_degree
  DT[rows_we_discount, cip_degree := NA_character_]
  DT[, term_enter := NULL]
  DT[, term_degree := NULL]

  # output
  DT[is.na(cip_degree), ipeds_grad := "N"]
  DT[!is.na(cip_degree), ipeds_grad := "Y"]
  DT[, cip_degree := NULL]
  data.table::setkey(DT, NULL)
}
