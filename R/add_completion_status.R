

#' Determine program completion status for every student 
#'
#' Add columns to a data frame of Student Unit Record (SUR) 
#' observations that indicate whether a student completed their program, 
#' and if so, whether their completion was timely. Requires a MIDFIELD 
#' \code{degree} data frame in the environment.  
#'
#' By "program completion" we mean an undergraduate earning their 
#' baccalaureate degree. In many studies, students must complete their 
#' programs in a specified time span, for example 4-, 6-, or 8-years after 
#' admission. If they do, their completion is timely; if not, their completion 
#' is untimely and they are grouped with the non-completers when computing 
#' a metric such as graduation rate. 
#' 
#' Completion status is "positive" for students completing their programs 
#' no later than their timely completion terms. See also 
#' \code{add_timely_term()}. 
#'
#' @param dframe Data frame of student unit record (SUR) observations keyed 
#'         by student ID. Required variables are \code{mcid} and 
#'         \code{timely_term}.
#'         
#' @param midfield_degree Data frame of SUR degree observations keyed 
#'         by student ID. Default is \code{degree}. Required variables are 
#'         \code{mcid} and \code{term_degree}.  
#'         
#' @return A \code{data.table}  with the following properties:
#' \itemize{
#'  \item Rows are not modified.
#'  \item Grouping structures are not preserved.
#'  \item Columns listed below are added. \strong{Caution!} An existing column 
#'  with the same name as one of the added columns is silently overwritten. 
#'  Other columns are not modified. 
#' }
#' Columns added:
#' \describe{
#'  \item{\code{term_degree}}{Character. Term in which a program is completed. 
#'  Encoded YYYYT.}
#'  \item{\code{completion}}{Logical. TRUE denotes students completing their 
#'  programs.}
#'  \item{\code{completion_status}}{Character. Label each observation to 
#'  indicate program completion status. Possible values are: 
#'  \code{positive}, indicating programs completed no later than their timely 
#'  completion term; and \code{negative}, indicating programs never completed 
#'  as well as programs completed after their timely completion terms.}
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
  completion <- NULL

  # do the work

  # variables added by this function and functions called (if any)
  new_cols <- c("term_degree", "completion", "completion_status")
  
  # retain original variables NOT in the vector of new columns 
  old_cols <- find_old_cols(dframe, new_cols) 
  dframe <- dframe[, .SD, .SDcols = old_cols]

  # subset midfield data table
  # DT <- filter_match(midfield_degree,
  #   match_to = dframe,
  #   by_col = "mcid",
  #   select = c("mcid", "term_degree")
  # )
 
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

  # add program completion status column
  dframe[, completion := fifelse(is.na(term_degree), FALSE, TRUE)]

  # evaluate, is the completion timely, TRUE / FALSE
  dframe[, completion_status := fifelse(term_degree <= timely_term,
    "positive", 
    "negative",
    na = "negative"
  )]

  # select columns to return
  final_cols <- c(old_cols, new_cols) 
  dframe <- dframe[, .SD, .SDcols = final_cols]
  
  # old columns as keys, order columns and rows
  set_colrow_order(dframe, old_cols)
  
  # enable printing (see data.table FAQ 2.23)
  dframe[] 
}
