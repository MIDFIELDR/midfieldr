#' @import data.table
#' @importFrom wrapr stop_if_dot_args
NULL

#' Add columns for race/ethnicity and sex
#'
#' Add variables \code{race} and \code{sex} from \code{student} to a
#' data frame, using \code{mcid} as the join-by variable.
#'
#' Existing variables with the same names, if any, are overwritten.
#'
#' @param dframe data frame with required variable \code{mcid}
#' @param midfield_table MIDFIELD \code{student} table, with required
#'        variables \code{mcid}, \code{race}, and \code{sex}
#' @return A \code{data.table}  with the following properties:
#' \itemize{
#'     \item Rows are not modified
#'     \item Columns \code{race} and \code{sex} are added
#'     \item Grouping structures are not preserved
#' }
#' @family functions
#' @export
#' @examples
#' # TBD
add_race_sex <- function(dframe,
                         midfield_table = NULL) {

    # default arguments if NULL
    midfield_table <- midfield_table %||% midfielddata::student

    # bind names due to NSE notes in R CMD check
    # var <- NULL

    # check arguments
    assert_explicit(dframe)
    assert_class(dframe, "data.frame")
    assert_class(midfield_table, "data.frame")

    # The dframe argument is modified "by reference." Thus changing its value
    # inside the function immediately changes its value in the calling frame
    # --- a data.table feature designed for fast data manipulation,
    # especially for data that occupies a lot of memory.
    setDT(dframe)
    setDT(midfield_table)

    # existence of required columns
    assert_required_column(dframe, "mcid")
    assert_required_column(midfield_table, "mcid")
    assert_required_column(midfield_table, "race")
    assert_required_column(midfield_table, "sex")

    # class of required columns
    assert_class(dframe[, mcid], "character")
    assert_class(midfield_table[, mcid], "character")
    assert_class(midfield_table[, race], "character")
    assert_class(midfield_table[, sex], "character")

    # preserve column order except columns that match new columns
    names_dframe <- colnames(dframe)
    added_cols <- c("race", "sex")
    key_names <- names_dframe[!names_dframe %chin% added_cols]
    dframe <- dframe[, key_names, with = FALSE]

    # work on the midfield_table data
    # cols_we_want <- c("mcid", added_cols)
    # rows_we_want <- midfield_table$mcid %chin% dframe$mcid
    # DT <- midfield_table[rows_we_want, cols_we_want, with = FALSE]

    DT <- filter_by_key(dframe = midfield_table,
                        match_to = dframe,
                        key_col = "mcid",
                        select = c("mcid", added_cols))


    # left-outer join, keep all rows of dframe
    dframe <-  merge(dframe, DT, by = "mcid", all.x = TRUE)

    # restore column and row order
    set_colrow_order(dframe, key_names)

    # remove grouping structure, if any
    setkey(dframe, NULL)

    # enable printing (see data.table FAQ 2.23)
    dframe[]
}

