#' @import data.table
#' @importFrom wrapr stop_if_dot_args
NULL

#' Add columns for race/ethnicity and sex
#'
#' Add variables \code{race} and \code{sex} from \code{dbase} to a data
#' frame, using \code{id} is the join-by variable.
#'
#' Existing variables with the same names, if any, are overwritten.
#'
#' @param dframe data frame
#' @param ... not used, forces later arguments to be used by name
#' @param dbase data frame of student attributes, default midfieldstudents
#' @return Data frame with the following properties:
#' \itemize{
#'     \item Rows are not modified
#'     \item Columns \code{race} and \code{sex} are added
#'     \item Data frame attributes \code{tbl} or \code{data.table}
#'           are preserved
#'     \item Grouping structures are not preserved
#' }
#' @export
#' @examples
#' # TBD
add_race_sex <- function(dframe,
                         ...,
                         dbase = NULL) {

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
    assert_required_column(dbase, "race")
    assert_required_column(dbase, "sex")

    # class of required columns
    assert_class(dframe[, id], "character")
    assert_class(dbase[, id], "character")
    assert_class(dbase[, race], "character")
    assert_class(dbase[, sex], "character")

    # preserve original data.frame, data.table, or tibble class
    df_class <- get_dframe_class(dframe)

    # prepare dframe, preserve column order for return
    # omit existing column(s) that match column(s) we add
    setDT(dframe)
    added_cols <- c("race", "sex")
    names_dframe <- colnames(dframe)
    key_names <- names_dframe[!names_dframe %chin% added_cols]
    dframe <- dframe[, key_names, with = FALSE]

    # work on the dbase data
    cols_we_want <- c("id", added_cols)
    rows_we_want <- dbase$id %chin% dframe$id
    DT <- dbase[rows_we_want, cols_we_want, with = FALSE]

    # left-outer join, keep all rows of dframe
    dframe <-  merge(dframe, DT, by = "id", all.x = TRUE)

    # prepare return
    # order columns and rows using original columns as keys
    set_colrow_order(dframe, key_names)

    # restore original data frame class
    revive_class(dframe, df_class)
}

