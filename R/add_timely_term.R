#' @import data.table
#' @importFrom wrapr stop_if_dot_args
NULL

#' Add a column of terms delimiting timely completion
#'
#' Add a column of academic term values to a data frame indicating the latest
#' term by which a student can graduate and have it considered a timely
#' completion. Student ID is the join-by variable; terms are encoded as
#' character strings YYYYT. Based on information in the MIDFIELD \code{term}
#' data table.
#'
#' The basic heuristic starts with \code{span} number of years for each student
#' (default 6 years). The span for students admitted at a higher level than
#' first year are reduced by one year for each full year the student is
#' assumed to have completed.
#'
#' For example, a student admitted at the second-year level is assumed
#' to have completed one year of a program, so their span is reduced by one
#' year. Similarly, spans are reduced by two years for students admitted at
#' the 3rd-year level and by three years for students admitted at the
#' fourth-year level.
#'
#' The adjusted span of years is added to their starting term; the result is
#' the timely completion term reported in the \code{timely_term} column.
#'
#' The timely completion term is used in two evaluations: filtering for data
#' sufficiency (see \code{add_data_sufficiency()}) and assessing
#' completion for timeliness (\code{add_completion_timely()}).
#'
#' If \code{details} is TRUE, additional column(s) that support the finding
#' are returned as well. Here the extra columns are the student's initial
#' (admission) term \code{term_i}, initial level \code{level_i}, and
#' the adjusted span \code{adj_span}.
#'
#' Existing columns with the same names as the added columns are overwritten.
#'
#' @param dframe Data frame with required variable \code{mcid}.
#' @param midfield_table MIDFIELD \code{term} data table or equivalent with
#'        required variables \code{mcid}, \code{term}, and \code{level}.
#' @param ... Not used, forces later arguments to be used by name.
#' @param details Logical scalar to add optional columns reporting information
#'        on which the evaluation is based, default FALSE.
#' @param span Numeric scalar, number of years to define timely completion,
#'        default 6 years.
#' @return A \code{data.table}  with the following properties:
#' \itemize{
#'     \item Rows are not modified.
#'     \item Column \code{timely_term} is added with an option to add
#'           columns \code{term_i}, \code{level_i}, and \code{adj_span}.
#'     \item Grouping structures are not preserved.
#' }
#' @family add_*
#' @export
#' @examples
#' # TBD
add_timely_term<- function(dframe,
                           midfield_table,
                           ...,
                           details = NULL,
                           span = NULL) {

    # force arguments after dots to be used by name
    wrapr::stop_if_dot_args(
        substitute(list(...)), "Arguments after ... must be named,"
    )

    # explicit arguments and NULL defaults if any
    assert_explicit(dframe)
    assert_explicit(midfield_table)
    details <- details %||% FALSE
    span <- span %||% 6

    # check argument class
    assert_class(dframe, "data.frame")
    assert_class(span, "numeric")
    assert_class(midfield_table, "data.frame")
    assert_class(details, "logical")

    # dframe is modified "by reference" throughout
    setDT(dframe)
    setDT(midfield_table)

    # existence of required columns
    assert_required_column(dframe, "mcid")
    assert_required_column(midfield_table, "mcid")
    assert_required_column(midfield_table, "term")
    assert_required_column(midfield_table, "level")

    # class of required columns
    assert_class(dframe[, mcid], "character")
    assert_class(midfield_table[, mcid], "character")
    assert_class(midfield_table[, term], "character")
    assert_class(midfield_table[, level], "character")

    # bind names due to NSE notes in R CMD check
    timely_term <- NULL
    adj_span <- NULL
    level_i <- NULL
    delta <- NULL
    yyyy <- NULL

    # condition dframe  -----------------------------------------------
    # new columns that overwrite existing columns if any
    new_cols <- c("term_i", "level_i", "adj_span", "timely_term")

    # existing column names to keep and restore
    names_dframe <- colnames(dframe)
    keep_cols <- names_dframe[!names_dframe %chin% new_cols]
    dframe <- dframe[, keep_cols, with = FALSE]

    # condition subset of midfield table ------------------------------
    DT <- filter_match(dframe = midfield_table,
                        match_to = dframe,
                        by_col = "mcid",
                        select =  c("mcid", "term", "level"))

    # separate term encoding
    DT[, `:=` (yyyy = as.numeric(substr(term, 1, 4)),
               t = as.numeric(substr(term, 5, 5)))]

    # keep fall through summer terms, omit "month" terms A, B, etc.
    DT <- DT[t %in% seq(1, 6)]

    # retain the first recorded term by ID
    setorderv(DT, c("mcid", "term"))
    DT <- DT[, .SD[1], by = c("mcid")]
    setnames(DT,
             old = c("term", "level"),
             new = c("term_i", "level_i"))

    # if first term is in summer, delay to the subsequent Fall
    DT[t %in% c(4, 5, 6), `:=` (yyyy = yyyy + 1, t = 1)]

    # reduce span by assumed number of completed years by level
    DT[, delta := fcase(
        level_i %like% "04", 3,
        level_i %like% "03", 2,
        level_i %like% "02", 1,
        default = 0
    )]
    DT[, adj_span := span - delta]

    # use adj_span to construct estimated term for timely-completion
    DT[t == 1, timely_term:= paste0(yyyy + adj_span - 1, 3)]
    DT[t  > 1, timely_term:= paste0(yyyy + adj_span    , 1)]

    # remove intermediate variables
    DT[, c("yyyy", "t", "delta") := NULL]

    # left outer join DT to dframe -------------------------------------
    setkeyv(DT, "mcid")
    setkeyv(dframe, "mcid")
    dframe <- DT[dframe]

    # restore column and row order
    set_colrow_order(dframe, keep_cols)

    # drop the optional columns if details not requested
    if (details == FALSE) {
        keep_cols <- c(keep_cols, "timely_term")
        dframe <- dframe[, keep_cols, with = FALSE]
    }

    # remove grouping structure, if any
    setkey(dframe, NULL)

    # enable printing (see data.table FAQ 2.23)
    dframe[]
}

