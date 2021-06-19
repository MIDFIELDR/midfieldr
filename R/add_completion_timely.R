

#' @importFrom wrapr stop_if_dot_args `%?%`
#' @import data.table
#' @importFrom stats na.omit
#' @importFrom checkmate qassert assert_names
NULL


#' Add a column to evaluate program completion
#'
#' Add a column of logical values (TRUE/FALSE) to a data frame indicating
#' whether a student completes their program in a timely manner. Based on
#' information in the MIDFIELD \code{degree} data table or equivalent.
#'
#' Program completion is typically considered timely if it occurs within a
#' specific span of years after admission. In a persistence metric that depends
#' on program completion (graduation), only students whose program completion
#' is timely are counted as graduates; students whose program completion
#' is un-timely (taking longer than the specific span to complete) are counted
#' as non-graduates.
#'
#' The input data frame \code{dframe} must include the \code{timely_term}
#' column obtained using the \code{add_timely_term()} function. Completion is
#' considered timely if: 1) the student has completed a program; and 2) the
#' degree term is no later than the estimated timely completion term. The
#' function itself performs no subsetting.
#'
#' If \code{details} is TRUE, additional column(s) that support the finding
#' are returned as well. Here the extra columns are \code{completion}
#' indicating by TRUE/FALSE if the student completed their program and
#' \code{term_degree} from the \code{degree} table giving the first term in
#' which degree(s), if any, are earned.
#'
#' Existing columns with the same names as the added columns are overwritten.
#'
#' @param dframe Data frame with required variables
#'        \code{mcid} and \code{timely_term}.
#' @param midfield_degree MIDFIELD \code{degree} data table or equivalent with
#'        required variables \code{mcid} and \code{term}.
#' @param ... Not used, forces later arguments to be used by name.
#' @param details Optional flag to add columns reporting information
#'        on which the evaluation is based, default FALSE.
#' @return A \code{data.table} with the following properties:
#' \itemize{
#'     \item Rows are not modified.
#'     \item Column \code{completion_timely} is added with an option to add
#'           columns \code{completion} and \code{term_degree}.
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
#'
#' @export
#'
#'
add_completion_timely <- function(dframe,
                                  midfield_degree,
                                  ...,
                                  details = NULL) {
  # remove all keys
  on.exit(setkey(dframe, NULL))
  on.exit(setkey(midfield_degree, NULL), add = TRUE)

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
  qassert(midfield_degree, "d+")

  # optional arguments
  details <- details %?% FALSE
  qassert(details, "b1") # boolean, length = 1

  # inputs modified (or not) by reference
  setDT(dframe)
  setDT(midfield_degree) # immediately subset, so side-effect OK

  # required columns
  assert_names(colnames(dframe),
               must.include = c("mcid", "timely_term"))
  assert_names(colnames(midfield_degree),
               must.include = c("mcid", "term"))

  # class of required columns
  qassert(dframe[, mcid], "s+")
  qassert(dframe[, timely_term], "s+")
  qassert(midfield_degree[, mcid], "s+")
  qassert(midfield_degree[, term], "s+")

  # bind names due to NSE notes in R CMD check
  completion_timely <- NULL
  term_degree <- NULL
  timely_term <- NULL
  completion <- NULL

  # do the work
  # preserve "term" column if exists in incoming df
  names_dframe <- colnames(dframe)
  if ("term" %chin% names_dframe) {
    setnames(dframe, old = "term", new = "existing_term_col")
  }

  # preserve column order except columns that match new columns
  cols_we_add <- c("term_degree", "completion", "completion_timely")
  key_names <- names_dframe[!names_dframe %chin% cols_we_add]
  dframe <- dframe[, key_names, with = FALSE]

  # subset midfield data table
  DT <- filter_match(midfield_degree,
    match_to = dframe,
    by_col = "mcid",
    select = c("mcid", "term")
  )

  # keep the first degree term
  setorderv(DT, c("mcid", "term"))
  DT <- na.omit(DT, cols = c("term"))
  DT <- DT[, .SD[1], by = "mcid"]
  setkey(DT, NULL)

  # rename term to term-degree
  setnames(DT, old = "term", new = "term_degree")

  # left-outer join, keep all rows of dframe
  dframe <- merge(dframe, DT, by = "mcid", all.x = TRUE)

  # add program completion status column
  dframe[, completion := fifelse(is.na(term_degree), FALSE, TRUE)]

  # evaluate, is the completion timely, TRUE / FALSE
  dframe[, completion_timely := fifelse(term_degree <= timely_term,
    TRUE, FALSE,
    na = FALSE
  )]

  # restore column and row order
  set_colrow_order(dframe, key_names)

  # include or omit the details columns
  if (details == FALSE) {
    cols_we_want <- c(key_names, "completion_timely")
    dframe <- dframe[, cols_we_want, with = FALSE]
  }

  # restore "term" column if exists in incoming df
  if ("existing_term_col" %chin% names(dframe)) {
    setnames(dframe, old = "existing_term_col", new = "term")
  }

  # enable printing (see data.table FAQ 2.23)
  dframe[]
}
