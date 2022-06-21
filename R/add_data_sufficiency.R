

#' Determine data sufficiency for every student
#'
#' Add a column to a data frame of Student Unit Record (SUR) 
#' observations that labels each row for inclusion or exclusion based on data 
#' sufficiency near the upper and lower bounds of an institution's data range. 
#' Requires a MIDFIELD \code{term} data frame in the environment.  
#'
#' The time span of MIDFIELD term data varies by institution, each having 
#' their own lower and upper bounds. For some student records, being at or 
#' near these bounds creates unavoidable ambiguity when trying to assess 
#' program completion. Such records must be identified and in most cases 
#' excluded to prevent false summary counts.
#'
#' @param dframe Data frame of student unit record (SUR) observations keyed 
#'         by student ID. Required variables are \code{mcid} and 
#'         \code{timely_term}. See also \code{add_timely_term()}.
#'         
#' @param midfield_term Data frame of SUR term observations keyed 
#'         by student ID. Default is \code{term}. Required variables are 
#'         \code{mcid}, \code{institution}, and \code{term}. 
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
#'  \item{\code{term_i}}{Character. Initial term of a student's longitudinal 
#'  record, encoded YYYYT. Not overwritten if present in \code{dframe}.}
#'  \item{\code{lower_limit}}{Character. Initial term of an institution's data 
#'  range, encoded YYYYT}
#'  \item{\code{upper_limit}}{Character. Final term of an institution's data 
#'  range, encoded YYYYT}
#'  \item{\code{data_sufficiency}}{Character. Label each observation for 
#'  inclusion or exclusion based on data sufficiency. Possible values are: 
#'  \code{include}, indicating that available data are sufficient for 
#'  estimating timely program completion; \code{exclude-upper}, indicating 
#'  that data are insufficient at the upper limit of a data range; and 
#'  \code{exclude-lower}, indicating that data are insufficient at the 
#'  lower limit.}
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
add_data_sufficiency <- function(dframe, midfield_term = term) {
    # remove keys if any 
    on.exit(setkey(dframe, NULL))
    on.exit(setkey(midfield_term, NULL), add = TRUE)

  # required arguments
  qassert(dframe, "d+")
  qassert(midfield_term, "d+")

  # ensure data.table format, changes by reference 
  setDT(dframe)
  setDT(midfield_term)

  # required columns
  assert_names(colnames(dframe),
               must.include = c("mcid", "timely_term")
  )
  assert_names(colnames(midfield_term),
               must.include = c("mcid", "institution", "term")
  )

  # class of required columns
  qassert(dframe[, mcid], "s+")
  qassert(dframe[, timely_term], "s+")
  qassert(midfield_term[, mcid], "s+")
  qassert(midfield_term[, institution], "s+")
  qassert(midfield_term[, term], "s+")

  # bind names due to NSE notes in R CMD check
  data_sufficiency <- NULL
  timely_term <- NULL
  upper_limit <- NULL
  lower_limit <- NULL
  term_i <- NULL

  # do the work

  # variables added by this function and functions called (if any)
  inst_limits_cols <- c("lower_limit", "upper_limit")
  new_cols <- c( "term_i", inst_limits_cols, "data_sufficiency")

  # retain original variables NOT in the vector of new columns 
  old_cols <- find_old_cols(dframe, new_cols) 
  dframe <- dframe[, .SD, .SDcols = old_cols]
  
  # begin
  DT <- copy(dframe)
  
  # add initial term term_i
  DT <- add_initial_term(DT, midfield_term)

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
  
  # select columns to return
  final_cols <- c(old_cols, new_cols) 
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
    
    # add institution if not present
    if(!"institution" %chin% names(dframe)){
        dframe <- add_institution(dframe, midfield_term = midfield_term)
    }
    
    # variables added by this function
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
    
    # enable printing (see data.table FAQ 2.23)
    dframe[] 
}

