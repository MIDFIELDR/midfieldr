#' @import data.table
#' @importFrom wrapr stop_if_dot_args
NULL

#' Add a column to evaluate record length
#'
#' Given a student's estimated timely completion limit and the range of data
#' available from their institution, evaluate if the record is of
#' sufficient length to fairly assess timely completion.
#'
#' The data frame argument must include the \code{timely_limit} column
#' obtained from the \code{add_timely_limit()} function.
#'
#' If \code{details} is TRUE, additional column(s) that support the finding
#' are returned as well. Here the extra column is the latest term in the
#' record by institution, \code{inst_limit}.
#'
#' @param dframe data frame
#' @param ... not used, forces later arguments to be used by name
#' @param record data frame of term attributes, default midfieldterms
#' @param details logical scalar to add columns reporting information on
#'        which the fair record evaluation is based, default FALSE
#' @return Data frame with the following properties:
#' \itemize{
#'     \item Rows are not modified
#'     \item Column \code{fair_record} is added, column \code{inst_limit}
#'           is added optionally
#'     \item Data frame attributes \code{tbl} or \code{data.table}
#'           are preserved
#'     \item Grouping structures are not preserved
#' }
#' @examples
#' # TBD
#'
#' @family functions
#' @export
eval_fair_record <- function(dframe,
                             ...,
                             record = NULL,
                             details = NULL) {

    # added columns
    # inst_limit  : institute last term in data
    # fair_record : TRUE/FALSE timely_limit <- inst_limit

    # default arguments if NULL
    record  <- record  %||% midfielddata::midfieldterms
    details <- details %||% FALSE

    # bind names due to nonstandard evaluation notes in R CMD check
    inst_limit <- NULL
    fair_record <- NULL
    timely_limit <- NULL

    # assert arguments
    # dframe    data.frame
    # record    data frame
    # details   logical

    # assert required variables
    # dframe    institution     character
    # dframe    timely_limit         character
    # record    institution     character
    # record    term            character

    # preserve original data.frame, data.table, or tibble class
    df_class <- get_dframe_class(dframe)

    # prepare dframe, preserve column order for return
    # omit existing column(s) that match column(s) we add
    setDT(dframe)
    names_dframe <- colnames(dframe)
    cols_we_add <- c("inst_limit", "fair_record")
    key_names <- names_dframe[!names_dframe %chin% cols_we_add]
    dframe <- dframe[, key_names, with = FALSE]

    # work on the record data
    # get institution last term in the record
    dframe <- add_inst_limit(dframe, record = record)

    # assess the record length, add new TRUE/FALSE column fair_record
    dframe[, fair_record := fifelse(timely_limit <= inst_limit, TRUE, FALSE)]

    # prepare return
    # order columns and rows using original columns as keys
    set_colrow_order(dframe, key_names)

    # do we return the details variables?
    if (details == FALSE) { # omit the details
        cols_we_want <- c(key_names, "fair_record")
        dframe <- dframe[, cols_we_want, with = FALSE]
    }

    # restore original data frame class
    revive_class(dframe, df_class)
}

