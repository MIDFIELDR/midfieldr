

#' @import data.table
#' @importFrom wrapr stop_if_dot_args
#' @importFrom checkmate qassert assert_names
NULL


#' Add a column to evaluate data sufficiency
#'
#' Add a column of logical values (TRUE/FALSE) to a data frame indicating
#' whether the available data include a sufficient range of years to justify
#' including a student in an analysis. Based on information in the MIDFIELD
#' \code{term} data table or equivalent.
#'
#' Program completion is typically considered timely if it occurs within a
#' specific span of years after admission. Students admitted too near the
#' last term in the available data are generally excluded from a study because
#' the data have insufficient range to fairly assess their records.
#'
#' The input data frame \code{dframe} must include the \code{timely_term}
#' column obtained using the \code{add_timely_term()} function. Students can be
#' retained in a study if their estimated timely completion term is no later
#' than the last term in their institution's data.
#'
#' If the result in the \code{data_sufficiency} column is TRUE, then then student
#' should be included in the research. If FALSE, the student should be excluded
#' before calculating any persistence metric involving program completion
#' (graduation). The function itself performs no subsetting.
#'
#' If \code{details} is TRUE, additional column(s) that support the finding
#' are returned as well. Here the extra column is \code{inst_limit}, the latest
#' term reported by the institution in the available data.
#'
#' Existing columns with the same names as the added columns are overwritten.
#'
#' @param dframe Data frame with required variables
#'        \code{institution} and \code{timely_term}.
#' @param midfield_table MIDFIELD \code{term} data table or equivalent
#'        with required variables \code{institution} and \code{term}.
#' @param ... Not used, forces later arguments to be used by name.
#' @param details Optional flag to add columns reporting information
#'        on which the evaluation is based, default FALSE.
#' @return A \code{data.table}  with the following properties:
#' \itemize{
#'     \item Rows are not modified.
#'     \item Column \code{data_sufficiency} is added with an option to add
#'           column \code{inst_limit}.
#'     \item Grouping structures are not preserved.
#' }
#'
#'
#' @family add_*
#'
#'
#' @examples
#' # TBD
#'
#'
#' @export
#'
#'
add_data_sufficiency <- function(dframe,
                                 midfield_table,
                                 ...,
                                 details = NULL) {
  # remove all keys
  on.exit(setkey(dframe, NULL))
  on.exit(setkey(midfield_table, NULL), add = TRUE)

  # assert arguments after dots used by name
  wrapr::stop_if_dot_args(
    substitute(list(...)),
    paste(
      "Arguments after ... must be named.\n",
      "* Did you forget to write `details = `?\n *"
    )
  )

  # required arguments
  qassert(dframe, "d+")
  qassert(midfield_table, "d+")

  # optional arguments
  details <- details %||% FALSE
  qassert(details, "b1") # boolean, length = 1

  # inputs modified (or not) by reference
  setDT(dframe)
  setDT(midfield_table) # immediately subset, so side-effect OK

  # required columns
  assert_names(colnames(dframe),
               must.include = c("institution", "timely_term"))
  assert_names(colnames(midfield_table),
               must.include = c("institution", "term"))

  # class of required columns
  qassert(dframe[, institution], "s+")
  qassert(dframe[, timely_term], "s+")
  qassert(midfield_table[, term], "s+")
  qassert(midfield_table[, institution], "s+")

  # bind names due to NSE notes in R CMD check
  data_sufficiency <- NULL
  timely_term <- NULL
  inst_limit <- NULL

  # do the work
  # preserve column order except columns that match new columns
  names_dframe <- colnames(dframe)
  cols_we_add <- c("inst_limit", "data_sufficiency")
  key_names <- names_dframe[!names_dframe %chin% cols_we_add]
  dframe <- dframe[, key_names, with = FALSE]

  # from midfield_table, get institution last term
  dframe <- add_inst_limit(dframe, midfield_table = midfield_table)

  # assess the data sufficiency
  dframe[, data_sufficiency := fifelse(timely_term <= inst_limit, TRUE, FALSE)]

  # restore column and row order
  set_colrow_order(dframe, key_names)

  # include or omit the details columns
  if (details == FALSE) {
    cols_we_want <- c(key_names, "data_sufficiency")
    dframe <- dframe[, cols_we_want, with = FALSE]
  }

  # enable printing (see data.table FAQ 2.23)
  dframe[]
}
