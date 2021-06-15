#' @import data.table
#' @importFrom wrapr stop_if_dot_args
NULL

#' Add a column to evaluate data sufficiency
#'
#' Add a column of logical values (TRUE/FALSE) to a data frame indicating
#' whether the available data include a sufficient range of years to justify
#' including a student in an analysis. Based on information in the MIDFIELD
#' \code{term} data table.
#'
#' Program completion is typically considered timely if it occurs within a
#' specific span of years after admission. Students admitted too near the
#' last term in the available data are generally excluded from a study because
#' the data have insufficient range to fairly assess their records.
#'
#' The input data frame \code{dframe} must include the \code{timely_term}
#' column obtained using the \code{add_timely_term()} function. Students can be
#' retained in a study if their estimated timely completion term is no later
#' than the last term in their institution's data.
#'
#' If the result in the \code{data_sufficiency} column is TRUE, then then student
#' should be included in the research. If FALSE, the student should be excluded
#' before calculating any persistence metric involving program completion
#' (graduation). The function itself performs no subsetting.
#'
#' If \code{details} is TRUE, additional column(s) that support the finding
#' are returned as well. Here the extra column is \code{inst_limit}, the latest
#' term reported by the institution in the available data.
#'
#' Existing columns with the same names as the added columns are overwritten.
#'
#' @param dframe Data frame with required variables
#'        \code{institution} and \code{timely_term}.
#' @param midfield_table MIDFIELD \code{term} data table or equivalent
#'        with required variables \code{institution} and \code{term}.
#' @param ... Not used, forces later arguments to be used by name.
#' @param details Logical scalar to add optional columns reporting information
#'        on which the evaluation is based, default FALSE.
#' @return A \code{data.table}  with the following properties:
#' \itemize{
#'     \item Rows are not modified.
#'     \item Column \code{data_sufficiency} is added with an option to add
#'           column \code{inst_limit}.
#'     \item Grouping structures are not preserved.
#' }
#' @family add_*
#' @export
#' @examples
#' # TBD
add_data_sufficiency <- function(dframe,
                                 midfield_table,
                                 ...,
                                 details = NULL) {

    # force arguments after dots to be used by name
    wrapr::stop_if_dot_args(
        substitute(list(...)),
        paste("Arguments after ... must be named.\n",
              "* Did you forget to write `details = `?\n *")

    )

    # explicit arguments and NULL defaults if any
    assert_explicit(dframe)
    assert_explicit(midfield_table)
    details <- details %||% FALSE

    # check argument class
    assert_class(dframe, "data.frame")
    assert_class(midfield_table, "data.frame")
    assert_class(details, "logical")

    # dframe is modified "by reference" throughout
    setDT(dframe)
    setDT(midfield_table)

    # existence of required columns
    assert_required_column(dframe, "institution")
    assert_required_column(dframe, "timely_term")
    assert_required_column(midfield_table, "institution")
    assert_required_column(midfield_table, "term")

    # class of required columns
    assert_class(dframe[, institution], "character")
    assert_class(dframe[, timely_term], "character")
    assert_class(midfield_table[, term], "character")
    assert_class(midfield_table[, institution], "character")

    # bind names due to NSE notes in R CMD check
    data_sufficiency <- NULL
    timely_term <- NULL
    inst_limit <- NULL

    # preserve column order except columns that match new columns
    names_dframe <- colnames(dframe)
    cols_we_add <- c("inst_limit", "data_sufficiency")
    key_names <- names_dframe[!names_dframe %chin% cols_we_add]
    dframe <- dframe[, key_names, with = FALSE]

    # from midfield_table, get institution last term
    dframe <- add_inst_limit(dframe, midfield_table = midfield_table)

    # assess the data sufficiency
    dframe[, data_sufficiency := fifelse(timely_term <= inst_limit, TRUE, FALSE)]

    # restore column and row order
    set_colrow_order(dframe, key_names)

    # include or omit the details columns
    if (details == FALSE) {
        cols_we_want <- c(key_names, "data_sufficiency")
        dframe <- dframe[, cols_we_want, with = FALSE]
    }

    # remove grouping structure, if any
    setkey(dframe, NULL)

    # enable printing (see data.table FAQ 2.23)
    dframe[]
}

