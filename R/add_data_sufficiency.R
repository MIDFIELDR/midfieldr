

#' Add a column to evaluate data sufficiency
#'
#' Add a column of logical values (TRUE/FALSE) to a data frame indicating
#' whether the available data include a sufficient range of years to justify
#' including a student in an analysis. Obtains the information from the
#' MIDFIELD \code{term} data table or equivalent.
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
#' If the result in the \code{data_sufficiency} column is TRUE, then then
#' student should be included in the research. If FALSE, the student should
#' be excluded before calculating any persistence metric involving program
#' completion (graduation). The function itself performs no subsetting.
#'
#' If \code{detail} is TRUE, additional column(s) that support the finding
#' are returned as well. Here the extra column is \code{inst_limit}, the latest
#' term reported by the institution in the available data.
#'
#' Existing columns with the same names as the added columns are overwritten.
#'
#' @param dframe Data frame with required variables
#'        \code{institution} and \code{timely_term}.
#' @param midfield_term MIDFIELD \code{term} data table or equivalent
#'        with required variables \code{institution} and \code{term}.
#' @param ... Not used, forces later arguments to be used by name.
#' @param detail Optional flag to add columns reporting information
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
#' @example man/examples/add_data_sufficiency_exa.R
#'
#'
#' @export
#'
#'
add_data_sufficiency <- function(dframe,
                                 midfield_term,
                                 ...,
                                 detail = NULL) {
  # remove all keys
  on.exit(setkey(dframe, NULL))
  on.exit(setkey(midfield_term, NULL), add = TRUE)

  # required arguments
  qassert(dframe, "d+")
  qassert(midfield_term, "d+")

  # assert arguments after dots used by name
  wrapr::stop_if_dot_args(
    substitute(list(...)),
    paste(
      "Arguments after ... must be named.\n",
      "* Did you forget to write `detail = `?\n *"
    )
  )

  # optional arguments
  detail <- detail %?% FALSE
  qassert(detail, "B1") # boolean, length = 1

  # inputs modified (or not) by reference
  setDT(dframe)
  setDT(midfield_term) # immediately subset, so side-effect OK

  # required columns
  assert_names(colnames(dframe),
    must.include = c("institution", "timely_term")
  )
  assert_names(colnames(midfield_term),
    must.include = c("institution", "term")
  )

  # class of required columns
  qassert(dframe[, institution], "s+")
  qassert(dframe[, timely_term], "s+")
  qassert(midfield_term[, term], "s+")
  qassert(midfield_term[, institution], "s+")

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

  # from midfield_term, get institution last term
  dframe <- add_inst_limit(dframe, midfield_term = midfield_term)

  # assess the data sufficiency
  dframe[, data_sufficiency := fifelse(timely_term <= inst_limit, TRUE, FALSE)]

  # restore column and row order
  set_colrow_order(dframe, key_names)

  # include or omit the detail columns
  if (detail == FALSE) {
    cols_we_want <- c(key_names, "data_sufficiency")
    dframe <- dframe[, cols_we_want, with = FALSE]
  }

  # enable printing (see data.table FAQ 2.23)
  dframe[]
}

# ------------------------------------------------------------------------

# Add term range by institution
#
# Determine the latest academic term by institution in \code{midfield_term}.
# Left-join by institution to \code{dframe} in a new column \code{inst_limit}.
#
# dframe            data frame that received added column
# midfield_term     data frame of term attributes
#
add_inst_limit <- function(dframe, midfield_term) {

  # prepare dframe, preserve column order for return
  # omit existing column(s) that match column(s) we add
  setDT(dframe)
  setDT(midfield_term)
  added_cols <- c("inst_limit")
  names_dframe <- colnames(dframe)
  key_names <- names_dframe[!names_dframe %chin% added_cols]
  dframe <- dframe[, key_names, with = FALSE]

  # get max term by institution
  cols_we_want <- c("institution", "term")
  DT <- midfield_term[, cols_we_want, with = FALSE]
  DT <- DT[, list(inst_limit = max(term)), by = "institution"]

  # left-outer join, keep all rows of dframe
  dframe <- merge(dframe, DT, by = "institution", all.x = TRUE)

  # original columns as keys, order columns and rows
  set_colrow_order(dframe, key_names)
  return(dframe)
}
