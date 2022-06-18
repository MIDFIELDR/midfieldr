

#' Determine program completion and timeliness for every student 
#'
#' Add a column of true/false values to a data frame of Student Unit Record 
#' (SUR) observations indicating whether a student completes their program 
#' in a timely manner. A column of CIP codes of their degree programs 
#' is returned as well. 
#'
#' Program completion is typically considered timely if it occurs within a
#' specified span of years after admission (default 6 years). In many studies, 
#' only students whose program completion is timely are counted as graduates; 
#' students whose program completion is untimely (taking longer than the 
#' specific span to complete) are counted as non-graduates.
#'
#' Completion is considered timely if: 1) the student has completed a 
#' program; and 2) the degree term is no later than the estimated timely 
#' completion term.
#'
#' The optional \code{details} argument returns the additional variables used 
#' in determining the results: whether a student completed their program and 
#' the term in which their first degree(s), if any, are earned.
#'
#' @section Caution:
#' Existing columns with the same names as the added columns are silently 
#' overwritten.
#'
#' @param dframe Data frame of student unit record (SUR) observations keyed 
#'         by student ID. Required variables are \code{mcid} and 
#'         \code{timely_term}.
#' @param midfield_degree MIDFIELD degree data frame keyed by student ID.  
#'         Default is \code{degree}. Required variables are \code{mcid} 
#'         and \code{term_degree}.
#' @param ... Not used, forces later arguments to be used by name.
#' @param details TRUE returns the additional variables used in
#'         determining the results. Default is FALSE.
#' @return A \code{data.table} with the following properties:
#' \itemize{
#'     \item Rows are not modified.
#'     \item Columns \code{cip6_degree} and code{timely_completion} are
#'     added; additional columns are added via the \code{details} argument. 
#'     \item Grouping structures are not preserved.
#' }
#'
#'
#' @family add_*
#'
#'
#' @example man/examples/add_timely_completion_exa.R
#'
#'
#' @export
#'
#'
add_timely_completion <- function(dframe,
                                  midfield_degree = degree,
                                  ...,
                                  details = NULL) {
  on.exit(setkey(dframe, NULL), add = TRUE)
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
  qassert(details, "B1") # boolean, missing values prohibited, length 1

  # inputs modified (or not) by reference
  setDT(dframe)
  setDT(midfield_degree) # immediately subset, so side-effect OK

  # required columns
  assert_names(colnames(dframe),
    must.include = c("mcid", "timely_term")
  )
  assert_names(colnames(midfield_degree),
    must.include = c("mcid", "term_degree")
  )

  # class of required columns
  qassert(dframe[, mcid], "s+")
  qassert(dframe[, timely_term], "s+")
  qassert(midfield_degree[, mcid], "s+")
  qassert(midfield_degree[, term_degree], "s+")

  # bind names due to NSE notes in R CMD check
  timely_completion <- NULL
  timely_term <- NULL
  term_degree <- NULL
  completion <- NULL

  # do the work

  # variables added by this function and functions called (if any)
  new_cols <- c("term_degree", "cip6_degree", "completion", "timely_completion")
  
  # retain original variables NOT in the vector of new columns 
  old_cols <- find_old_cols(dframe, new_cols) 
  dframe <- dframe[, .SD, .SDcols = old_cols]

  # subset midfield data table
  DT <- filter_match(midfield_degree,
    match_to = dframe,
    by_col = "mcid",
    select = c("mcid", "term_degree", "cip6")
  )

  # rename
  setnames(DT, old = c("cip6"), new = c("cip6_degree"))

  # keep the first degree term
  setorderv(DT, c("mcid", "term_degree"))
  DT <- na.omit(DT, cols = c("term_degree"))
  DT <- DT[, .SD[1], by = "mcid"]
  setkey(DT, NULL)

  # left-outer join, keep all rows of dframe
  dframe <- merge(dframe, DT, by = "mcid", all.x = TRUE)

  # add program completion status column
  dframe[, completion := fifelse(is.na(term_degree), FALSE, TRUE)]

  # evaluate, is the completion timely, TRUE / FALSE
  dframe[, timely_completion := fifelse(term_degree <= timely_term,
    TRUE, 
    FALSE,
    na = FALSE
  )]

  # apply details to select columns to return
  if (details == TRUE){
      final_cols <- c(old_cols, new_cols) 
  } else {
      final_cols <- c(old_cols, "cip6_degree", "timely_completion")
  }
  dframe <- dframe[, .SD, .SDcols = final_cols]
  
  # old columns as keys, order columns and rows
  set_colrow_order(dframe, old_cols)
  
  # enable printing (see data.table FAQ 2.23)
  dframe[] 
}
