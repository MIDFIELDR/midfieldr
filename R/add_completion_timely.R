#' @import data.table
#' @importFrom wrapr stop_if_dot_args
#' @importFrom stats na.omit
NULL

#' Add column from degree to evaluate timely completion
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
#' The data frame argument must include the \code{timely_term} column
#' obtained using the \code{add_timely_term()} function. Completion is
#' considered timely if: 1) the student has completed a program; and 2) the
#' degree term is no later than the timely completion limit.
#'
#' If \code{details} is TRUE, additional column(s) that support the finding
#' are returned as well. Here the extra columns are \code{completion}
#' indicating by TRUE/FALSE if the student completed their program and
#' \code{term_degree} from the degree table giving the term in
#' which the first degree(s), if any, was earned.
#'
#' @param dframe Data frame with required variables
#'        \code{mcid} and \code{timely_term}.
#' @param midfield_table MIDFIELD degree data table with required
#'        variables \code{mcid} and \code{term}.
#' @param ... Not used, forces later arguments to be used by name.
#' @param details Logical scalar to add columns reporting information on
#'        which the evaluation is based, default FALSE.
#' @return A \code{data.table} with the following properties:
#' \itemize{
#'     \item Rows are not modified.
#'     \item Column \code{completion_timely} is added, columns
#'           \code{completion} and \code{term_degree} are added optionally.
#'     \item Grouping structures are not preserved.
#' }
#' @family functions
#' @export
#' @examples
#' # TBD
add_completion_timely <- function(dframe,
                                  midfield_table,
                                  ...,
                                  details = NULL) {

    # force arguments after dots to be used by name
    wrapr::stop_if_dot_args(
        substitute(list(...)), "Arguments after ... must be named,"
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
    assert_required_column(dframe, "mcid")
    assert_required_column(dframe, "timely_term")
    assert_required_column(midfield_table, "mcid")
    assert_required_column(midfield_table, "term")

    # class of required columns
    assert_class(dframe[, mcid], "character")
    assert_class(dframe[, timely_term], "character")
    assert_class(midfield_table[, mcid], "character")
    assert_class(midfield_table[, term], "character")

    # bind names due to NSE notes in R CMD check
    completion_timely <- NULL
    term_degree <- NULL
    timely_term <- NULL
    completion <- NULL

    # preserve "term" column if exists in incoming df
    names_dframe <- colnames(dframe)
    if ("term" %chin% names_dframe) {
        setnames(dframe, old = "term", new = "existing_term_col")
    }

    # preserve column order except columns that match new columns
    cols_we_add <- c("term_degree", "completion", "completion_timely")
    key_names <- names_dframe[!names_dframe %chin% cols_we_add]
    dframe <- dframe[, key_names, with = FALSE]

    # subset midfield data table
    DT <- filter_match(midfield_table,
                        match_to = dframe,
                        by_col = "mcid",
                        select = c("mcid", "term"))

    # keep the first degree term
    setorderv(DT, c("mcid", "term"))
    DT <- na.omit(DT, cols = c("term"))
    DT <- DT[, .SD[1], by = "mcid"]
    setkey(DT, NULL)

    # rename term to term-degree
    setnames(DT, old = "term", new = "term_degree")

    # left-outer join, keep all rows of dframe
    dframe <-  merge(dframe, DT, by = "mcid", all.x = TRUE)

    # add program completion status column
    dframe[, completion := fifelse(is.na(term_degree), FALSE, TRUE)]

    # evaluate, is the completion timely, TRUE / FALSE
    dframe[, completion_timely := fifelse(term_degree <= timely_term,
                                           TRUE, FALSE, na = FALSE)]

    # restore column and row order
    set_colrow_order(dframe, key_names)

    # include or omit the details columns
    if (details == FALSE) {
        cols_we_want <- c(key_names, "completion_timely")
        dframe <- dframe[, cols_we_want, with = FALSE]
    }

    # remove grouping structure, if any
    setkey(dframe, NULL)

    # restore "term" column if exists in incoming df
    if ("existing_term_col" %chin% names(dframe)) {
        setnames(dframe, old = "existing_term_col", new = "term")
    }

    # enable printing (see data.table FAQ 2.23)
    dframe[]
}

