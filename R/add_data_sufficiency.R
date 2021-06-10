#' @import data.table
#' @importFrom wrapr stop_if_dot_args
NULL

#' Add a column to evaluate data sufficiency
#'
#' A column is added to a data frame indicating whether the data include a
#' sufficient number of years to justify including a student in an analysis
#' of student records. The new column is a logical variable (TRUE/FALSE
#' values).
#'
#' Program completion is typically assessed over a given span of years after
#' admission. A student admitted too near the last term in the
#' available data should be excluded from analysis because the data
#' have insufficient span to fairly assess the student's record.
#'
#' The data frame argument must include the \code{timely_term} column
#' obtained using the \code{add_timely_term()} function. Assessment is
#' considered fair if the student's timely completion term is no later than
#' the last term in their institution's data.
#'
#' If the result in the \code{data_sufficiency} column is TRUE, then then student
#' should be included in the research. If FALSE, the student should be excluded
#' before calculating any persistence metric involving program completion
#' (graduation). The function performs no subsetting.
#'
#' If \code{details} is TRUE, additional column(s) that support the finding
#' are returned as well. Here the extra column \code{inst_limit}, the latest
#' term reported by the institution in the available data.
#'
#' @param dframe data frame with required variables
#'        \code{institution} and \code{timely_term}
#' @param ... not used, forces later arguments to be used by name
#' @param mdata MIDFIELD term data, default \code{midfielddata::term},
#'        with required variables \code{institution} and \code{term}
#' @param details logical scalar to add columns reporting information on
#'        which the evaluation is based, default FALSE
#' @return A \code{data.table}  with the following properties:
#' \itemize{
#'     \item Rows are not modified
#'     \item Column \code{data_sufficiency} is added, column \code{inst_limit}
#'           is added optionally
#'     \item Grouping structures are not preserved
#' }
#' @family functions
#' @export
#' @examples
#' # TBD
add_data_sufficiency <- function(dframe,
                             ...,
                             mdata = NULL,
                             details = NULL) {

    wrapr::stop_if_dot_args(
        substitute(list(...)), "Arguments after ... must be named,"
    )

    # explicit or NULL arguments
    assert_explicit(dframe)
    mdata  <- mdata  %||% midfielddata::term
    details <- details %||% FALSE

    # check argument class
    assert_class(dframe, "data.frame")
    assert_class(mdata, "data.frame")
    assert_class(details, "logical")

    # The dframe argument is modified "by reference." Thus changing its value
    # inside the function immediately changes its value in the calling frame
    # --- a data.table feature designed for fast data manipulation,
    # especially for data that occupies a lot of memory.
    setDT(dframe)
    setDT(mdata)

    # existence of required columns
    assert_required_column(dframe, "institution")
    assert_required_column(dframe, "timely_term")
    assert_required_column(mdata, "institution")
    assert_required_column(mdata, "term")

    # class of required columns
    assert_class(dframe[, institution], "character")
    assert_class(dframe[, timely_term], "character")
    assert_class(mdata[, term], "character")
    assert_class(mdata[, institution], "character")

    # bind names due to NSE notes in R CMD check
    data_sufficiency <- NULL
    timely_term <- NULL
    inst_limit <- NULL

    # preserve column order except columns that match new columns
    names_dframe <- colnames(dframe)
    cols_we_add <- c("inst_limit", "data_sufficiency")
    key_names <- names_dframe[!names_dframe %chin% cols_we_add]
    dframe <- dframe[, key_names, with = FALSE]

    # from mdata, get institution last term
    dframe <- add_inst_limit(dframe, mdata = mdata)

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

