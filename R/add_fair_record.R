#' @import data.table
#' @importFrom wrapr stop_if_dot_args
NULL

#' Add a column to evaluate record length for fair assessment
#'
#' A logical variable is added to a data frame indicating whether the data
#' available from an institution have sufficient span to fairly assess a
#' student's record.
#'
#' Program completion is typically assessed over a given span of years after
#' matriculation. A student matriculating too near the last term in the
#' available data should be excluded from analysis because the data
#' have insufficient span to fairly assess the student's record.
#'
#' The data frame argument must include the \code{term_timely} column
#' obtained using the \code{add_term_timely()} function. Assessment is
#' considered fair if the student's timely completion term is no later than
#' the last term in their institution's data.
#'
#' If the result in the \code{fair_record} column is TRUE, then then student
#' should be included in the research. If FALSE, the student should be excluded
#' before calculating any persistence metric involving program completion
#' (graduation). The function performs no subsetting.
#'
#' If \code{details} is TRUE, additional column(s) that support the finding
#' are returned as well. Here the extra column \code{inst_limit}, the latest
#' term reported by the institution in the available data.
#'
#' @param dframe data frame
#' @param ... not used, forces later arguments to be used by name
#' @param record data frame of term attributes, default midfieldterms
#' @param details logical scalar to add columns reporting information on
#'        which the evaluation is based, default FALSE
#' @return Data frame with the following properties:
#' \itemize{
#'     \item Rows are not modified
#'     \item Column \code{fair_record} is added, column \code{inst_limit}
#'           is added optionally
#'     \item Data frame attributes \code{tbl} or \code{data.table}
#'           are preserved
#'     \item Grouping structures are not preserved
#' }
#' @export
#' @examples
#' # TBD
add_fair_record <- function(dframe,
                             ...,
                             record = NULL,
                             details = NULL) {

    wrapr::stop_if_dot_args(
        substitute(list(...)), "Arguments after ... must be named,"
    )

    # explicit or NULL arguments
    assert_explicit(dframe)
    record  <- record  %||% midfielddata::midfieldterms
    details <- details %||% FALSE

    # check argument class
    assert_class(dframe, "data.frame")
    assert_class(record, "data.frame")
    assert_class(details, "logical")

    # existence of required columns
    assert_required_column(dframe, "institution")
    assert_required_column(dframe, "term_timely")
    assert_required_column(record, "institution")
    assert_required_column(record, "term")

    # class of required columns
    assert_class(dframe[, institution], "character")
    assert_class(dframe[, term_timely], "character")
    # to do: revise term in midfielddata to be character, for now:
    record[, term := as.character(term)]
    assert_class(record[, term], "character")
    assert_class(record[, institution], "character")

    # bind names due to nonstandard evaluation notes in R CMD check
    inst_limit <- NULL
    fair_record <- NULL
    term_timely<- NULL

    # prepare dframe, preserve class
    df_class <- get_dframe_class(dframe)
    setDT(dframe)

    # preserve columns not being overwritten and their order
    names_dframe <- colnames(dframe)
    cols_we_add <- c("inst_limit", "fair_record")
    key_names <- names_dframe[!names_dframe %chin% cols_we_add]
    dframe <- dframe[, key_names, with = FALSE]

    # from record, get institution last term
    dframe <- add_inst_limit(dframe, record = record)

    # assess the record length
    dframe[, fair_record := fifelse(term_timely <= inst_limit, TRUE, FALSE)]

    # prepare return, order columns and rows
    set_colrow_order(dframe, key_names)

    # include or omit the details columns
    if (details == FALSE) {
        cols_we_want <- c(key_names, "fair_record")
        dframe <- dframe[, cols_we_want, with = FALSE]
    }

    # restore original data frame class
    revive_class(dframe, df_class)
}

