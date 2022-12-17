

#' Determine completion status for every student
#'
#' Add columns to a data frame of student-level records that indicate whether a
#' student completed a degree, and if so, whether their completion was timely.
#'
#' By "completion" we mean an undergraduate earning their first baccalaureate
#' degree (or degrees, for students earning more than one degree in the same
#' term). Additional degrees, if any, earned later than the term of the first
#' degree are ignored.
#'
#' In many studies, students must complete a degree in a specified time span,
#' for example 4-, 6-, or 8-years after admission. If they do, their completion
#' is timely; if not, their completion is late and they are grouped with the
#' non-completers when computing a metric such as graduation rate.
#'
#' Completion status is "timely" for students completing a degree no later than
#' their timely completion terms. See also `add_timely_term()`.
#'
#' @param dframe Data frame of student-level records keyed by student ID.
#'   Required variables are `mcid` and `timely_term.`
#'
#' @param midfield_degree Data frame of student-level degree observations keyed
#'   by student ID. Default is `degree.` Required variables are `mcid`
#'   and `term_degree.`
#'         
#' @return A `data.table` with the following properties:
#' \itemize{
#'  \item Rows are not modified.
#'  \item Grouping structures are not preserved.
#'  \item Columns listed below are added. __Caution!__ An existing column 
#'  with the same name as one of the added columns is silently overwritten. 
#'  Other columns are not modified. 
#' }
#' Columns added:
#' \describe{
#'  \item{`term_degree`}{Character. Term in which the first degree(s) are 
#'  completed. Encoded YYYYT. Joined from `midfield_degree` data table.}
#'  \item{`completion_status`}{Character. Label each observation to 
#'  indicate completion status. Possible values are: "timely", indicating 
#'  completion no later than the timely completion term; "late", indicating 
#'  completion after the timely completion term; and "NA" indicating 
#'  non-completion.}
#' }
#'
#'
#' @family add_*
#'
#'
#' @example man/examples/add_completion_status_exa.R
#'
#'
#' @export
#'
#'
add_completion_status <- function(dframe, midfield_degree = degree) {
  on.exit(setkey(dframe, NULL), add = TRUE)
  on.exit(setkey(midfield_degree, NULL), add = TRUE)

  # required arguments
  qassert(dframe, "d+")
  qassert(midfield_degree, "d+")

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
  completion_status <- NULL
  timely_term <- NULL
  term_degree <- NULL

  # do the work

  # variables added by this function and functions called (if any)
  new_cols <- c("term_degree", "completion_status")
  
  # retain original variables NOT in the vector of new columns 
  old_cols <- find_old_cols(dframe, new_cols) 
  dframe <- dframe[, .SD, .SDcols = old_cols]
 
  # Inner join using three columns of term
  x <- midfield_degree[, .(mcid, term_degree)]
  y <- unique(dframe[, .(mcid)])
  DT <- y[x, on = .(mcid), nomatch = NULL]

  # keep the first degree term
  setorderv(DT, c("mcid", "term_degree"))
  DT <- na.omit(DT, cols = c("term_degree"))
  DT <- DT[, .SD[1], by = "mcid"]
  setkey(DT, NULL)

  # left-outer join, keep all rows of dframe
  dframe <- merge(dframe, DT, by = "mcid", all.x = TRUE)

  # completion is timely, late, or NA
  dframe[, completion_status := fifelse(term_degree <= timely_term,
    "timely", 
    "late",
    na = NA_character_
  )]

  # select columns to return
  final_cols <- c(old_cols, new_cols) 
  dframe <- dframe[, .SD, .SDcols = final_cols]
  
  # old columns as keys, order columns and rows
  set_colrow_order(dframe, old_cols)
  
  # enable printing (see data.table FAQ 2.23)
  dframe[] 
}
