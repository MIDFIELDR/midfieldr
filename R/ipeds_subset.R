#' @importFrom data.table setDT setDF setnames %chin% setnafill
#' @importFrom wrapr stop_if_dot_args
NULL

#' Subset rows for IPEDS constraints
#'
#' Subset a data frame of student IDs and starting programs, retaining
#' students satisfying the constraints of the IPEDS definition for
#' successful graduation. The results adds a yes/no column \code{ipeds_grad} to
#' indicate whether the student's graduation satisfied the IPREDS constraints.
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
ipeds_subset <- function (starters,
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
  data_terms    <- data_terms    %||% midfielddata::midfieldterms
  data_degrees  <- data_degrees  %||% midfielddata::midfielddegrees

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

  # gather matriculation data
  matric_attr <- filter_by_id(data_students,
                              keep_id = starters$id,
                              keep_col = c("id", "term_enter", "transfer"),
                              unique_row = TRUE)

  # remove transfer students
  DT <- merge(starters, matric_attr, by = "id", all.x = TRUE)
  DT <- DT[transfer != "Y"]
  DT[, transfer := NULL]

  # merge degree data
  degree_attr <- filter_by_id(data_degrees,
                              keep_id = DT$id,
                              keep_col = c("id", "cip6", "term_degree"))
  setnames(degree_attr, old = c("cip6"), new = c("cip_degree"))
  DT <- merge(DT, degree_attr, by = "id", all.x = TRUE)

  # merge term data
  term_attr <- filter_by_id(data_terms,
                            keep_id = DT$id,
                            keep_col = c("id", "cip6", "term"))
  DT <- merge(DT, term_attr , by = "id", all.x = TRUE)
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

  # discount degree if > span
  rows_we_discount <- DT$term_degree - DT$term_enter > 60 |
    is.na(DT$term_degree)
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
}
