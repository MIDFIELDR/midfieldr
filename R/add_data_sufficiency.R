

#' Determine data sufficiency for every student
#'
#' Add a column of values to a data frame of Student Unit Record (SUR) 
#' observations labeling each row for inclusion or exclusion based on data 
#' sufficiency near the upper and lower bounds of an institution's data range. 
#'
#' The time span of MIDFIELD data varies by institution, each having 
#' their own lower and upper bounds. For some student records at these 
#' bounds, assessing program completion is unavoidably ambiguous. Such 
#' records must be identified and excluded in most cases to prevent false 
#' summary counts.
#' 
#' The \code{data_sufficiency} variable added to \code{dframe} contains 
#' three possible values: \code{include} indicates that available data are 
#' sufficient for estimating timely program completion;  
#' \code{exclude-upper} indicates that data are insufficient at the 
#' upper limit of a data range; \code{exclude-lower} that data are 
#' insufficient at the lower limit.
#' 
#' The optional \code{details} argument returns the additional variables used in
#' determining the results: a student's institution and the upper and lower 
#' limits of its data range; and a student's initial term and level. 
#' 
#' @section Caution:
#' Existing columns with the same names as the added columns are silently 
#' overwritten.
#'
#' @param dframe Data frame of student unit record (SUR) observations keyed 
#'         by student ID. Required variables are \code{mcid} and 
#'         \code{timely_term}. 
#' @param midfield_term MIDFIELD term data frame keyed by student ID.  
#'         Default is \code{term}. Required variables are \code{mcid}, 
#'         \code{term}, and \code{level}. 
#' @param ... Not used, forces later arguments to be used by name.
#' @param details Optional logical value. TRUE returns the additional 
#'         variables used in determining the results. Default is FALSE.
#' @return A \code{data.table}  with the following properties:
#' \itemize{
#'     \item Rows are not modified.
#'     \item Column \code{data_sufficiency} is added; additional columns 
#'     are added via the \code{details} argument.  
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
                                 midfield_term = term,
                                 ...,
                                 details = NULL) {
    # remove keys if any 
    on.exit(setkey(dframe, NULL))
    on.exit(setkey(midfield_term, NULL), add = TRUE)
    
    # assert arguments after dots used by name
    wrapr::stop_if_dot_args(
        substitute(list(...)),
        paste(
            "Arguments after ... must be named.\n",
            "* Did you forget to write `detail = `?\n *"
        )
    )

  # required arguments
  qassert(dframe, "d+")
  qassert(midfield_term, "d+")
  
  # optional arguments
  details <- details %?% FALSE
  qassert(details, "B1") # boolean, length = 1

  # ensure data.table format, changes by reference 
  setDT(dframe)
  setDT(midfield_term)

  # required columns
  assert_names(colnames(dframe),
               must.include = c("mcid", "timely_term")
  )
  assert_names(colnames(midfield_term),
               must.include = c("mcid", "institution", "term", "level")
  )

  # class of required columns
  qassert(dframe[, mcid], "s+")
  qassert(dframe[, timely_term], "s+")
  qassert(midfield_term[, mcid], "s+")
  qassert(midfield_term[, institution], "s+")
  qassert(midfield_term[, term], "s+")
  qassert(midfield_term[, level], "s+")

  # bind names due to NSE notes in R CMD check
  data_sufficiency <- NULL
  upper_limit <- NULL
  lower_limit <- NULL
  term_i <- NULL

  # do the work

  # variables added by this function and functions called (if any)
  add_inst_limits_cols    <- c("lower_limit", "upper_limit")
  new_cols <- c(add_inst_limits_cols, "data_sufficiency")
  
  # retain original variables NOT in the vector of new columns 
  old_cols <- find_old_cols(dframe, new_cols) 
  dframe <- dframe[, .SD, .SDcols = old_cols]
  
  # begin
  DT <- copy(dframe)
  
  # obtain timely completion term
  # DT <- add_timely_term(DT, midfield_term, details = TRUE)
  
  # obtain lower and upper institution data limits
  DT <- add_inst_limits(DT, midfield_term)
  
  # default is include
  DT[, data_sufficiency := "include"]
  
  # exclude if TC term exceeds upper limit
  DT <- DT[timely_term > upper_limit, data_sufficiency := "exclude-upper"]
  
  # exclude if term_i == lower_limit
  DT <- DT[term_i == lower_limit, data_sufficiency := "exclude-lower"]
  
  # remove all but essential variables
  DT <- DT[, .SD, .SDcols = c("mcid", new_cols)]
  
  # ensure no duplicate rows
  setkeyv(DT, "mcid")
  DT <- DT[, .SD[1], by = "mcid"]
  
  # left outer join new columns to dframe by key(s)
  setkeyv(dframe, "mcid")
  dframe <- DT[dframe]
  
  # apply details to select columns to return
  if (details == TRUE){
      final_cols <- c(old_cols, new_cols) 
  } else {
      final_cols <- c(old_cols, "data_sufficiency")
  }
  dframe <- dframe[, .SD, .SDcols = final_cols]
  
  # old columns as keys, order columns and rows
  set_colrow_order(dframe, old_cols)
  
  # enable printing (see data.table FAQ 2.23)
  dframe[] 
}

# ------------------------------------------------------------------------

# Add upper and lower limits of institution data range

add_inst_limits <- function(dframe, midfield_term) {
    
    # remove keys if any 
    on.exit(setkey(dframe, NULL))
    on.exit(setkey(midfield_term, NULL), add = TRUE)
    
    # ensure data.table format, changes by reference 
    setDT(dframe)
    setDT(midfield_term)
    
    # variables added by this function and functions called (if any)
    new_cols  <- c("lower_limit", "upper_limit")
    
    # retain original variables NOT in the vector of new columns 
    old_cols <- find_old_cols(dframe, new_cols) 
    dframe <- dframe[, .SD, .SDcols = old_cols]
    
    # obtain new_cols keyed by institution, 
    cols_we_want <- c("institution", "term")
    DT <- midfield_term[, .SD, .SDcols = cols_we_want]
    DT <- DT[, list(lower_limit = min(term), 
                    upper_limit = max(term)), by = "institution"]
    
    # ensure no duplicate rows
    DT <- unique(DT)
    
    # left outer join new columns to dframe by key(s)
    setkeyv(DT, "institution")
    setkeyv(dframe, "institution")
    dframe <- DT[dframe] 
    
    # old columns as keys, order columns and rows
    # set_colrow_order(dframe, old_cols)
    
    # enable printing (see data.table FAQ 2.23)
    dframe[] 
}

