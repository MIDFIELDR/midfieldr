#' @import data.table
#' @importFrom wrapr stop_if_dot_args
NULL

#' Add columns for race/ethnicity and sex
#'
#' Add variables \code{race} and \code{sex} from \code{mdata} to a data
#' frame, using \code{mcid} as the join-by variable.
#'
#' Existing variables with the same names, if any, are overwritten.
#'
#' @param dframe data frame with required variable \code{mcid}
#' @param ... not used, forces later arguments to be used by name
#' @param mdata MIDFIELD student data, default \code{midfielddata::student},
#'        with required variables \code{mcid}, \code{race}, and \code{sex}
#' @return A \code{data.table}  with the following properties:
#' \itemize{
#'     \item Rows are not modified
#'     \item Columns \code{race} and \code{sex} are added
#'     \item Grouping structures are not preserved
#' }
#' @export
#' @examples
#' # TBD
add_race_sex <- function(dframe,
                         ...,
                         mdata = NULL) {

    wrapr::stop_if_dot_args(
        substitute(list(...)), "Arguments after ... must be named,"
    )

    # default arguments if NULL
    mdata <- mdata %||% midfielddata::student

    # bind names due to NSE notes in R CMD check
    # var <- NULL

    # check arguments
    assert_explicit(dframe)
    assert_class(dframe, "data.frame")
    assert_class(mdata, "data.frame")

    # The dframe argument is modified "by reference." Thus changing its value
    # inside the function immediately changes its value in the calling frame
    # --- a data.table feature designed for fast data manipulation,
    # especially for data that occupies a lot of memory.
    setDT(dframe)
    setDT(mdata)

    # existence of required columns
    assert_required_column(dframe, "mcid")
    assert_required_column(mdata, "mcid")
    assert_required_column(mdata, "race")
    assert_required_column(mdata, "sex")

    # class of required columns
    assert_class(dframe[, mcid], "character")
    assert_class(mdata[, mcid], "character")
    assert_class(mdata[, race], "character")
    assert_class(mdata[, sex], "character")

    # preserve column order except columns that match new columns
    names_dframe <- colnames(dframe)
    added_cols <- c("race", "sex")
    key_names <- names_dframe[!names_dframe %chin% added_cols]
    dframe <- dframe[, key_names, with = FALSE]

    # work on the mdata data
    cols_we_want <- c("mcid", added_cols)
    rows_we_want <- mdata$mcid %chin% dframe$mcid
    DT <- mdata[rows_we_want, cols_we_want, with = FALSE]

    # left-outer join, keep all rows of dframe
    dframe <-  merge(dframe, DT, by = "mcid", all.x = TRUE)

    # restore column and row order
    set_colrow_order(dframe, key_names)

    # remove grouping structure, if any
    setkey(dframe, NULL)

    # enable printing (see data.table FAQ 2.23)
    dframe[]
}

