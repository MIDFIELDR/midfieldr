

#' Calculate a timely completion term for every student 
#' 
#' Add a column to a data frame of Student Unit Record (SUR) 
#' observations that indicates the latest term by which program completion 
#' would be considered timely for every student. Requires a MIDFIELD 
#' \code{term} data frame in the environment.  
#' 
#' By "program completion" we mean an undergraduate earning their 
#' baccalaureate degree. In many studies, students must complete their 
#' programs in a specified time span, for example 4-, 6-, or 8-years after 
#' admission. If they do, their completion is timely; if not, their completion 
#' is untimely and they are grouped with the non-completers when computing 
#' a metric such as graduation rate. 
#' 
#' Our heuristic assigns \code{span} number of years (default is 6 years) to 
#' every student. For students admitted at second-year level or higher, the 
#' span is reduced by one year for each full year the student is assumed 
#' to have completed. For example, a student admitted at the 
#' second-year level is assumed to have completed one year of a program, 
#' so their span is reduced by one year.
#' 
#' The adjusted span is added to the initial term to create the timely 
#' completion term in the \code{timely_term} column.
#'
#' @param dframe Data frame of student unit record (SUR) observations keyed 
#'         by student ID. Required variable is \code{mcid}.
#'         
#' @param midfield_term Data frame of SUR term observations keyed 
#'         by student ID. Default is \code{term}. Required variables are 
#'         \code{mcid}, \code{term}, and \code{level}.         
#'        
#' @param ... Not used, forces later arguments to be used by name.
#'         
#' @param span Optional integer scalar, number of years to define timely
#'        completion. Commonly used values are are 100\%, 150\%, and 200\% of  
#'        \code{sched_span}. Default 6 years.
#'        
#' @param sched_span Optional integer scalar, the number of years an
#'        institution officially schedules for completing a program. Default
#'        4 years.
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
#'  record, encoded YYYYT}
#'  \item{\code{level_i}}{Character. Student level (01 Freshman, 02 Sophomore, 
#'  etc.) in their initial term}
#'  \item{\code{adj_span}}{Numeric. Integer span of years for timely completion 
#'  adjusted for a student's initial level.}
#'  \item{\code{timely_term}}{Character. Latest term by which program 
#'  completion would be considered timely for every student. Encoded YYYYT.}
#' }
#'
#'
#' @family add_*
#'
#'
#' @example man/examples/add_timely_term_exa.R
#'
#'
#' @export
#'
#'
add_timely_term <- function(dframe,
                            midfield_term = term,
                            ...,
                            span = NULL,
                            sched_span = NULL) {
    
    # remove keys if any 
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
            "* Did you forget to write `details = ` or `span = `?\n *"
        )
    )
    
    # optional arguments
    span <- span %?% 6
    sched_span <- sched_span %?% 4
    
    # optional arguments assertions
    assert_int(sched_span, lower = 0)
    assert_int(span, lower = sched_span)
    
    # ensure data.table format
    setDT(dframe)
    setDT(midfield_term) # immediately subset, so no changes by reference
    
    # required columns
    assert_names(colnames(dframe),
                 must.include = c("mcid")
    )
    assert_names(colnames(midfield_term),
                 must.include = c("mcid", "term", "level")
    )
    
    # class of required columns
    qassert(dframe[, mcid], "s+")
    qassert(midfield_term[, mcid], "s+")
    qassert(midfield_term[, term], "s+")
    qassert(midfield_term[, level], "s+")
    
    # bind names due to NSE notes in R CMD check
    timely_term <- NULL
    adj_span <- NULL
    level_i <- NULL
    term_i <- NULL
    delta <- NULL
    yyyy <- NULL
    
    # do the work
    
    # variables added by this function and functions called (if any)
    initial_traits_cols <- c("term_i", "level_i")
    new_cols <- c(initial_traits_cols, "adj_span", "timely_term")
    
    # retain original variables NOT in the vector of new columns 
    old_cols <- find_old_cols(dframe, new_cols) 
    dframe <- dframe[, .SD, .SDcols = old_cols]
    
    # begin
    DT <- copy(dframe)
    
    # add first recorded term_i and level_i 
    DT <- add_initial_term(DT, midfield_term)
    DT <- add_initial_level(DT, midfield_term)
    DT <- DT[, .SD, .SDcols = c("mcid", initial_traits_cols)]
    
    # begin constructing the timely term
    DT[, `:=`(
        yyyy = substr(term_i, 1, 4),
        t    = substr(term_i, 5, 5)
    )]
    
    # for month terms, (letters A, B, C, ...), set first term to zero
    DT <- DT[t %chin% LETTERS | t %chin% letters, t := "0"]
    
    # make year and term numeric
    DT[, `:=`(
        yyyy = as.numeric(yyyy),
        t    = as.numeric(t)
    )] 
    
    # if first term is in summer, delay to the subsequent Fall
    DT[t > 3, `:=`(yyyy = yyyy + 1, t = 1)]
    
    # reduce span by assumed number of completed years by level
    DT[, delta := fcase(
        level_i %like% "04", 3,
        level_i %like% "03", 2,
        level_i %like% "02", 1,
        default = 0
    )]
    DT[, adj_span := span - delta]
    
    # use adj_span to construct estimated timely-completion term
    DT[t == 0 | t == 1, timely_term := paste0(yyyy + adj_span - 1, 3)]
    DT[t > 1, timely_term := paste0(yyyy + adj_span, 1)]
    
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

# Add students' initial terms

add_initial_term <- function(dframe, midfield_term) {
    
    # remove keys if any 
    on.exit(setkey(dframe, NULL))
    on.exit(setkey(midfield_term, NULL), add = TRUE)
    
    # ensure data.table format, changes by reference 
    setDT(dframe)
    setDT(midfield_term)
    
    # variables added by this function
    new_cols <- c("term_i")
    
    # retain original variables NOT in the vector of new columns 
    old_cols <- find_old_cols(dframe, new_cols) 
    dframe <- dframe[, .SD, .SDcols = old_cols]
    
    # obtain new_cols keyed by ID
    DT <- filter_match(
        dframe = midfield_term,
        match_to = dframe,
        by_col = "mcid",
        select = c("mcid", "term")
    )
    
    # retain first term by ID
    setkeyv(DT, c("mcid", "term"))
    DT <- DT[, .SD[1], by = c("mcid")]
    
    # rename new columns 
    setnames(DT,
             old = c("term"),
             new = c("term_i")
    )
    
    # left outer join new columns to dframe by key(s)
    setkeyv(DT, "mcid")
    setkeyv(dframe, "mcid")
    dframe <- DT[dframe] 
    
    # enable printing (see data.table FAQ 2.23)
    dframe[]  
}

# ------------------------------------------------------------------------

# Add students' initial levels

add_initial_level <- function(dframe, midfield_term) {
    
    # remove keys if any 
    on.exit(setkey(dframe, NULL))
    on.exit(setkey(midfield_term, NULL), add = TRUE)
    
    # ensure data.table format, changes by reference 
    setDT(dframe)
    setDT(midfield_term)
    
    # variables added by this function and functions called (if any)
    new_cols <- c("level_i")
    
    # retain original variables NOT in the vector of new columns 
    old_cols <- find_old_cols(dframe, new_cols) 
    dframe <- dframe[, .SD, .SDcols = old_cols]
    
    # obtain new_cols keyed by ID
    DT <- filter_match(
        dframe = midfield_term,
        match_to = dframe,
        by_col = "mcid",
        select = c("mcid", "term", "level")
    )
    
    # retain first term by ID
    setkeyv(DT, c("mcid", "term"))
    DT <- DT[, .SD[1], by = c("mcid")]
    
    # rename new columns 
    setnames(DT,
             old = c("level"),
             new = c("level_i")
    )
    
    # left outer join new columns to dframe by key(s)
    setkeyv(DT, "mcid")
    setkeyv(dframe, "mcid")
    dframe <- DT[dframe] 
    
    # enable printing (see data.table FAQ 2.23)
    dframe[]  
}
