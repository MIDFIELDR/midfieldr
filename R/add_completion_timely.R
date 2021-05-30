#' @import data.table
#' @importFrom wrapr stop_if_dot_args
#' @importFrom stats na.omit
NULL

#' Add a column to evaluate timely completion
#'
#' A logical variable is added to a data frame indicating whether a student
#' has completed their program in a timely manner.
#'
#' Program completion is typically considered timely if it occurs within a
#' given span of years after matriculation. In a persistence metric involving
#' graduation, students with timely completion should be grouped as graduates.
#' Students whose completion is not timely should be grouped with the
#' non-graduates.
#'
#' The data frame argument must include the \code{term_timely} column
#' obtained using the \code{add_term_timely()} function. Completion is
#' considered timely if: 1) the student has completed a program; and 2) the
#' degree term is no later than the timely completion limit.
#'
#' If \code{details} is TRUE, additional column(s) that support the finding
#' are returned as well. Here the extra columns are \code{completion}
#' indicating by TRUE/FALSE if the student completed their program and
#' \code{term_degree} from the degree attributes record giving the term in
#' which the first degree(s), if any, was earned.
#'
#' @param dframe data frame
#' @param ... not used, forces later arguments to be used by name
#' @param record data frame of degree attributes, default midfielddegrees
#' @param details logical scalar to add columns reporting information on
#'        which the evaluation is based, default FALSE
#' @return Data frame with the following properties:
#' \itemize{
#'     \item Rows are not modified
#'     \item Column \code{completion_timely} is added, columns
#'      \code{completion} and \code{term_degree} are added optionally
#'     \item Data frame attributes \code{tbl} or \code{data.table}
#'           are preserved
#'     \item Grouping structures are not preserved
#' }
#' @export
#' @examples
#' # TBD
add_completion_timely <- function(dframe,
                                   ...,
                                   record = NULL,
                                   details = NULL) {

    wrapr::stop_if_dot_args(
        substitute(list(...)), "Arguments after ... must be named,"
    )

    # explicit or NULL arguments
    assert_explicit(dframe)
    record  <- record  %||% midfielddata::midfielddegrees
    details <- details %||% FALSE

    # check argument class
    assert_class(dframe, "data.frame")
    assert_class(record, "data.frame")
    assert_class(details, "logical")

    # existence of required columns
    assert_required_column(dframe, "id")
    assert_required_column(dframe, "term_timely")
    assert_required_column(record, "id")
    # to do: revise term in midfielddata to be character, for now:
    record[, term_degree := as.character(term_degree)]
    assert_required_column(record, "term_degree")

    # class of required columns
    assert_class(dframe[, id], "character")
    assert_class(dframe[, term_timely], "character")
    assert_class(record[, id], "character")
    assert_class(record[, term_degree], "character")

    # bind names due to nonstandard evaluation notes in R CMD check
    completion_timely <- NULL
    term_timely<- NULL
    completion <- NULL

    # prepare dframe, preserve class
    df_class <- get_dframe_class(dframe)
    setDT(dframe)

    # preserve columns not being overwritten and their order
    names_dframe <- colnames(dframe)
    cols_we_add <- c("term_degree", "completion", "completion_timely")
    key_names <- names_dframe[!names_dframe %chin% cols_we_add]
    dframe <- dframe[, key_names, with = FALSE]

    # degree term
    cols_we_want <- c("id", "term_degree")
    rows_we_want <- record$id %chin% dframe$id
    DT <- record[rows_we_want, cols_we_want, with = FALSE]

    # keep the first degree term
    setorderv(DT, c("id", "term_degree"))
    DT <- na.omit(DT, cols = c("term_degree"))
    DT <- DT[, .SD[1], by = "id"]

    # left-outer join, keep all rows of dframe
    dframe <-  merge(dframe, DT, by = "id", all.x = TRUE)

    # add program completion status column
    dframe[, completion := fifelse(is.na(term_degree), FALSE, TRUE)]

    # evaluate, is the completion timely, TRUE / FALSE
    dframe[, completion_timely := fifelse(term_degree <= term_timely,
                                          TRUE, FALSE, na = FALSE)]

    # include or omit the details columns
    set_colrow_order(dframe, key_names)

    # include or omit the details columns
    if (details == FALSE) {
        cols_we_want <- c(key_names, "completion_timely")
        dframe <- dframe[, cols_we_want, with = FALSE]
    }

    # restore original data frame class
    revive_class(dframe, df_class)
}

