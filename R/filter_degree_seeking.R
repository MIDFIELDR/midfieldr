#' @import data.table
#' @importFrom wrapr stop_if_dot_args
NULL

#' Subset a data frame for matriculants
#'
#' Subset a data frame by student ID, retaining students who are degree-seeking.
#'
#' An inner join between \code{dframe} and the ID column of \code{dbase}
#' retains all rows of \code{dframe} with matching IDs.
#'
#' @param dframe data frame with an ID column
#' @param ... not used, forces later arguments to be used by name
#' @param dbase data frame of student attributes, default midfieldstudents
#' @return Data frame with the following properties:
#' \itemize{
#'     \item Rows with matching IDs in \code{dbase}
#'     \item Columns are not modified
#'     \item Data frame attributes \code{tbl} or \code{data.table}
#'           are preserved
#'     \item Grouping structures are not preserved
#' }
#' @seealso \code{add_race_sex()}, \code{add_term_timely()},
#'          \code{add_data_sufficiency()}, \code{add_completion_timely()}
#' @export
#' @examples
#' # TBD
filter_degree_seeking <- function(dframe, ..., dbase = NULL) {

    wrapr::stop_if_dot_args(
        substitute(list(...)), "Arguments after ... must be named,"
    )

    # default arguments if NULL
    dbase <- dbase %||% midfielddata::midfieldstudents

    # bind names due to nonstandard evaluation notes in R CMD check
    # var <- NULL

    # check arguments
    assert_explicit(dframe)
    assert_class(dframe, "data.frame")
    assert_class(dbase, "data.frame")

    # existence of required columns
    assert_required_column(dframe, "id")
    assert_required_column(dbase, "id")

    # class of required columns
    assert_class(dframe$id, "character")
    assert_class(dbase$id, "character")

    # preserve original data.frame, data.table, or tibble class
    df_class <- get_dframe_class(dframe)

    # prepare dframe
    # preserve column order for return
    setDT(dframe)
    key_names <- names(dframe)

    # work with dbase
    # IDs in the dbase of matriculants
    DT <- dbase[, .(id)]

    # inner join, omit students not in matriculation data
    setkeyv(DT, "id")
    setkeyv(dframe, "id")
    dframe <- DT[dframe, nomatch = 0] # data.table syntax for inner join

    # prepare return
    # original columns as keys, order columns and rows
    set_colrow_order(dframe, key_names)

    # restore original data frame class
    revive_class(dframe, df_class)
}
